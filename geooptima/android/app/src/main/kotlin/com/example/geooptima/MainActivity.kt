package com.example.geooptima

import android.content.Context
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

// Fixed the typo `cclass` to `class`
class OlaMapViewPlatform(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    private val params: Map<String, Any>
) : PlatformView {

    private val mapView: OlaMapView = OlaMapView(context)
    private val methodChannel = MethodChannel(messenger, "ola_map_view_$viewId")
    private var olaMap: OlaMap? = null

    init {
        val apiKey = params["apiKey"] as? String ?: ""
        val initialLat = params["initialLat"] as? Double ?: 12.9549
        val initialLng = params["initialLng"] as? Double ?: 77.5742
        val initialZoom = params["initialZoom"] as? Double ?: 15.0

        // TEMP FIX: Commented out until we locate correct initializer class
        // OlaMaps.initialize(context, apiKey)

        mapView.getMap(apiKey, object : OlaMapCallback {
            override fun onMapReady(map: OlaMap) {
                Log.d("OlaMapView", "Map ready")
                olaMap = map

                // TEMP FIX: Commented out due to unresolved reference
                // map.moveCamera(OlaLatLng(initialLat, initialLng), initialZoom.toFloat())

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
                        // TEMP FIX: Commented out due to unresolved method
                        // olaMap?.moveCamera(OlaLatLng(lat, lng), zoom.toFloat())
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                "addMarker" -> {
                    val lat = call.argument<Double>("latitude") ?: 0.0
                    val lng = call.argument<Double>("longitude") ?: 0.0
                    if (olaMap != null) {
                        // Create the OlaMarkerOptions using the Builder
                        val position = OlaLatLng(lat, lng) // Use OlaLatLng to set position
                        
                        val markerOptions = OlaMarkerOptions.Builder()
                            .setPosition(position) // Set position for the marker
                            .setIsIconClickable(true) // Set this property if needed
                            .build() // Finalize the marker options

                        // Add marker to the map
                        olaMap?.addMarker(markerOptions)
                        result.success(null)
                    } else {
                        result.error("MAP_NOT_READY", "Map is not initialized", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun getView(): View = mapView

    override fun dispose() {
        Log.d("OlaMapView", "Disposing map view")
        // mapView.onDestroy()  // Removed: doesn't exist
    }
}
