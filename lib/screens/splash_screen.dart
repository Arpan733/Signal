import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signal/screens/map_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double bgOpacity = 1;
  double otherOpacity = 0.0;
  int currentNumber = 0;

  late var connectivityResult;

  @override
  void initState() {
    super.initState();

    initAsync();
  }

  Future<void> initAsync() async {
    connectivityResult = await Connectivity().checkConnectivity();
    await checkAndRequestPermissions();
  }

  Future<void> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.location] != PermissionStatus.granted ||
        statuses[Permission.locationWhenInUse] != PermissionStatus.granted) {
      await requestLocationPermission();
    } else {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            bgOpacity = 0.2;
          });
        });

        Future.delayed(const Duration(seconds: 2), () {
          otherOpacity = 1;

          printNumber();
        });
      } else {
        print("No internet connection");
      }
    }
  }

  Future<void> requestLocationPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.location] == PermissionStatus.granted &&
        statuses[Permission.locationWhenInUse] == PermissionStatus.granted) {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            bgOpacity = 0.2;
          });
        });

        Future.delayed(const Duration(seconds: 2), () {
          otherOpacity = 1;

          printNumber();
        });
      } else {
        print("No internet connection");
      }
    } else {
      print("Location permissions not granted");
    }
  }

  void navigateToNextPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  void printNumber() {
    if (currentNumber < 100) {
      Future.delayed(
        const Duration(milliseconds: 50),
        () {
          setState(() {
            currentNumber++;
            printNumber();
          });
        },
      );
    } else {
      navigateToNextPage();
    }
  }

  String signalImage() {
    if (currentNumber < 30) {
      return 'assets/logo/r.png';
    } else if (currentNumber < 50) {
      return 'assets/logo/y.png';
    } else if (currentNumber < 70) {
      return 'assets/logo/g.png';
    } else {
      return 'assets/logo/all_g.png';
    }
  }

  Color signalColor() {
    if (currentNumber < 3 + 0) {
      return Colors.red;
    } else if (currentNumber < 50) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  String centerText() {
    if (currentNumber < 33) {
      return 'AT\nANYTIME...';
    } else if (currentNumber < 66) {
      return 'AT\nANYWHERE...';
    } else {
      return 'KNOW\nFAST,\nREACH\nFAST...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: bgOpacity,
            duration: const Duration(seconds: 1),
            child: Image.asset(
              "assets/images/splash_screen_bg.png",
              fit: BoxFit.fitHeight,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width,
            child: AnimatedOpacity(
              opacity: otherOpacity,
              duration: const Duration(seconds: 1),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: signalColor(),
                            spreadRadius: 10,
                            blurRadius: 7,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        signalImage(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Green Road',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: currentNumber > 65
                ? MediaQuery.of(context).size.height * 0.375
                : MediaQuery.of(context).size.height * 0.475,
            child: AnimatedOpacity(
              opacity: otherOpacity,
              duration: const Duration(seconds: 1),
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(
                  centerText(),
                  style: GoogleFonts.abrilFatface(
                    color: Colors.white,
                    fontSize: 55,
                    fontWeight: FontWeight.w400,
                    height: 0,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.width * 0.05,
            child: AnimatedOpacity(
              opacity: otherOpacity,
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  Text(
                    'Loading...   $currentNumber%',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width - 35) *
                                  (currentNumber / 100)),
                          child: Image.asset(
                            'assets/images/car.png',
                            height: 35,
                            width: 35,
                          ),
                        ),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black,
                          margin: const EdgeInsets.only(top: 33),
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
    );
  }
}
