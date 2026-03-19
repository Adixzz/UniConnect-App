import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FreeSlotScreen extends StatefulWidget {
  const FreeSlotScreen({super.key});

  @override
  State<FreeSlotScreen> createState() => _FreeSlotScreenState();
}

class _FreeSlotScreenState extends State<FreeSlotScreen> {
  List<Map<String, dynamic>> freeSlots = [];
  List<Map<String, dynamic>> filteredSlots = [];

  bool isLoading = false;
  String? selectedDate;

  final String sheetUrl =
      "https://docs.google.com/spreadsheets/d/1N-8ZbnpqlKt2bsdk4UnBYCKJM6slHK2aHyKNMYaHVQA/export?format=csv";

  // 🔥 Convert "9.00 AM" → DateTime
  DateTime parseTime(String time) {
    final parts = time.split(" ");
    final hm = parts[0].split(".");
    int hour = int.parse(hm[0]);
    int min = int.parse(hm[1]);

    if (parts[1] == "PM" && hour != 12) hour += 12;
    if (parts[1] == "AM" && hour == 12) hour = 0;

    return DateTime(2024, 1, 1, hour, min);
  }

  Future<void> fetchFreeSlots() async {
    setState(() => isLoading = true);

    final response = await http.get(Uri.parse(sheetUrl));

    if (response.statusCode != 200) {
      setState(() => isLoading = false);
      return;
    }

    final data = response.body;

    List<List<String>> sheet = data
        .split("\n")
        .map((row) => row.split(","))
        .toList();

    freeSlots.clear();

    List<String> dates = sheet[0];

    for (int i = 1; i < sheet.length; i++) {
      List<String> row = sheet[i];
      if (row.length < 3) continue;

      String start = row[0].trim();
      String end = row[1].trim();

      for (int j = 2; j < row.length; j++) {
        if (row[j].trim().isEmpty) {
          String date = dates[j].trim();

          freeSlots.add({
            "date": date,
            "start": start,
            "end": end,
            "time": parseTime(start), // for sorting
          });
        }
      }
    }

    // ✅ SORT (Ascending)
    freeSlots.sort((a, b) {
      int dateCompare = a["date"].compareTo(b["date"]);
      if (dateCompare != 0) return dateCompare;
      return a["time"].compareTo(b["time"]);
    });

    filteredSlots = List.from(freeSlots);

    setState(() => isLoading = false);
  }

  // 🔥 FILTER BY DATE
  void filterByDate(String? date) {
    setState(() {
      selectedDate = date;

      if (date == null) {
        filteredSlots = List.from(freeSlots);
      } else {
        filteredSlots = freeSlots
            .where((slot) => slot["date"] == date)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> uniqueDates = freeSlots
        .map((e) => e["date"] as String)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Free Time Slots")),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔍 Fetch Button
          ElevatedButton(
            onPressed: fetchFreeSlots,
            child: const Text("🔍 Find Free Slots"),
          ),

          const SizedBox(height: 10),

          // 📅 FILTER DROPDOWN
          DropdownButton<String>(
            hint: const Text("Filter by Date"),
            value: selectedDate,
            items: uniqueDates.map((date) {
              return DropdownMenuItem(value: date, child: Text(date));
            }).toList(),
            onChanged: filterByDate,
          ),

          const SizedBox(height: 10),

          // 📋 LIST
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredSlots.length,
                    itemBuilder: (context, index) {
                      final slot = filteredSlots[index];

                      return ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          "${slot["date"]} | ${slot["start"]} - ${slot["end"]}",
                        ),
                        subtitle: const Text("FREE"),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
