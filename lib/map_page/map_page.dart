import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:signal/map_page/get_signal_data.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double opacityOfSignal = 1.0;

  Completer<GoogleMapController> googleMapController = Completer();
  late GoogleMapController mapController;

  Location location = Location();

  late CameraPosition cameraPosition;
  LocationData? currentLocation;
  Set<Marker> setMarker = {};
  Set<Marker> setMarkerOfMainSignals = {};
  Set<Marker> setMarkerOfSignals = {};

  bool showSignals = false;
  bool showLights = false;
  bool showSignal = false;

  Timer? timerSignal;
  Timer? realSignal;

  String circleName = '';

  List<dynamic>? circles;
  List<dynamic>? signals;
  Map<String, dynamic>? circle;
  Map<String, dynamic>? signal;

  String signalId = '';

  int r = 0;
  int y = 0;
  int g = 0;

  int rForShow = 0;
  int yForShow = 0;
  int gForShow = 0;

  bool rFromData = false;
  bool yFromData = false;
  bool gFromData = false;

  bool rShow = false;
  bool yShow = false;
  bool gShow = false;

  late Timer timer;

  bool cameraUpdating = true;

  @override
  void initState() {
    super.initState();
    cameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 15,
    );

    getCircle();

    initLocation();
    updateSignal();
  }

  getCircle() async {
    await GetSignalData.getAllCircles();
    circles = GetSignalData.circles;
  }

  initLocation() {
    location.getLocation().then((location) {
      currentLocation = location;
      moveToPosition(LatLng(
          currentLocation?.latitude ?? 0, currentLocation?.longitude ?? 0));
    });

    location.onLocationChanged.listen((newLocation) {
      currentLocation = newLocation;
      moveToPosition(LatLng(
          currentLocation?.latitude ?? 0, currentLocation?.longitude ?? 0));
    });
  }

  moveToPosition(LatLng latLng) async {
    updateMarker(latLng);

    if (cameraUpdating) {
      GoogleMapController mapController = await googleMapController.future;
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

  Future<LocationData>? getCurrentLocation() {
    var currentLocation = location.getLocation();
    return currentLocation;
  }

  updateMarker(LatLng latLng) async {
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

    ByteData data2 = await rootBundle.load('assets/images/crossroad.png');
    List<int> bytes2 = data2.buffer.asUint8List();
    img.Image image2 = img.decodeImage(Uint8List.fromList(bytes2))!;
    img.Image resizedImage2 = img.copyResize(image2, width: 150, height: 150);
    Uint8List resizedBytes2 = Uint8List.fromList(img.encodePng(resizedImage2));

    // BitmapDescriptor customMarker = await BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(
    //     devicePixelRatio: 2.5,
    //   ),
    //   'assets/images/car_icon.png',
    // );
    //
    // BitmapDescriptor customSignalMarker = await BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(
    //     devicePixelRatio: 2.5,
    //   ),
    //   'assets/images/traffic_light.png',
    // );

    setState(() {
      setMarker.clear();
      setMarker.add(Marker(
        markerId: const MarkerId('live_location'),
        position: latLng,
        icon: BitmapDescriptor.fromBytes(resizedBytes),
      ));

      if (showSignals) {
        if (signals!.isEmpty) {
          showSignals = false;
        } else {
          setState(() {
            circleName = signals?[0]["address"]["circleName"];
          });

          signals?.forEach((element) {
            setMarkerOfSignals.add(
              Marker(
                markerId: MarkerId("${element["signalId"]}"),
                position: LatLng(element["location"]["latitude"],
                    element["location"]["longitude"]),
                icon: BitmapDescriptor.fromBytes(resizedBytes1),
                onTap: () async {
                  if (signalId == element["signalId"]) {
                    await GetSignalData.getSignalById(signalId);
                    signal = GetSignalData.signal;
                    // print("Hemlo: $signal");

                    setState(() {
                      showSignal = false;
                      showSignals = true;
                      updateSignal();
                    });
                  } else {
                    setState(() {
                      showSignal = false;
                      showSignals = true;
                      signal = element;
                      // print("element: $signal");

                      signalId = element["signalId"];
                      // print("signalId: $signalId");

                      showLights = true;
                    });

                    await GetSignalData.getSignalByCircle(element["circleId"]);
                    signals = GetSignalData.signals;

                    updateSignal();
                  }
                },
              ),
            );
          });

          setMarker.addAll(setMarkerOfSignals);
        }
      } else {
        if (circles == null) {
          getCircle();
        }

        setMarkerOfMainSignals.clear();
        setMarkerOfSignals.clear();

        circles?.forEach((element) {
          setMarkerOfMainSignals.add(
            Marker(
              markerId: MarkerId(element["circleId"] ?? ''),
              position: LatLng(element["coordinates"]["latitude"],
                  element["coordinates"]["longitude"]),
              icon: BitmapDescriptor.fromBytes(resizedBytes2),
              onTap: () async {
                circle = await element;
                setMarkerOfSignals.clear();

                await GetSignalData.getSignalByCircle(element["circleId"]);
                signals = GetSignalData.signals;

                setState(() {
                  signalId = '';
                  showSignals = true;
                  showSignal = true;
                });

                updateMarker(latLng);
              },
            ),
          );
        });

        setMarker.addAll(setMarkerOfMainSignals);
      }
    });
  }

  updateSignal() async {
    rShow = false;
    yShow = false;
    gShow = false;

    rForShow = 0;
    yForShow = 0;
    gForShow = 0;

    timerSignal?.cancel();
    realSignal?.cancel();

    timerSignal = Timer(Duration.zero, () => {});
    realSignal = Timer(Duration.zero, () => {});

    if (showLights) {
      print("Signal Aspects: ${signal?["aspects"]}");

      if (signal == null) {
        await GetSignalData.getSignalById(signalId);
        signal = GetSignalData.signal;

        updateSignal();

        // setState(() {
        //   showSignals = false;
        //   showLights = false;
        // });
        // print("Hello");
      } else {
        // print("Hello1");
        r = signal?["aspects"]["red"];
        y = signal?["aspects"]["yellow"];
        g = signal?["aspects"]["green"];

        // print(r);
        // print(y);
        // print(g);

        if (signal?["aspects"]["currentColor"].toString().toLowerCase() ==
            "red") {
          // print("red");
          rFromData = true;
          red(signal?["aspects"]["durationInSeconds"]);
        } else if (signal?["aspects"]["currentColor"]
                .toString()
                .toLowerCase() ==
            "yellow") {
          // print("yellow");
          yFromData = true;
          yellow(signal?["aspects"]["durationInSeconds"]);
        } else if (signal?["aspects"]["currentColor"]
                .toString()
                .toLowerCase() ==
            "green") {
          // print("green");
          gFromData = true;
          green(signal?["aspects"]["durationInSeconds"]);
        } else {
          print("Hello");
          setState(() {
            showLights = false;
          });
        }
      }
    } else {
      tickTick();
    }
  }

  tickTick() {
    rShow = false;
    yShow = false;
    gShow = false;

    rForShow = 0;
    yForShow = 0;
    gForShow = 0;

    r = 0;
    y = 0;
    g = 0;

    timerSignal = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        rShow = !rShow;
        yShow = !yShow;
        gShow = !gShow;
      });
    });
  }

  countdown(int duration, int show, void Function(int) onComplete) {
    realSignal = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        rFromData = false;
        yFromData = false;
        gFromData = false;

        if (duration > 0) {
          duration--;
          if (show == 0) {
            rForShow = duration;
            rShow = true;
            yShow = false;
            gShow = false;
          } else if (show == 1) {
            gForShow = duration;
            rShow = false;
            yShow = false;
            gShow = true;
          } else if (show == 2) {
            yForShow = duration;
            rShow = false;
            yShow = true;
            gShow = false;
          }
        } else {
          timer.cancel();
          // print('Abcde');
          onComplete(0);
        }
      });
    });
  }

  red(int i) {
    // print('red');
    setState(() {
      if (rFromData) {
        // print(1);
        countdown(i, 0, yellow);
      } else {
        countdown(r, 0, yellow);
      }
    });
  }

  green(int i) {
    // print('green');
    setState(() {
      if (gFromData) {
        // print(1);
        countdown(i, 1, red);
      } else {
        countdown(g, 1, red);
      }
    });
  }

  yellow(int i) {
    // print('yellow');
    setState(() {
      if (yFromData) {
        // print(1);
        countdown(i, 2, green);
      } else {
        countdown(y, 2, green);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: showSignals ? 170 : 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: MediaQuery.of(context).size.width,
                height: showSignals
                    ? MediaQuery.of(context).size.height - 170
                    : MediaQuery.of(context).size.height,
                child: SizedBox.expand(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: cameraPosition,
                    markers: setMarker,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    trafficEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController.complete(controller);
                      // if (!googleMapController.isCompleted) {
                      // }
                    },
                    onTap: (latLng) {
                      setState(() {
                        showSignals = false;
                        showLights = false;
                        showSignal = false;

                        updateSignal();

                        signalId = '';
                        setMarkerOfSignals.clear();
                        circleName = '';
                      });

                      // getCircle();
                      // GetSignalData.getSignalByCircle("1");
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: AnimatedOpacity(
                opacity: showSignals ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Color(0xFFD6D3D3),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(19),
                        bottomRight: Radius.circular(19),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                        spreadRadius: 7,
                      ),
                    ],
                  ),
                  child: showSignal
                      ? Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Center(
                                child: Text(
                                  circleName,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "${circle!["address"]["road"].toString()},",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "${circle!["address"]["area"].toString()}, ${circle!["address"]["city"].toString()} - ${circle!["address"]["pincode"].toString()}",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "No. of signals: ${circle!["numberOfSignals"].toString()}",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 0,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Center(
                                child: Text(
                                  circleName == ''
                                      ? 'Signal can\'t detect'
                                      : circleName,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: ShapeDecoration(
                                    color: !rShow ? Colors.black45 : Colors.red,
                                    shape: const OvalBorder(),
                                    shadows: const [
                                      BoxShadow(
                                        color: Colors.red,
                                        blurRadius: 5,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      rShow ? '$rForShow' : '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: ShapeDecoration(
                                    color:
                                        !yShow ? Colors.black45 : Colors.yellow,
                                    shape: const OvalBorder(),
                                    shadows: const [
                                      BoxShadow(
                                        color: Colors.yellow,
                                        blurRadius: 5,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      yShow ? '$yForShow' : '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: ShapeDecoration(
                                    color:
                                        !gShow ? Colors.black45 : Colors.green,
                                    shape: const OvalBorder(),
                                    shadows: const [
                                      BoxShadow(
                                        color: Colors.green,
                                        blurRadius: 5,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      gShow ? '$gForShow' : '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: IconButton(
            icon: Icon(
              cameraUpdating
                  ? Icons.location_disabled
                  : Icons.location_searching,
              size: 25,
              weight: 3,
            ),
            onPressed: () {
              cameraUpdating = !cameraUpdating;
            },
          ),
        ),
      ),
    );
  }
}
