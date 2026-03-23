import 'package:http/http.dart' as http;
import 'dart:convert';

class SheetsService {
  String _toCsvUrl(String sheetUrl) {
    // extract the sheet ID from the URL
    final uri = Uri.parse(sheetUrl);
    final pathSegments = uri.pathSegments;
    final sheetId = pathSegments[pathSegments.indexOf('d') + 1];
    return 'https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv';
  }

  Future<List<List<String>>> fetchTimetable(String sheetUrl) async {
    try {
      final csvUrl = _toCsvUrl(sheetUrl);
      final response = await http.get(Uri.parse(csvUrl));

      if (response.statusCode == 200) {
        final lines = const LineSplitter().convert(response.body);
        return lines.map((line) => line.split(',')).toList();
      } else {
        throw Exception("Failed to fetch sheet: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching timetable: $e");
    }
  }
}