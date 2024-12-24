import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class reformation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _reformation();
}

class _reformation extends State<reformation> {

  bool isLoading = true;
  String SelectedTarget = "Select";
  String SelectedTargetGoal = "0";
  TextEditingController Target = TextEditingController(text: "Select");
  TextEditingController TargetGoal = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    setState(() {
      Target = TextEditingController(text: SelectedTarget); // Initialize here
      TargetGoal = TextEditingController(text: SelectedTargetGoal); // Initialize here
      isLoading = false;
    });
  }
  List<DropdownMenuItem<dynamic>> targetList = [
    DropdownMenuItem(
      value: "Push Ups",
      child: Text("Push Ups"),
    ),
    DropdownMenuItem(
      value: "Squeats",
      child: Text("Stretches"),
    ),
    DropdownMenuItem(
      value: "Sit Ups",
      child: Text("Sit Ups"),
    ),
    DropdownMenuItem(
      value: "Run (Km)",
      child: Text("Run (Km)"),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/main.jpg"), // Ensure the image exists in your assets folder
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0x66010018), // Semi-transparent overlay
                  ),
                  child: Center(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center the content horizontally
                      children: [
                        Container(
                          child: Container(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              "Goal Modifications",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.itim(
                                textStyle: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: 20), // Space between text and container
                        Container(
                          height: 450,
                          width: MediaQuery.of(context).size.width * 0.86,
                          decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  width: 2, color: Color(0x664300fb))),
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align items to the start
                              children: [
                                // Title
                                Text(
                                  "Choose Target",
                                  style: GoogleFonts.itim(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10), // Add spacing

                                // Dropdown Button
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection("Tasks").snapshots(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasData && !snapshot.hasError) {
                                      List<DropdownMenuItem<String>> dropdownItems = snapshot.data!.docs.map((DocumentSnapshot doc) {
                                        String task = doc['Task'];
                                        return DropdownMenuItem<String>(
                                          value: task,
                                          child: Text(task),
                                        );
                                      }).toList();

                                      return DropdownButton<String>(
                                        items: dropdownItems,
                                        hint: Text(
                                          "Select",
                                          style: GoogleFonts.itim(
                                            textStyle: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            SelectedTarget = value!;
                                            Target = TextEditingController(text: value);
                                          });
                                        },
                                        isExpanded: true, // Make dropdown take full width
                                        dropdownColor: Colors.white70, // Dropdown background color
                                        borderRadius: BorderRadius.circular(20),
                                      );
                                    } else {
                                      return Center(child: Text("No data available"));
                                    }
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // First TextField
                                    Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      child: TextField(
                                        controller: Target,
                                        enabled: false,
                                        style: GoogleFonts.itim(
                                          textStyle: TextStyle(color: Colors.white),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: SelectedTarget,
                                          hintStyle: TextStyle(color: Colors.white54),
                                          enabledBorder: UnderlineInputBorder( // Bottom border when not focused
                                            borderSide: BorderSide(color: Color(0xff9D8AFF), width: 1.5),
                                          ),
                                          focusedBorder: UnderlineInputBorder( // Bottom border when focused
                                            borderSide: BorderSide(color: Color(0xff9D8AFF), width: 2.0),
                                          ),
                                          border: UnderlineInputBorder( // Default border
                                            borderSide: BorderSide(color: Color(0xff9D8AFF)),
                                          ),
                                          disabledBorder: UnderlineInputBorder( // Default border
                                            borderSide: BorderSide(color: Color(0xff9D8AFF)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            10), // Spacing between TextFields

                                    // Second TextField
                                    Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      child: TextField(
                                        onChanged: (value) async {
                                          QuerySnapshot querydata = await FirebaseFirestore.instance.collection("Tasks").get();
                                          for (var doc in querydata.docs) {
                                            String target = doc['Task']; // Assuming 'Target' is the field name
                                            if (target == SelectedTarget) {
                                              doc.reference.update({
                                                "Goal": value.toString(),
                                              });
                                              Fluttertoast.showToast(msg: "Updated");
                                              break; // Exit loop if a match is found
                                            }
                                          }
                                        },
                                        controller: TargetGoal,
                                        keyboardType: TextInputType.numberWithOptions(),
                                        textAlign: TextAlign.start, // Aligns text to the right
                                        style: GoogleFonts.itim(
                                          textStyle: TextStyle(color: Colors.white),
                                        ),
                                        decoration: InputDecoration(
                                          prefixText: "+",
                                          hintText: SelectedTargetGoal,
                                          hintStyle: TextStyle(color: Colors.white54),
                                          enabledBorder: UnderlineInputBorder( // Bottom border when not focused
                                            borderSide: BorderSide(color: Color(0xff9D8AFF), width: 1.5),
                                          ),
                                          focusedBorder: UnderlineInputBorder( // Bottom border when focused
                                            borderSide: BorderSide(color: Color(0xff9D8AFF), width: 2.0),
                                          ),
                                          border: UnderlineInputBorder( // Default border
                                            borderSide: BorderSide(color: Color(0xff9D8AFF)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10), // Add spacing

                                // Inspirational Quote
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "I'll become strong enough to protect everything important to me, "
                                    "even if it means making enemies of everyone in the world.",
                                    style: GoogleFonts.itim(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
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
    );
  }
}
