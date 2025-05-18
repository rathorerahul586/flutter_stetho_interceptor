package com.rathorerahul586.flutter_stetho_interceptor

import android.content.Context
import com.facebook.stetho.Stetho
import com.facebook.stetho.inspector.network.DefaultResponseHandler
import com.facebook.stetho.inspector.network.NetworkEventReporter
import com.facebook.stetho.inspector.network.NetworkEventReporterImpl
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.IOException
import java.io.PipedInputStream
import java.io.PipedOutputStream
import java.util.concurrent.LinkedBlockingQueue

/** FlutterStethoInterceptorPlugin */
class FlutterStethoInterceptorPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel


    private val mEventReporter: NetworkEventReporter = NetworkEventReporterImpl.get()
    private val inputs = mutableMapOf<String, PipedInputStream>()
    private val outputs = mutableMapOf<String, PipedOutputStream>()
    private val responses = mutableMapOf<String, FlutterStethoInspectorResponse>()
    private val queues =
        mutableMapOf<String, LinkedBlockingQueue<QueueItem>>()
    private lateinit var context: Context


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "flutter_stetho_interceptor"
        )

        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                initStetho()
                result.success(null)
            }

            "requestWillBeSent" -> requestWillBeSent(call.arguments as Map<String?, Any?>)
            "responseHeadersReceived" -> responseHeadersReceived((call.arguments as Map<String?, Any?>))
            "interpretResponseStream" -> interpretResponseStream((call.arguments as String))
            "onDataReceived" -> onDataReceived(call.arguments as Map<String?, Any?>)
            "onDone" -> onDone(call.arguments as String)
            "responseReadFinished" -> mEventReporter.responseReadFinished((call.arguments as String))
            "responseReadFailed" -> {
                val idError = (call.arguments as List<String>)
                mEventReporter.responseReadFailed(idError[0], idError[1])
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun onDone(id: String) {
        android.util.Log.d(TAG, "onDone: $id")
        val pipedOutputStream = outputs[id]
        val doneQueue: LinkedBlockingQueue<QueueItem>? = queues[id]
        try {
            doneQueue?.put(NullQueueItem())
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
    }

    private fun onDataReceived(arguments: Map<String?, Any?>) {
        android.util.Log.d(TAG, "onDataReceived: $arguments")
        val dataId = (arguments["id"] as String?)
        val data = (arguments["data"] as ByteArray?)
        val queue: LinkedBlockingQueue<QueueItem>? = queues[dataId]
        try {
            queue?.put(ByteQueueItem(data))
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
        data?.let {
            mEventReporter.dataReceived(dataId, it.size, it.size)
        }
    }

    private fun responseHeadersReceived(arguments: Map<String?, Any?>) {
        android.util.Log.d(TAG, "responseHeadersReceived: $arguments")
        val response = FlutterStethoInspectorResponse(arguments)
        responses[response.requestId() ?: ""] = response
        mEventReporter.responseHeadersReceived(response)
    }

    private fun requestWillBeSent(arguments: Map<String?, Any?>) {
        android.util.Log.d(TAG, "requestWillBeSent: $arguments")
        mEventReporter.requestWillBeSent(
            FlutterStethoInspectorRequest(
                (arguments)
            )
        )
    }

    private fun interpretResponseStream(interpretedResponseId: String) {
        try {
            val `in` = PipedInputStream()
            val out = PipedOutputStream(`in`)
            val queue = LinkedBlockingQueue<QueueItem>()
            inputs[interpretedResponseId] = `in`
            outputs[interpretedResponseId] = out
            queues[interpretedResponseId] = queue
            android.util.Log.d(TAG, "interpretResponseStream: $String")
            Thread({
                try {
                    var item: QueueItem
                    while ((queue.take().also { item = it }) is ByteQueueItem) {
                        out.write((item as ByteQueueItem).bytes)
                    }
                    out.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }
            }, interpretedResponseId + "src").start()

            Thread({
                val in2 = mEventReporter.interpretResponseStream(
                    interpretedResponseId,
                    responses[interpretedResponseId]?.firstHeaderValue("content-type"),
                    null,
                    `in`,
                    DefaultResponseHandler(mEventReporter, interpretedResponseId)
                )
                try {
                    var item: Int
                    while ((in2!!.read().also { item = it }) != -1);
                    `in`.close()
                    in2.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }, interpretedResponseId + "dst").start()
        } catch (e: IOException) {
            mEventReporter.responseReadFailed(interpretedResponseId, e.message)
        }
    }

    private fun initStetho() {
        android.util.Log.d(TAG, "Initializing stetho")
        Stetho.initializeWithDefaults(context)
    }


    interface QueueItem

    class ByteQueueItem internal constructor(val bytes: ByteArray?) : QueueItem

    class NullQueueItem : QueueItem

    companion object {
        private const val TAG = "FlutterStethoInterceptorPlugin"
    }
}
