package com.rathorerahul586.flutter_stetho_interceptor

import com.facebook.stetho.inspector.network.NetworkEventReporter.InspectorResponse

/**
 * A Kotlin class implementing Stetho's InspectorResponse interface.
 * It adapts a Map (likely passed from Dart/Flutter) into structured response data.
 */
internal class FlutterStethoInspectorResponse(private val map: Map<String?, Any?>) : InspectorResponse {

    override fun url(): String? {
        return map["url"] as? String
    }

    override fun connectionReused(): Boolean {
        return map["connectionReused"] as? Boolean ?: false
    }

    override fun connectionId(): Int {
        return map["connectionId"] as? Int ?: -1
    }

    override fun fromDiskCache(): Boolean {
        return map["fromDiskCache"] as? Boolean ?: false
    }

    override fun requestId(): String? {
        return map["requestId"] as? String
    }

    override fun statusCode(): Int {
        return map["statusCode"] as? Int ?: -1
    }

    override fun reasonPhrase(): String? {
        return map["reasonPhrase"] as? String
    }

    override fun headerCount(): Int {
        return headers.size
    }

    override fun headerName(index: Int): String {
        return headers.keys.elementAt(index)
    }

    override fun headerValue(index: Int): String {
        return headers.values.elementAt(index)
    }

    override fun firstHeaderValue(name: String): String? {
        return headers[name]
    }

    /**
     * Lazily converts 'headers' map from the input map. Returns an empty map if not present.
     */
    private val headers: Map<String, String>
        get() = map["headers"] as? Map<String, String> ?: emptyMap()
}
