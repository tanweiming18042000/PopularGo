import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:http/http.dart' as http;
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../constants/global_variables.dart';
import '../../providers/user_provider.dart';
import 'package:crypto/crypto.dart';

class KeyScreen extends StatefulWidget {
  static const String routeName = '/key';
  const KeyScreen({super.key});

  @override
  State<KeyScreen> createState() => _KeyScreenState();
}

class _KeyScreenState extends State<KeyScreen> {
  final AuthService authService = AuthService();
  Position? _currentPosition;
  String apiKey = 'AIzaSyAU4FwZV1M3i483WUrWE_u4b_mu2CSpHvM';
  // rafius is in meter
  String radius = '5000';
  List<dynamic> nearbyPlaces = [];
  String operatingHour = "";
  int randomNum = 0;
  String hashStr = "";
  String duration = '';

  @override
  void initState() {
    super.initState();
    randomNum = generateRandomNumber();
    hashStr =
        "${Provider.of<UserProvider>(context, listen: false).user.id},${randomNum.toString()}";
    generateHashDurationAndContinue();
    _getCurrentPosition();
  }

  // to get the permission
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  // after getting the permission, get the location
  //longitude and latitude
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
      });
      await getNearbyPlaces();
      getOperatingHour();
      // check whether nearbyPlaces is []
      // for loop to get the place_id, get today's Day, post to the API
      // get results['current_opening_hours'][weekday_text]
      // get the text with the Day, then get the substring starting from :,
      // then trim it.
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  // get nearby places
  Future<void> getNearbyPlaces() async {
    if (_currentPosition == null) return;
    // final longitude = _currentPosition?.longitude;
    // final latitude = _currentPosition?.latitude;
    final latitude = 2.2534858;
    final longitude = 102.2803661;

    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=book_store&keyword=Popular Bookstore&opennow=true&key=$apiKey');

    var res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'OK') {
        final List<dynamic> results = data['results'];

        final filteredResults =
            results.where((place) => place['name'].contains('POPULAR'));

        setState(() {
          nearbyPlaces =
              filteredResults.isNotEmpty ? filteredResults.toList() : [];
        });
      } else {
        setState(() {
          nearbyPlaces = [];
        });
      }
    }
  }

  // get the operating hour
  void getOperatingHour() async {
    // check if nearbyPlaces is null or not
    // if it is null, return
    // else, get the place_id, get today's Day, post to the API
    // get the results
    // loop the results['current_opening_hours'][weekday_text]
    // get the text with the Day, then get the substring starting from :,
    // then trim it.
    // then set the global variable as the operating hour string

    if (nearbyPlaces.isEmpty) return;

    final placeId = nearbyPlaces[0]['place_id'];
    print("placeid: $placeId");

    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');

    var res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        final openingHours = result['opening_hours'];

        if (openingHours != null && openingHours['weekday_text'] != null) {
          final weekdayText = openingHours['weekday_text'];
          final currentDay = DateTime.now().weekday - 1;

          if (currentDay >= 0 && currentDay < weekdayText.length) {
            final todayHours = weekdayText[currentDay];
            final startIndex = todayHours.indexOf(':') + 1;
            final trimmedHours = todayHours.substring(startIndex).trim();

            setState(() {
              operatingHour = trimmedHours;
            });
          }
        }
      } else {
        setState(() {
          operatingHour = "";
        });
      }
    }
  }

  // generate random number, bind with user.id, then encrypt to form a String
  // generate random number
  int generateRandomNumber() {
    var random = Random();
    return random.nextInt(9000) + 1000;
  }

  // use SHA-256 hashing
  String generateSHA256Hash(String input) {
    var bytes = utf8.encode(input);
    var shaHash = sha256.convert(bytes);
    return shaHash.toString();
  }

  Future<void> generateHashDurationAndContinue() async {
    // randomNum = generateRandomNumber();
    duration = await getLatestDuration();
    // hashStr =
    //     "${Provider.of<UserProvider>(context, listen: false).user.id},${randomNum.toString()}";
    hashStr = await generateSHA256Hash(hashStr);
    setState(() {});
    createQRKey(hashStr);
  }

  // create or update the qrStr and random num in database (the QRCode is the qrStr)
  // encrypted qrStr (userid + random num)
  void createQRKey(String hashStr) {
    authService.createQRKey(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        qrStr: hashStr);
  }

  // get latest duration (), if the return is '', then text = Welcome to Popular
  // if there is duration,
  Future<String> getLatestDuration() {
    return authService.getLatestDuration(
      context: context,
      user_id: Provider.of<UserProvider>(context, listen: false).user.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.5,
        backgroundColor: GlobalVariables.secondaryColor,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(bottom: getProportionateScreenHeight(20)),
          child: Center(
            child: Container(
                width: getProportionateScreenWidth(200),
                child: Image.asset('assets/popular.png')),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                width: double.infinity,
                height: getProportionateScreenHeight(60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: GlobalVariables.secondaryColor,
                    ),
                    SizedBox(
                        width:
                            5), // Adjust the spacing between the icon and the text
                    Flexible(
                      child: nearbyPlaces.isNotEmpty
                          ? Text(
                              '${nearbyPlaces[0]['name']} | $operatingHour',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              "Welcome to Popular",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ), // Empty container when nearbyPlaces is empty
                    ),
                  ],
                ),
              ),
              // display the qr code and text
              SizedBox(
                height: getProportionateScreenHeight(40),
              ),
              Text(
                'SCAN KEY TO ENTER',
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              QrImage(
                data: hashStr,
                version: QrVersions.auto,
                size: getProportionateScreenHeight(250),
              ),
              SizedBox(
                height: getProportionateScreenHeight(70),
              ),
              Text(
                'Hello, ${Provider.of<UserProvider>(context, listen: false).user.name.split(' ')[0]}',
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(35),
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: getProportionateScreenHeight(30)),
              Text.rich(TextSpan(
                  text: duration != '0'
                      ? 'Your last trip time was '
                      : 'Welcome to ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                  children: <InlineSpan>[
                    if (duration != '0')
                      TextSpan(
                        text: '$duration',
                        style: TextStyle(color: GlobalVariables.secondaryColor),
                      ),
                    if (duration == '0')
                      TextSpan(
                        text: 'Popular',
                        style: TextStyle(color: GlobalVariables.secondaryColor),
                      ),
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
