import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:signal/providers/live_location_provider.dart';
import 'package:signal/providers/name_provider.dart';

import '../services/get_data.dart';

class SignalAlgoProvider extends ChangeNotifier {
  Map<String, dynamic> _currentCircle = {};
  Map<String, dynamic> get currentCircle => _currentCircle;

  Map<String, dynamic> _currentSignal = {};
  Map<String, dynamic> get currentSignal => _currentSignal;

  double _latitude = 0.0;
  double get latitude => _latitude;

  double _longitude = 0.0;
  double get longitude => _longitude;

  List<dynamic> blackCircle = [];
  List<double> prevBlackCircleDistances = [];
  double previousCircleDistance = 10000;

  Timer? algoTimer;
  Timer? timerSignal;
  Timer? realSignal;

  bool _isSignalWorking = true;
  bool get isSignalWorking => _isSignalWorking;

  int r = 0;
  int y = 0;
  int g = 0;

  int _rForShow = 0;
  int get rForShow => _rForShow;
  int _yForShow = 0;
  int get yForShow => _yForShow;
  int _gForShow = 0;
  int get gForShow => _gForShow;

  bool rFromData = false;
  bool yFromData = false;
  bool gFromData = false;

  bool _rShow = false;
  bool get rShow => _rShow;
  bool _yShow = false;
  bool get yShow => _yShow;
  bool _gShow = false;
  bool get gShow => _gShow;

  void restartAlgo({required BuildContext context}) {
    playBeep();

    _isSignalWorking = true;
    r = 0;
    y = 0;
    g = 0;
    _rForShow = 0;
    _yForShow = 0;
    _gForShow = 0;
    rFromData = false;
    yFromData = false;
    gFromData = false;
    _rShow = false;
    _yShow = false;
    _gShow = false;

    _currentCircle = {};
    _currentSignal = {};
    _latitude = 0.0;
    _longitude = 0.0;
    blackCircle = [];
    prevBlackCircleDistances = [];

    algoTimer?.cancel();
    realSignal?.cancel();
    timerSignal?.cancel();

    startApi(context);
  }

  startApi(BuildContext context) async {
    Map<String, dynamic> check = {};
    algoTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      LocationData? currentLocation =
          Provider.of<LiveLocationProvider>(context, listen: false).currentLocation;

      List<dynamic>? circles = await GetSignalCircle.getCirclesByLocation(
        currentLocation?.latitude,
        currentLocation?.longitude,
      );
      // print(circles);

      if (circles != null) {
        if (!checkContains(circles, _currentCircle)) {
          if (blackCircle.isNotEmpty && !checkContains(blackCircle, circles[0])) {
            for (var element in circles) {
              if (!checkContains(blackCircle, element) && blackCircle.isNotEmpty) {
                check = element;
                if (kDebugMode) {
                  // print('new currentCircle ${check.toString()}');
                }
              }
            }
          } else {
            if (circles.isNotEmpty) {
              check = circles[0];
              if (kDebugMode) {
                // print('first currentCircle ${check.toString()}');
              }
            }
          }
        }

        if ((check.isNotEmpty || _currentCircle.isNotEmpty) &&
            !checkContains(blackCircle, check)) {
          double dist = 0;

          if (check.isEmpty) {
            dist = distance(
              currentLocation!.latitude,
              currentLocation.longitude,
              _currentCircle['coordinates']['latitude'],
              _currentCircle['coordinates']['longitude'],
            );
          } else {
            _currentCircle = check;
            dist = distance(
              currentLocation!.latitude,
              currentLocation.longitude,
              _currentCircle['coordinates']['latitude'],
              _currentCircle['coordinates']['longitude'],
            );
          }

          if (dist > 900 && currentLocation.speed! > 0.1) {
            if (kDebugMode) {
              // print('Circle is far');
              // print(check['address']['circleName']);
            }
            previousCircleDistance = 10000;
            check = {};
            _latitude = 0.0;
            _longitude = 0.0;
            _currentCircle = {};
            if (!context.mounted) return;
            Provider.of<NameProvider>(context, listen: false)
                .setName('No Nearby Signal Found');
            _currentSignal = {};
            _isSignalWorking = true;
          } else if (previousCircleDistance < dist && currentLocation.speed! > 0.1) {
            if (kDebugMode) {
              // print(currentCircle['address']['circleName']);
              // print('Circle removed');
            }
            check = {};
            _latitude = 0.0;
            _longitude = 0.0;
            if (!context.mounted) return;
            removeCircle(context);
          } else {
            if (check.isNotEmpty) {
              _currentCircle = check;
            }

            List<dynamic>? signals = await GetSignalCircle.getSignalsByCircle(
                int.parse(_currentCircle['circleId']));

            if (_latitude != check['coordinates']['latitude'] &&
                _longitude != check['coordinates']['longitude']) {
              playBeep();
              _latitude = check['coordinates']['latitude'] ?? 0;
              _longitude = check['coordinates']['longitude'] ?? 0;
            }

            previousCircleDistance = dist;

            // print(signals);

            if (signals != null) {
              List<double> dd = [];

              for (var element in signals) {
                dd.add(distance(
                  currentLocation.latitude,
                  currentLocation.longitude,
                  element['location']['latitude'],
                  element['location']['longitude'],
                ));
              }

              double minDouble = dd[0];
              int cs = 0;

              for (double value in dd) {
                if (value < minDouble) {
                  minDouble = value;
                  cs = dd.indexOf(value);
                }
              }

              if (_currentSignal.isNotEmpty) {
                // print(int.parse(currentSignal['signalId']));
                _currentSignal = await GetSignalCircle.getSignalsById(
                    int.parse(_currentSignal['signalId']));
                // print('signal start');

                if (_currentSignal['signalStatus'] != 'notworking') {
                  if (!context.mounted) return;
                  Provider.of<NameProvider>(context, listen: false)
                      .setName(_currentCircle['address']['circleName']);
                  updateSignal();
                } else {
                  if (!context.mounted) return;
                  Provider.of<NameProvider>(context, listen: false).setName(
                      '${_currentCircle['address']['circleName']} signal is not working');
                }
              } else {
                // print('signal update');
                _currentSignal = signals[cs];

                if (_currentSignal['signalStatus'] != 'notworking') {
                  if (!context.mounted) return;
                  Provider.of<NameProvider>(context, listen: false)
                      .setName(_currentCircle['address']['circleName']);
                  updateSignal();
                } else {
                  if (!context.mounted) return;
                  Provider.of<NameProvider>(context, listen: false).setName(
                      '${_currentCircle['address']['circleName']} signal is not working');
                }
              }
            }

            if (kDebugMode) {
              // print(currentCircle['address']['circleName']);
              // print(previousCircleDistance);
            }
          }
        }
      }
    });
  }

  removeCircle(BuildContext context) {
    LocationData? currentLocation =
        Provider.of<LiveLocationProvider>(context, listen: false).currentLocation;
    playBeep();

    blackCircle.add(_currentCircle);
    prevBlackCircleDistances.add(0);
    previousCircleDistance = 10000;
    _currentCircle = {};
    Provider.of<NameProvider>(context, listen: false).setName('No Nearby Signal Found');
    _currentSignal = {};
    _isSignalWorking = true;
    tickTick();

    Timer? t;

    t = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        for (var element in blackCircle) {
          if (element.toString().isNotEmpty) {
            double dist = distance(
              currentLocation!.latitude,
              currentLocation.longitude,
              element['coordinates']['latitude'],
              element['coordinates']['longitude'],
            );

            // print('black');
            // print(element['address']['circleName']);
            // print(dist);

            if (prevBlackCircleDistances[blackCircle.indexOf(element)] > dist &&
                currentLocation.speed! < 0.1) {
              blackCircle.removeAt(blackCircle.indexOf(element));
              prevBlackCircleDistances.removeAt(blackCircle.indexOf(element));
              t?.cancel();
              removeCircle(context);
            }

            if (dist > 500) {
              t?.cancel();
              blackCircle.removeAt(blackCircle.indexOf(element));
              int indexToRemove = blackCircle.indexOf(element);
              if (indexToRemove != -1) {
                prevBlackCircleDistances.removeAt(indexToRemove);
              }
            }

            prevBlackCircleDistances[blackCircle.indexOf(element)] = dist;
          }
        }
      },
    );
  }

  bool checkContains(List<dynamic> circles, Map<String, dynamic> c) {
    for (var element in circles) {
      if (element.toString() == c.toString()) {
        return true;
      }
    }

    return false;
  }

  double distance(double? startLatitude, double? startLongitude, double endLatitude,
      double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude!, startLongitude!, endLatitude, endLongitude);
  }

  updateSignal() async {
    // print('update Signal');

    rFromData = false;
    yFromData = false;
    gFromData = false;

    _rShow = false;
    _yShow = false;
    _gShow = false;

    _rForShow = 0;
    _yForShow = 0;
    _gForShow = 0;

    r = 0;
    y = 0;
    g = 0;

    timerSignal?.cancel();
    realSignal?.cancel();

    timerSignal = Timer(Duration.zero, () => {});
    realSignal = Timer(Duration.zero, () => {});

    r = _currentSignal["aspects"]["red"];
    y = _currentSignal["aspects"]["yellow"];
    g = _currentSignal["aspects"]["green"];

    if (_currentSignal["aspects"]["currentColor"].toString().toLowerCase() == "red") {
      // print("red");
      rFromData = true;
      red(_currentSignal["aspects"]["durationInSeconds"]);
    } else if (_currentSignal["aspects"]["currentColor"].toString().toLowerCase() ==
        "yellow") {
      // print("yellow");
      yFromData = true;
      yellow(_currentSignal["aspects"]["durationInSeconds"]);
    } else if (_currentSignal["aspects"]["currentColor"].toString().toLowerCase() ==
        "green") {
      // print("green");
      gFromData = true;
      green(_currentSignal["aspects"]["durationInSeconds"]);
    }
  }

  countdown(
      {required int duration,
      required int show,
      required void Function(int) onComplete}) {
    realSignal = Timer.periodic(const Duration(seconds: 1), (timer) {
      rFromData = false;
      yFromData = false;
      gFromData = false;

      if (duration > 1) {
        duration--;
        if (show == 0) {
          _rForShow = duration;
          _rShow = true;
          _yShow = false;
          _gShow = false;
        } else if (show == 1) {
          _gForShow = duration;
          _rShow = false;
          _yShow = false;
          _gShow = true;
        } else if (show == 2) {
          _yForShow = duration;
          _rShow = false;
          _yShow = true;
          _gShow = false;
        }
      } else {
        timer.cancel();
        onComplete(0);
      }

      notifyListeners();
    });
  }

  red(int i) {
    // print('red');
    if (rFromData) {
      // print(1);
      countdown(duration: i, show: 0, onComplete: green);
    } else {
      countdown(duration: r, show: 0, onComplete: green);
    }

    notifyListeners();
  }

  green(int i) {
    // print('green');
    if (gFromData) {
      // print(1);
      countdown(duration: i, show: 1, onComplete: yellow);
    } else {
      countdown(duration: g, show: 1, onComplete: yellow);
    }

    notifyListeners();
  }

  yellow(int i) {
    // print('yellow');
    if (yFromData) {
      // print(1);
      countdown(duration: i, show: 2, onComplete: red);
    } else {
      countdown(duration: y, show: 2, onComplete: red);
    }

    notifyListeners();
  }

  tickTick() {
    rFromData = false;
    yFromData = false;
    gFromData = false;

    _rShow = false;
    _yShow = false;
    _gShow = false;

    _rForShow = 0;
    _yForShow = 0;
    _gForShow = 0;

    r = 0;
    y = 0;
    g = 0;

    realSignal?.cancel();
    timerSignal?.cancel();

    timerSignal = Timer.periodic(const Duration(seconds: 2), (timer) {
      _rShow = !_rShow;
      _yShow = !_yShow;
      _gShow = !_gShow;

      notifyListeners();
    });
  }

  Future<void> playBeep() async {
    AudioPlayer audioPlayer = AudioPlayer();

    await audioPlayer.play(AssetSource('sounds/beep.mp3'));
    await Future.delayed(const Duration(seconds: 1));
    await audioPlayer.stop();
  }
}
