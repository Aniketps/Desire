import 'dart:math';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desire/penalty.dart';
import 'package:desire/reformation.dart';
import 'package:desire/scrolls.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<_homeState> homeKey = GlobalKey<_homeState>();

class home extends StatefulWidget {
  home({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _homeState();
}

class _homeState extends State<home> {
  String heading = "Loading..."; // Default value for heading

  @override
  void initState() {
    super.initState();
    getHeading();
    savePoint();
    loadTaskCompletion();
    getLegthOfData();
    _startAutoRefresh();
    _startAutoRefreshLocation();
    DaySet();
  }

  String day = "Empty";

  void DaySet() {
    setState(() {
      int today = DateTime.now().weekday; // Get the current day of the week (1 = Monday, ..., 7 = Sunday)
      if (today == 1) {
        day = "1st";
      } else if (today == 2) {
        day = "2nd";
      } else if (today == 3) {
        day = "3rd";
      } else if (today == 4) {
        day = "4th";
      } else if (today == 5) {
        day = "5th";
      } else if (today == 6) {
        day = "2nd last";
      } else if (today == 7) { // Sunday
        day = "Last";
      }
    });
  }


  Future<void> saveTask(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value); // Save a boolean value
  }

  Future<int> getPoints(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0; // Default to 0 if not found
  }

  Future<void> getLegthOfData() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection("Tasks").get();
    setState(() {
      RequiredTotalPonits = (querySnapshot.docs.length * 10) * 5;
    });
  }

  Future<void> loadTaskCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await FirebaseFirestore.instance.collection("Tasks").get();

    setState(() {
      taskCompletion = tasks.docs.map((task) {
        return prefs.getBool(task['Task']) ?? false;
      }).toList();
    });
  }

  bool isLoading = true;
  var currentLat;
  var currentLong;

  Timer? _timer;
  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      getHeading();
      checkAccessLocation(currentLat, currentLong);
    });
  }
  void _startAutoRefreshLocation() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLat = position.latitude;
        currentLong = position.longitude;
      });
      checkAccessLocation(currentLat, currentLong);
    });
  }

  Future<void> getHeading() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("Heading").get();
      if (querySnapshot.docs.isNotEmpty) {
        // Pick a random document from the available ones
        int randomIndex = (querySnapshot.docs.length * (Random()).nextDouble()).toInt();

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          currentLat = position.latitude;
          currentLong = position.longitude;
          isLoading = false;
          heading = querySnapshot.docs[randomIndex]
              ['Title']; // Replace 'Title' with your Firestore field name
        });
      } else {
        setState(() {
          heading = "No data available";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        heading = "Error loading data";
      });
    }
  }

  Future<void> savePoints(String key, int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, points);
  }

  Future<dynamic> getTask(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(key);

    if (value == null) {
      return false; // Return a default value if no data is found
    }

    if (value is bool) {
      return value;
    } else if (value is int) {
      return value;
    } else {
      return false; // Return false for unsupported types
    }
  }

  int RequiredTotalPonits = 0;

  Future<void> savePoint() async {
    List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    DateTime now = DateTime.now();
    String today = weekdays[now.weekday - 1];
    bool isMonday = now.weekday == DateTime.monday;
    bool isNoon = now.hour == 12;

    if (isMonday && isNoon) {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("DailySave").get();
      querySnapshot.docs.first.reference.update({
        'TotalPoints': "0",
        'Day': now.weekday.toString(),
      });
    } else {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("DailySave").get();
      querySnapshot.docs.first.reference.update({
        'TotalPoints': "0",
        'Day': today,
      });
    }
  }

  List<bool> taskCompletion = [];

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
  late StreamSubscription<Position> positionStream;
  LatLng? currentLocation;

  bool isInside = false;

  Future<void> checkAccessLocation(double lat, double long) async {

    var querySnapshot = await FirebaseFirestore.instance.collection("TempAccess").doc("iAsUQEMZs6vxaZuv6IN0").get();
    var newlat = querySnapshot["lat"];
    var newlong = querySnapshot["long"];

    var minLat = double.parse(newlat) - 0.003;
    var minLong = double.parse(newlong) - 0.003;
    var maxLat = double.parse(newlat) + 0.003;
    var maxLong = double.parse(newlong) + 0.003;

    // Check if the point lies within the rectangle
    setState(() {
      if (minLat <= lat && lat <= maxLat && minLong <= long && long <= maxLong) {
        isInside = true;
      } else {
        isInside = false;
      }
    });
  }

  bool isInfo = false;
  String Info = "Empty";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
            child: TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 5),
              builder: (context, value, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10.0,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                );
              },
            ),
          )
          : GestureDetector(
              onTap: () {
                if (isInfo) {
                  setState(() {
                    isInfo =
                        false; // Set isInfo to false only when tapped outside the box while it's open
                  });
                }
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/main.jpg"), // Ensure the image exists in your assets folder
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0x66010018), // Semi-transparent overlay
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Center the content horizontally
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: const EdgeInsets.only(top: 50, right: 55),
                              child: Text(
                                heading,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.itim(
                                  textStyle: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Space between text and container
                            Stack(
                              children: [
                                Center(
                                  child: Container(
                                    height: 470,
                                    width: MediaQuery.of(context).size.width *
                                        0.86,
                                    decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            width: 2,
                                            color: const Color(0x664300fb))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(30.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Todays Goals",
                                                  style: GoogleFonts.itim(
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                FutureBuilder<int>(
                                                  future:
                                                      getPoints('TotalPonits'),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Container(); // Show a loading spinner while waiting
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          'Error: ${snapshot.error}'); // Handle error if there's any
                                                    } else if (snapshot
                                                        .hasData) {
                                                      return Text(
                                                        "${snapshot.data}/$RequiredTotalPonits",
                                                        style: GoogleFonts.itim(
                                                          textStyle: const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return Text(
                                                        "0/$RequiredTotalPonits",
                                                        style: GoogleFonts.itim(
                                                          textStyle: const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              color: Color(0xff9D8AFF),
                                            ),
                                            StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection("Tasks")
                                                  .snapshots(),
                                              builder: (context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot) {
                                                if (snapshot.hasData &&
                                                    !snapshot.hasError) {
                                                  List<DocumentSnapshot> tasks =
                                                      snapshot.data!.docs;
                                                  return Column(
                                                    children: tasks.map((task) {
                                                      int index = tasks.indexOf(
                                                          task); // Get the current index of the task
                                                      return Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Checkbox(
                                                                    value: taskCompletion[index], // This is a preloaded boolean

                                                                    onChanged: isInside? (value) {
                                                                      setState(() {
                                                                        taskCompletion[index] = value!;
                                                                        saveTask(task['Task'], value);
                                                                        if (value) {
                                                                          getPoints("TotalPonits").then((currentPoints) {
                                                                            savePoints("TotalPonits", currentPoints + 10); // Add 10 points
                                                                          });
                                                                        } else {
                                                                          getPoints("TotalPonits").then((currentPoints) {
                                                                            savePoints("TotalPonits", currentPoints - 10); // Subtract 10 points
                                                                          });
                                                                        }
                                                                      });
                                                                    } : null // Disable the checkbox if isInside is false
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        isInfo =
                                                                            true;
                                                                        var data =
                                                                            task.data();
                                                                        if (data is Map<
                                                                            String,
                                                                            dynamic>) {
                                                                          var infoValue =
                                                                              data['Info']; // Safely retrieve 'Info' if 'data' is a Map
                                                                          Info = infoValue != null
                                                                              ? infoValue.toString()
                                                                              : "Not Available"; // Use ternary operator
                                                                        } else {
                                                                          Info =
                                                                              "Not Available"; // Handle cases where data is not a Map
                                                                        }
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                      task['Task']
                                                                          .toString(),
                                                                      style: GoogleFonts
                                                                          .itim(
                                                                        textStyle:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    "+10P",
                                                                    style:
                                                                        GoogleFonts
                                                                            .itim(
                                                                      textStyle:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "+${task['Goal']}",
                                                                    style:
                                                                        GoogleFonts
                                                                            .itim(
                                                                      textStyle:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          const Divider(
                                                            color: Color(
                                                                0xff9D8AFF),
                                                          ),
                                                        ],
                                                      );
                                                    }).toList(),
                                                  );
                                                } else {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }
                                              },
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Penalty",
                                                  style: GoogleFonts.itim(
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "60₹",
                                                  style: GoogleFonts.itim(
                                                    textStyle: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              "$day day of week",
                                              style: GoogleFonts.itim(
                                                textStyle: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                isInfo
                                    ? Center(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 150.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.75,
                                            decoration: BoxDecoration(
                                              color: const Color(0xB3000000),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  width: 2,
                                                  color: const Color(0x664300fb)),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(30.0),
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  Info,
                                                  style: GoogleFonts.itim(
                                                    textStyle: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.86,
                              decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      width: 2, color: const Color(0x664300fb))),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, bottom: 20, left: 30.0, right: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  reformation(),
                                            ));
                                      },
                                      onLongPress: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => penalty(),
                                            ));
                                      },
                                      child: Text(
                                        "Reformation",
                                        style: GoogleFonts.itim(
                                          textStyle: const TextStyle(
                                              color: Color(0xffB098FF)),
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      color: Color(0xff9D8AFF),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => scrolls(),
                                            ));
                                      },
                                      child: Text(
                                        "Scrolls",
                                        style: GoogleFonts.itim(
                                          textStyle: const TextStyle(
                                              color: Color(0xffB098FF)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
