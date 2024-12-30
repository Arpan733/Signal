import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:signal/providers/signal_algo_provider.dart';

class LiveLocationProvider extends ChangeNotifier {
  final Completer<GoogleMapController> _googleMapController = Completer();
  Completer<GoogleMapController> get googleMapController => _googleMapController;

  Location location = Location();

  LocationData? _currentLocation;
  LocationData? get currentLocation => _currentLocation;

  double? _speed;
  double? get speed => _speed;

  double? _dist;
  double? get dist => _dist;

  Set<Marker> _setMarker = {};
  Set<Marker> get setMarker => _setMarker;

  bool _cameraUpdating = true;
  bool get cameraUpdating => _cameraUpdating;

  isCameraUpdating() {
    _cameraUpdating = !_cameraUpdating;
    ChangeNotifier();
  }

  initLocation(BuildContext context) {
    location.getLocation().then((locationData) {
      _currentLocation = locationData;
      _speed = _currentLocation?.speed;
      _dist = Provider.of<SignalAlgoProvider>(context, listen: false).distance(
          currentLocation?.latitude,
          currentLocation?.longitude,
          Provider.of<SignalAlgoProvider>(context, listen: false).latitude,
          Provider.of<SignalAlgoProvider>(context, listen: false).longitude);

      _dist = (_dist ?? 0) > 600 ? 0 : _dist;
      moveToPosition(
          LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0),
          context);
    });

    location.onLocationChanged.listen((newLocation) {
      if (_currentLocation != newLocation) {
        _currentLocation = newLocation;
        _speed = _currentLocation?.speed;
        _dist = Provider.of<SignalAlgoProvider>(context, listen: false).distance(
            currentLocation?.latitude,
            currentLocation?.longitude,
            Provider.of<SignalAlgoProvider>(context, listen: false).latitude,
            Provider.of<SignalAlgoProvider>(context, listen: false).longitude);

        _dist = (_dist ?? 0) > 600 ? 0 : _dist;
        moveToPosition(
            LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0),
            context);
      }
    });
  }

  moveToPosition(LatLng latLng, BuildContext context) async {
    updateMarker(latLng, context);

    if (_cameraUpdating) {
      final GoogleMapController mapController = await _googleMapController.future;
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 17,
          ),
        ),
      );
    }
  }

  updateMarker(LatLng latLng, BuildContext context) async {
    Map<String, dynamic> currentSignal =
        Provider.of<SignalAlgoProvider>(context, listen: false).currentSignal;

    ByteData data = await rootBundle.load('assets/images/car_icon.png');
    List<int> bytes = data.buffer.asUint8List();
    img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    img.Image resizedImage = img.copyResize(image, width: 150, height: 150);
    Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resizedImage));

    ByteData data1 = await rootBundle.load('assets/images/traffic_light.png');
    List<int> bytes1 = data1.buffer.asUint8List();
    img.Image image1 = img.decodeImage(Uint8List.fromList(bytes1))!;
    img.Image resizedImage1 = img.copyResize(image1, width: 150, height: 150);
    Uint8List resizedBytes1 = Uint8List.fromList(img.encodePng(resizedImage1));

    _setMarker.clear();
    _setMarker.add(Marker(
      markerId: const MarkerId('live_location'),
      position: latLng,
      icon: BitmapDescriptor.fromBytes(resizedBytes),
    ));

    if (currentSignal.isNotEmpty) {
      _setMarker.add(
        Marker(
          markerId: MarkerId("${currentSignal["signalId"]}"),
          position: LatLng(currentSignal["location"]["latitude"],
              currentSignal["location"]["longitude"]),
          icon: BitmapDescriptor.fromBytes(resizedBytes1),
        ),
      );
    }

    notifyListeners();
  }
}
