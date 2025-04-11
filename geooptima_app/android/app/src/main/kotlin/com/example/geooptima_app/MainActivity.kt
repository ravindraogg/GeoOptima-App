package com.example.geooptimaapp

import android.content.Context
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import com.ola.mapsdk.views.OlaMapView
import com.ola.mapsdk.OlaMap
import com.ola.mapsdk.interfaces.OlaMapCallback
import com.ola.mapsdk.models.OlaLatLng
import com.ola.mapsdk.models.OlaMarkerOptions

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("ola_map_view", OlaMapViewFactory(flutterEngine.dartExecutor.binaryMessenger))
    }
}

class OlaMapViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec()) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as Map<String, Any>
        return OlaMapViewPlatform(context, viewId, messenger, params)
    }
}

class OlaMapViewPlatform(
    private val context: Context,
    private val viewId: Int,
    messenger: BinaryMessenger,
    private val params: Map<String, Any>
) : PlatformView {
    private val olaMapView = OlaMapView(context)
    private val methodChannel = MethodChannel(messenger, "ola_map_view_$viewId")
    private var olaMap: OlaMap? = null

    init {
        val apiKey = params["apiKey"] as? String ?: ""
        val initialLat = params["initialLat"] as? Double ?: 12.9549
        val initialLng = params["initialLng"] as? Double ?: 77.5742
        val initialZoom = params["initialZoom"] as? Double ?: 15.0

        olaMapView.getMap(apiKey, object : OlaMapCallback {
            override fun onMapReady(map: OlaMap) {
                olaMap = map
                map.moveCamera(OlaLatLng(initialLat, initialLng), initialZoom.toFloat())
                setupMethodChannel()
            }

            override fun onMapError(error: String) {
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
                    olaMap?.moveCamera(OlaLatLng(lat, lng), zoom.toFloat())
                    result.success(null)
                }
                "addMarker" -> {
                    val lat = call.argument<Double>("latitude") ?: 0.0
                    val lng = call.argument<Double>("longitude") ?: 0.0
                    val id = call.argument<String>("id") ?: "marker"
                    val markerOptions = OlaMarkerOptions()
                        .setMarkerId(id)
                        .setPosition(OlaLatLng(lat, lng))
                        .setIsIconClickable(true)
                    olaMap?.addMarker(markerOptions)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun getView(): View = olaMapView

    override fun dispose() {
        olaMapView.onDestroy()
    }
}
