
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';
import 'home.dart';

// Save task data to Firestore
void SaveToCloudDaily() async {
  try {
    print("Hello");
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("Tasks").get();
    print("Hello");

    Map<String, dynamic> scrollsData = {
      "Day": DateFormat('d MMM yyyy').format(DateTime.now()),
    };

    for (var doc in querySnapshot.docs) {
      String taskTitle = doc["Task"];
      int points = (await getTask(taskTitle) && doc["Goal"] is String)
          ? int.parse(doc["Goal"])
          : 0; // Check task completion status
      scrollsData[taskTitle] = points;
      await saveTask(doc["Task"], false);
    }

    // Add the data to a single "Scrolls" document
    await FirebaseFirestore.instance.collection("Scrolls").add(scrollsData);
    print("Data successfully added to 'Scrolls'.");
    Fluttertoast.showToast(msg: "Uploaded");
  } catch (error) {
    print("Failed to save data to Firestore: $error");
  }
}

// Save a boolean task status to SharedPreferences
Future<void> saveTask(String key, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

// Retrieve a task's completion status from SharedPreferences
Future<dynamic> getTask(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.get(key);

  if (value == null) return false; // Default to false if no value found
  return value;
}

// Background task dispatcher
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await Future.delayed(Duration(seconds: 10));

    print("Executing background task: $taskName");
    final now = DateTime.now();
    if (taskName == "Save" && (now.hour == 0 || now.hour == 12)){
      final prefs = await SharedPreferences.getInstance();
      final lastExecutionDate = prefs.getString('lastExecutionDate');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (lastExecutionDate != today) {
        // Execute task only if it hasn't been run today
        print("Running SaveToCloudDaily for $today.");
        SaveToCloudDaily();

        // Update last execution date
        await prefs.setString('lastExecutionDate', today);
      } else {
        print("Task already executed today. Skipping...");
      }
    }else{
      print("Its not time to save");
      print(now.hour);
    }
    await Future.delayed(Duration(seconds: 10));
    return Future.value(true);
  });
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Main entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager().initialize(callbackDispatcher);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Ani',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ani'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Workmanager().registerPeriodicTask(
      "DailySave", // Unique task name
      "Save",      // Task identifier
      frequency: const Duration(minutes: 15), // Minimum periodic duration
      initialDelay: const Duration(seconds: 10), // Delay before the first run
    );
  }

  Future<void> getLiveCoordinates() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showAlertDialog(
        "Location Services Disabled",
        "Location services are required for this app to function properly. Please enable them in your device settings.",
      );
      getLiveCoordinates();
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showAlertDialog(
          "Permission Denied",
          "Location permissions are required to use this feature. Please grant permissions to proceed.",
        );
        getLiveCoordinates();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show a dialog to guide the user to enable permissions in settings
      showAlertDialog(
        "Permission Denied Forever",
        "Location permissions are permanently denied. You need to enable them manually in your device's settings.",
        openSettings: true,
      );
      return;
    }
  }

  void showAlertDialog(String title, String message, {bool openSettings = false}) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (openSettings) {
                  Geolocator.openAppSettings();
                }
              },
              child: Text(openSettings ? "Open Settings" : "OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Lock.jpg"), // Corrected asset path with file extension
            fit: BoxFit.cover, // Ensures the image covers the entire container
          ),
        ),
        child: Center(
          child: Container(
            height: 80,
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Who is your desire?',
                      hintStyle: TextStyle(color: Colors.white), // Text color for the hint
                      fillColor: Color(0xFF330867), // Fill color
                      filled: true, // Enables fill color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50), // Border radius
                        borderSide: BorderSide(color: Colors.white),
                        // Border color
                      ),
                      contentPadding: EdgeInsets.only(left: 25), // Padding from the left for input text
                    ),
                    style: GoogleFonts.itim(
                        textStyle: TextStyle(color: Colors.white),
                    ), // Text color for entered text
                    onChanged: (value) {
                      if(value=="isnam"){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => home(),));
                      }
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Text("In reverse order", style: GoogleFonts.itim(
                  textStyle: TextStyle(color: Color(0xffA392FF), fontSize: 12),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
