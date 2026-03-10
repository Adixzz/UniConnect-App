import 'package:flutter/material.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Student Profile",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 65,
              backgroundColor: Colors.blue,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(Icons.person,size:60,color: Colors.black),
              ),
            ),

            const SizedBox(height: 30),

            profileItem(Icons.person,"Student Name","Kavindu Kaushika"),

            profileItem(Icons.badge,"Student Number","ST2023001"),

            profileItem(Icons.email,"Student Email","kavindu@email.com"),

            profileItem(Icons.school,"Faculty","Faculty of Computing"),

          ],
        ),
      ),
    );
  }

  Widget profileItem(IconData icon,String title,String value){

    return Container(
      margin: const EdgeInsets.only(bottom:15),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),

      child: Row(
        children: [

          Icon(icon,color: Colors.blue),

          const SizedBox(width:10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Text(value)

        ],
      ),
    );
  }
}