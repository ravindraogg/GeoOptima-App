import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OlaMapView extends StatelessWidget {
  const OlaMapView({
    Key? key,
    this.onMapCreated,
    this.initialCameraPosition,
    required this.apiKey,
  }) : super(key: key);

  final Function(MethodChannel)? onMapCreated;
  final CameraPosition? initialCameraPosition;
  final String apiKey;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'ola_map_view',
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        }.toSet(),
        creationParams: {
          'apiKey': apiKey,
          'initialLat': initialCameraPosition?.target.latitude ?? 12.9549,
          'initialLng': initialCameraPosition?.target.longitude ?? 77.5742,
          'initialZoom': initialCameraPosition?.zoom ?? 15.0,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return const Text('Ola Maps not supported on this platform');
  }

  Future<void> _onPlatformViewCreated(int id) async {
    final methodChannel = MethodChannel('ola_map_view_$id');
    try {
      // Initialize the map with the API key
      await methodChannel.invokeMethod('initializeMap', {'apiKey': apiKey});
      // Notify the caller (if needed)
      onMapCreated?.call(methodChannel);
    } on PlatformException catch (e) {
      debugPrint('Failed to initialize map: ${e.message}');
      // Optionally, propagate the error to the caller
    }
  }
}

class CameraPosition {
  final LatLng target;
  final double zoom;

  CameraPosition({required this.target, this.zoom = 15.0});
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}