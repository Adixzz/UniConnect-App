import 'package:flutter/material.dart';
import 'student_profile.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.blue.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          iconSize: 28,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: "Clubs",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Lectures",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: "Time Table",
            ),

          ],
        ),
      ),

      body: Column(
        children: [

          /// HEADER BAR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                )
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const SizedBox(width: 40),

                const Text(
                  "Welcome to Uniconnect",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentProfile(),
                      ),
                    );
                  },

                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),

                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                  ),
                )

              ],
            ),
          ),

          const SizedBox(height: 25),

          /// BOOK MEETING BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {},

              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0,4),
                    )
                  ],
                ),

                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Icon(Icons.video_call, color: Colors.white),

                      SizedBox(width: 10),

                      Text(
                        "Book a Meeting",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// CURRENT MEETINGS TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Meetings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// MEETING TABLE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListView(
                  children: [

                    meetingRow("Lecture", "Date", "Time", true),

                    meetingRow("Software Engineering", "June 10", "10:00 AM", false),

                    meetingRow("Database Systems", "June 10", "1:30 PM", false),

                    meetingRow("Mobile App Dev", "June 11", "9:00 AM", false),

                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  Widget meetingRow(String lecture, String date, String time, bool header) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
        color: header ? Colors.blue.shade50 : Colors.white,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(
            lecture,
            style: TextStyle(
              fontWeight: header ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          Text(
            date,
            style: TextStyle(
              fontWeight: header ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          Text(
            time,
            style: TextStyle(
              fontWeight: header ? FontWeight.bold : FontWeight.normal,
            ),
          ),

        ],
      ),
    );
  }
}