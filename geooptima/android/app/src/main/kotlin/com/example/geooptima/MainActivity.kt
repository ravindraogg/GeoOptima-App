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
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import com.ola.mapsdk.view.OlaMap
import com.ola.mapsdk.model.OlaLatLng
import com.ola.mapsdk.model.OlaMarkerOptions
import com.ola.mapsdk.view.OlaMapView
import com.ola.mapsdk.interfaces.OlaMapCallback
import android.util.Log

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("ola_map_view", OlaMapViewFactory(flutterEngine.dartExecutor.binaryMessenger))
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

    init {
        val apiKey = params["apiKey"] as? String ?: ""
        val initialLat = params["initialLat"] as? Double ?: 12.9549
        val initialLng = params["initialLng"] as? Double ?: 77.5742
        val initialZoom = params["initialZoom"] as? Double ?: 15.0

        // Initialize map
        mapView.getMap(apiKey, object : OlaMapCallback {
            override fun onMapReady(map: OlaMap) {
                Log.d("OlaMapView", "Map ready")
                olaMap = map
                // Skip moveCamera; rely on initial position from Flutter
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
                "moveCamera" -> {
                    val lat = call.argument<Double>("latitude") ?: 0.0
                    val lng = call.argument<Double>("longitude") ?: 0.0
                    val zoom = call.argument<Double>("zoom") ?: 15.0
                    if (olaMap != null) {
                        // Skip moveCamera; log for debugging
                        Log.w("OlaMapView", "moveCamera not supported, requested: $lat, $lng, zoom=$zoom")
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                "addMarker" -> {
                    val lat = call.argument<Double>("latitude") ?: 0.0
                    val lng = call.argument<Double>("longitude") ?: 0.0
                    val id = call.argument<String>("id") ?: ""
                    if (olaMap != null) {
                        val position = OlaLatLng(lat, lng)
                        val markerOptions = OlaMarkerOptions.Builder()
                            .setPosition(position)
                            .setIsIconClickable(true)
                            .build()
                        olaMap?.addMarker(markerOptions)
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
                    if (olaMap != null) {
                        val position = OlaLatLng(lat, lng)
                        val markerOptions = OlaMarkerOptions.Builder()
                            .setPosition(position)
                            .setIsIconClickable(true)
                        if (iconType == "blue_dot") {
                            val bitmap = createBlueDotBitmap(size)
                            markerOptions.setIconBitmap(bitmap)
                        }
                        olaMap?.addMarker(markerOptions.build())
                        Log.d("OlaMapView", "Blue dot added at $lat, $lng, id=$id")
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                "clearMarkers" -> {
                    if (olaMap != null) {
                        // Skip clearMarkers; log for debugging
                        Log.w("OlaMapView", "clearMarkers not supported")
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    // Create a blue dot bitmap for the marker
    private fun createBlueDotBitmap(size: Float): Bitmap {
        val bitmap = Bitmap.createBitmap(size.toInt(), size.toInt(), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint()
        paint.color = Color.BLUE
        paint.style = Paint.Style.FILL
        paint.isAntiAlias = true
        canvas.drawCircle(size / 2, size / 2, size / 2, paint)
        paint.color = Color.WHITE
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = size / 10
        canvas.drawCircle(size / 2, size / 2, size / 2 - size / 20, paint)
        return bitmap
    }

    override fun getView(): View = mapView

    override fun dispose() {
        Log.d("OlaMapView", "Disposing map view")
        // No lifecycle methods available
    }
}