package com.rathorerahul586.flutter_stetho_interceptor

import com.facebook.stetho.inspector.network.NetworkEventReporter.InspectorRequest
import java.io.IOException

/**
 * A Kotlin class to adapt a map-based structure (likely received from Dart)
 * into Stetho's InspectorRequest interface.
 */
internal class FlutterStethoInspectorRequest(private val map: Map<String?, Any?>) : InspectorRequest {

    // Optional user-friendly name suffix
    override fun friendlyNameExtra(): Int? {
        return map["friendlyNameExtra"] as? Int
    }

    // Request URL
    override fun url(): String? {
        return map["url"] as? String
    }

    // HTTP method (GET, POST, etc.)
    override fun method(): String? {
        return map["method"] as? String
    }

    /**
     * Converts the body list (from Dart/Flutter) to a byte array for transmission.
     * Assumes that the 'body' field is a List<Int> representing raw bytes.
     */
    @Throws(IOException::class)
    override fun body(): ByteArray? {
        val body = map["body"] as? List<Int> ?: return null
        return ByteArray(body.size) { i -> body[i].toByte() }
    }

    // Request ID
    override fun id(): String? {
        return map["id"] as? String
    }

    // Friendly name (e.g., the source or description of the request)
    override fun friendlyName(): String? {
        return map["friendlyName"] as? String
    }

    // Total number of headers
    override fun headerCount(): Int {
        return headers.size
    }

    // Header name at a given index
    override fun headerName(index: Int): String {
        return headers.keys.elementAt(index)
    }

    // Header value at a given index
    override fun headerValue(index: Int): String {
        return headers.values.elementAt(index)
    }

    // First value of a given header name
    override fun firstHeaderValue(name: String): String? {
        return headers[name]
    }

    // Lazily retrieve the headers map from the backing map
    private val headers: Map<String, String>
        get() = map["headers"] as? Map<String, String> ?: emptyMap()
}
