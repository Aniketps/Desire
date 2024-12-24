import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class scrolls extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _scrolls();
}

class _scrolls extends State<scrolls> {
  bool isLoading = true;
  List<String> Tasknames = [];
  @override
  void initState() {
    super.initState();
    getAllTasks();
  }
  Future<void> getAllTasks() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("Tasks").get();
    for(var doc in querySnapshot.docs){
      Tasknames.add(doc['Task'].toString());
    }
    setState(() {
      isLoading = false;
    });
  }
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
                        "Scrolls",
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
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("Scrolls").snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("Error: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("No data found."));
                          }

                          List<DocumentSnapshot> scrolls = snapshot.data!.docs;

                          return Column(
                            children: scrolls.map((scroll) {
                              final data = scroll.data() as Map<String, dynamic>?; // Safely cast document data
                              if (data == null) return SizedBox.shrink(); // Skip if data is null

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                height: 300,
                                width: MediaQuery.of(context).size.width * 0.86,
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(width: 2, color: Color(0x664300fb)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        data['Day'] ?? "No Day Found", // Safely access the 'Day' field
                                        style: GoogleFonts.itim(
                                          textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            children: [
                                              ...Tasknames.map((task) {
                                                return Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          task.toString(),
                                                          style: GoogleFonts.itim(
                                                            textStyle: TextStyle(color: Colors.white, fontSize: 16),
                                                          ),
                                                        ),
                                                        Text(
                                                          "+" + (data[task]?.toString() ?? 'No Data'),
                                                          style: GoogleFonts.itim(
                                                            textStyle: TextStyle(color: Colors.white, fontSize: 15),
                                                          ),
                                                        ), // Safely access task values
                                                      ],
                                                    ),
                                                    Divider(color: Color(0x664300fb)),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
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