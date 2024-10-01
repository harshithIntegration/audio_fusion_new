// first--->megha

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Attendance>> fetchAttendance(String startDate, String endDate) async {
  final response = await http.post(
      Uri.parse('http://13.201.213.5:4080/admin/fetchallattendancebystartandenddate?startingdate=$startDate&enddate=$endDate'));
print(response.body );
  if (response.statusCode == 200) {
    // Parse the JSON
    final data = json.decode(response.body);
    List<dynamic> body = data['body'];
    print(body);
    return body.map((dynamic item) => Attendance.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load attendance');
  }
}

class Attendance {
  final String department;
  final int empCode;
  final String nameOfEmployee;
  final List<DayAndDate> dayAndDate;

  Attendance({
    required this.department,
    required this.empCode,
    required this.nameOfEmployee,
    required this.dayAndDate,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      department: json['department'] ?? '',
      empCode: json['emp_Code'],
      nameOfEmployee: json['name_of_the_Employee'] ?? '',
      dayAndDate: (json['dayAndDate'] as List)
          .map((i) => DayAndDate.fromJson(i))
          .toList(),
    );
  }
}

class DayAndDate {
  final String date;
  final List<AttendanceDetails> attendanceDetails;

  DayAndDate({
    required this.date,
    required this.attendanceDetails,
  });

  factory DayAndDate.fromJson(Map<String, dynamic> json) {
    return DayAndDate(
      date: json['date'],
      attendanceDetails: (json['attendance_Details'] as List)
          .map((i) => AttendanceDetails.fromJson(i))
          .toList(),
    );
  }
}

class AttendanceDetails {
  final String time;
  final String address;

  AttendanceDetails({
    required this.time,
    required this.address,
  });

  factory AttendanceDetails.fromJson(Map<String, dynamic> json) {
    return AttendanceDetails(
      time: json['time'],
      address: json['address'],
    );
  }
}
