import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:signal/providers/live_location_provider.dart';
import 'package:signal/providers/name_provider.dart';
import 'package:signal/providers/signal_algo_provider.dart';
import 'package:text_scroll/text_scroll.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();

    context.read<LiveLocationProvider>().initLocation(context);
    context.read<SignalAlgoProvider>().startApi(context);
    context.read<SignalAlgoProvider>().tickTick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Consumer<LiveLocationProvider>(
              builder: (context, locationProvider, _) => Positioned(
                top: 240,
                height: MediaQuery.of(context).size.height - 240,
                width: MediaQuery.of(context).size.width,
                child: SizedBox.expand(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 15,
                    ),
                    markers: locationProvider.setMarker,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    trafficEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      locationProvider.googleMapController.complete(controller);
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                height: 240,
                width: MediaQuery.of(context).size.width,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: Color(0xFFD6D3D3),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
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
                child: Column(
                  children: [
                    Consumer<NameProvider>(
                      builder: (context, name, _) => Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Center(
                          child: TextScroll(
                            name.name,
                            mode: TextScrollMode.endless,
                            velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
                            delayBefore: const Duration(milliseconds: 1000),
                            pauseBetween: const Duration(milliseconds: 500),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Consumer<SignalAlgoProvider>(
                      builder: (context, algo, _) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: ShapeDecoration(
                              color: !algo.rShow ? Colors.black45 : Colors.red,
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
                                algo.rShow ? '${algo.rForShow}' : '',
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
                              color: !algo.yShow ? Colors.black45 : Colors.yellow,
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
                                algo.yShow ? '${algo.yForShow}' : '',
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
                              color: !algo.gShow ? Colors.black45 : Colors.green,
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
                                algo.gShow ? '${algo.gForShow}' : '',
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
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<LiveLocationProvider>(
                      builder: (context, live, _) => Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Speed: ',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Distance: ',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${live.speed == null ? '0' : (live.speed! * 3.6).toStringAsFixed(0)} KM/H',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${live.dist?.toStringAsFixed(0) ?? '0'} M',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 60,
            width: 60,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Consumer<SignalAlgoProvider>(
                builder: (context, signalAlgoProvider, _) => IconButton(
                  icon: const Icon(
                    Icons.restart_alt_outlined,
                    size: 25,
                    weight: 3,
                  ),
                  onPressed: () {
                    signalAlgoProvider.restartAlgo(context: context);
                  },
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            width: 60,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Consumer<LiveLocationProvider>(
                builder: (context, locationProvider, _) => IconButton(
                  icon: Icon(
                    locationProvider.cameraUpdating
                        ? Icons.location_disabled
                        : Icons.location_searching,
                    size: 25,
                    weight: 3,
                  ),
                  onPressed: () {
                    locationProvider.isCameraUpdating();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
