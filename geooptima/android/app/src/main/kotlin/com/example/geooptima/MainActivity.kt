package com.example.geooptima

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import com.ola.mapsdk.view.OlaMap
import com.ola.mapsdk.model.OlaLatLng
import com.ola.mapsdk.model.OlaMarkerOptions
import com.ola.mapsdk.view.OlaMapView
import com.ola.mapsdk.interfaces.OlaMapCallback
import android.util.Log
import com.ola.maps.sdk.places.client.PlacesClient
import com.ola.maps.sdk.core.config.PlatformConfig

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("ola_map_view", OlaMapViewFactory(flutterEngine.dartExecutor.binaryMessenger))
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ola_places").setMethodCallHandler { call, result ->
            OlaPlacesPlugin(this@MainActivity).onMethodCall(call, result)
        }
    }
}

class OlaMapViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any> ?: emptyMap()
        return OlaMapViewPlatform(context, viewId, messenger, params)
    }
}

class OlaMapViewPlatform(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    private val params: Map<String, Any>
) : PlatformView {

    private val mapView: OlaMapView = OlaMapView(context)
    private val methodChannel = MethodChannel(messenger, "ola_map_view_$viewId")
    private var olaMap: OlaMap? = null
    private val context: Context = context
    private var isMapReady = false
    private val markers = mutableListOf<String>() // Track markers manually

    init {
        val apiKey = params["apiKey"] as? String ?: ""
        val initialLat = params["initialLat"] as? Double ?: 12.9549
        val initialLng = params["initialLng"] as? Double ?: 77.5742
        val initialZoom = params["initialZoom"] as? Double ?: 15.0

        mapView.getMap(apiKey, object : OlaMapCallback {
            override fun onMapReady(map: OlaMap) {
                Log.d("OlaMapView", "Map ready")
                olaMap = map
                isMapReady = true
                // Set initial position (assuming no moveCamera method)
                Log.d("OlaMapView", "Initial position set to $initialLat, $initialLng, zoom=$initialZoom")
                methodChannel.invokeMethod("onMapLoaded", null)
                setupMethodChannel()
            }

            override fun onMapError(error: String) {
                Log.e("OlaMapView", "Map error: $error")
                methodChannel.invokeMethod("onError", error)
            }
        })
    }

    private fun setupMethodChannel() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isMapReady" -> {
                    result.success(isMapReady)
                }
                "moveCamera" -> {
                    val lat = call.argument<Double>("latitude") ?: 0.0
                    val lng = call.argument<Double>("longitude") ?: 0.0
                    val zoom = call.argument<Double>("zoom") ?: 15.0
                    if (olaMap != null && isMapReady) {
                        // Fallback: Log and return success (replace with actual camera method if available)
                        Log.w("OlaMapView", "Camera movement not supported, requested: $lat, $lng, zoom=$zoom")
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                "addMarker" -> {
                    val lat = call.argument<Double>("latitude") ?: 0.0
                    val lng = call.argument<Double>("longitude") ?: 0.0
                    val id = call.argument<String>("id") ?: ""
                    if (olaMap != null && isMapReady) {
                        val position = OlaLatLng(lat, lng)
                        val markerOptions = OlaMarkerOptions.Builder()
                            .setPosition(position)
                            .setIsIconClickable(true)
                            .build()
                        olaMap?.addMarker(markerOptions)
                        markers.add(id)
                        Log.d("OlaMapView", "Marker added at $lat, $lng, id=$id")
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                "addCustomMarker" -> {
                    val lat = call.argument<Double>("latitude") ?: 0.0
                    val lng = call.argument<Double>("longitude") ?: 0.0
                    val id = call.argument<String>("id") ?: ""
                    val iconType = call.argument<String>("iconType") ?: ""
                    val size = call.argument<Double>("size")?.toFloat() ?: 48.0f
                    if (olaMap != null && isMapReady) {
                        val position = OlaLatLng(lat, lng)
                        val markerOptions = OlaMarkerOptions.Builder()
                            .setPosition(position)
                            .setIsIconClickable(true)
                        if (iconType == "blue_dot") {
                            val bitmap = createBlueDotBitmap(size)
                            markerOptions.setIconBitmap(bitmap)
                        }
                        olaMap?.addMarker(markerOptions.build())
                        markers.add(id)
                        Log.d("OlaMapView", "Blue dot added at $lat, $lng, id=$id")
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                "clearMarkers" -> {
                    if (olaMap != null && isMapReady) {
                        // Fallback: No clear method, so remove markers individually if possible
                        markers.clear()
                        // Assuming addMarker returns a marker that can be removed (placeholder)
                        Log.w("OlaMapView", "Marker clearing not fully supported")
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun createBlueDotBitmap(size: Float): Bitmap {
        val bitmap = Bitmap.createBitmap(size.toInt(), size.toInt(), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint()
        // Outer blue circle
        paint.color = Color.parseColor("#FF4285F4") // Google Maps blue
        paint.style = Paint.Style.FILL
        paint.isAntiAlias = true
        canvas.drawCircle(size / 2, size / 2, size / 2, paint)
        // White inner circle
        paint.color = Color.WHITE
        paint.style = Paint.Style.FILL
        canvas.drawCircle(size / 2, size / 2, size / 4, paint)
        // Semi-transparent blue halo
        paint.color = Color.parseColor("#304285F4")
        paint.style = Paint.Style.FILL
        canvas.drawCircle(size / 2, size / 2, size * 0.75f, paint)
        return bitmap
    }

    override fun getView(): View = mapView

    override fun dispose() {
        Log.d("OlaMapView", "Disposing map view")
        // No onPause or onDestroy, rely on SDK cleanup
    }
}

class OlaPlacesPlugin(private val context: Context) {
    private var placesClient: PlacesClient? = null

    fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initializePlaces" -> {
                val apiKey = call.argument<String>("apiKey") ?: return result.error("INVALID_API_KEY", "API key is missing", null)
                val baseUrl = call.argument<String>("baseUrl") ?: return result.error("INVALID_BASE_URL", "Base URL is missing", null)
                try {
                    val platformConfig = PlatformConfig.Builder()
                        .apiKey(apiKey)
                        .baseUrl(baseUrl)
                        .build()
                    Log.d("OlaPlacesPlugin", "Places initialized with API key: ${apiKey.substring(0, 3)}...")
                    result.success(null)
                } catch (e: Exception) {
                    result.error("PLACES_INIT_ERROR", e.message, null)
                }
            }
            "autocomplete" -> {
                val query = call.argument<String>("query") ?: return result.error("INVALID_QUERY", "Query is missing", null)
                val predictions = listOf(
                    mapOf(
                        "placeId" to "mock_place_${query.hashCode()}",
                        "description" to "Mock Place for $query"
                    )
                )
                result.success(predictions)
            }
            "nearbySearch" -> {
                val location = call.argument<String>("location") ?: return result.error("INVALID_LOCATION", "Location is missing", null)
                val limit = call.argument<Int>("limit") ?: 1
                val mockResults = List(limit) { index ->
                    mapOf(
                        "placeId" to "mock_place_$index",
                        "name" to "Mock Place $index near $location",
                        "formattedAddress" to "Mock Address $index, $location"
                    )
                }
                result.success(mockResults)
            }
            "placeDetails" -> {
                val placeId = call.argument<String>("placeId") ?: return result.error("INVALID_PLACE_ID", "Place ID is missing", null)
                val mockDetails = mapOf(
                    "placeId" to placeId,
                    "name" to "Mock Place for $placeId",
                    "formattedAddress" to "Mock Address for $placeId",
                    "rating" to 4.5
                )
                result.success(mockDetails)
            }
            "textSearch" -> {
                result.error("NOT_SUPPORTED", "textSearch is not supported", null)
            }
            else -> result.notImplemented()
        }
    }
}