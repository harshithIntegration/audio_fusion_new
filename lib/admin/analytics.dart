// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AttendanceAnalytics {
//   Future<Map<String, int>> getAttendanceAnalytics(
//     String employeeId, int month, int year) async {
    
//     // print("Employee ID: $employeeId");
//     // print("Month: $month");
//     // print("Year: $year");

//     final startDate = DateTime(year, month, 1);
//     final currentDate = DateTime.now();

//     // We'll stop counting days after today's date
//     final lastDay = (month == currentDate.month && year == currentDate.year)
//         ? currentDate.day
//         : DateTime(year, month + 1, 0).day; // Last day of the month or today

//     try {
//       final responseAttendance = await http.post(
//         Uri.parse(
//           'http://13.201.213.5:4040/admin/fetchallattendancebystartandenddate?startingdate=${startDate.day}-${startDate.month}-${startDate.year}&enddate=$lastDay-$month-$year',
//         ),
//       );

//       if (responseAttendance.statusCode == 200) {
//         final Map<String, dynamic> attendanceData = json.decode(responseAttendance.body);
//         final body = attendanceData['body'];

//         if (body != null && body is List) {
//           // Iterating through body and printing fields, replacing null values with "N/A"
//           for (var item in body) {
//             if (item == null) {
//               print('N/A');
//             } else {
//               print(item);
//             }
//           }

//           int presentCount = 0;
//           int absentCount = 0;
//           int lateCount = 0;

//           // Track days with attendance records
//           List<DateTime> attendedDays = [];

//           // Process attendance for the specific employee
//           for (var employee in body) {
//             if (employee['emp_Code']?.toString() == employeeId) {
//               final dayAndDate = employee['dayAndDate'];
//               if (dayAndDate != null && dayAndDate is List) {
//                 for (var dayEntry in dayAndDate) {
//                   final date = dayEntry['date'];
//                   final attendance = (dayEntry['attendance'] ?? '').toLowerCase();
//                   final attendanceDetails = dayEntry['attendance_Details'] ?? [];

//                   if (date != null) {
//                     final dateObj = DateTime.parse(
//                         "${date.split('-')[2]}-${date.split('-')[1]}-${date.split('-')[0]}");

//                     // Track attended days
//                     attendedDays.add(dateObj);

//                     if (dateObj.month == month && dateObj.year == year) {
//                       if (attendance == 'absent') {
//                         absentCount++;
//                       } else {
//                         bool firstPunchInIsLate = false;

//                         for (var i = 0; i < attendanceDetails.length; i++) {
//                           var detail = attendanceDetails[i];
//                           if (detail['attendance_status'] != null &&
//                               detail['attendance_status']
//                                   .toLowerCase()
//                                   .contains('punch in')) {
//                             final punchInTime = parseTime(date, detail['time']);

//                             // Only consider the first punch-in status
//                             if (i == 0) {
//                               firstPunchInIsLate =
//                                   getInStatus(punchInTime) == 'Late';
//                             }

//                             if (getInStatus(punchInTime) == 'Late') {
//                               // Late punch-in logic
//                             }
//                           }
//                         }
//                         if (firstPunchInIsLate) {
//                           lateCount++;
//                         }
//                         presentCount++;
//                       }
//                     }
//                   }
//                 }
//               }
//             }
//           }

//           // Calculate absent days excluding Sundays without attendance
//           for (int day = 1; day <= lastDay; day++) {
//             final currentDay = DateTime(year, month, day);

//             // If it's not attended and not a Sunday, or it's a Sunday without attendance
//             if (!attendedDays.any((d) => d.day == currentDay.day)) {
//               // Only count non-Sundays as absent or Sundays without attendance
//               if (currentDay.weekday != DateTime.sunday) {
//                 absentCount++;
//               }
//             }
//           }

//           // Return the computed values for present (including late), absent, and late counts
//           return {
//             'Present': presentCount, // Present count includes late as well
//             'Absent': absentCount, // Excludes Sundays without attendance
//             'Late': lateCount, // Separate late count
//           };
//         } else {
//           print("Attendance Data Body: N/A");
//           return {'Present': 0, 'Absent': 0, 'Late': 0};
//         }
//       } else {
//         print(
//             'Failed to load attendance data. Status Code: ${responseAttendance.statusCode}');
//         return {'Present': 0, 'Absent': 0, 'Late': 0};
//       }
//     } catch (e) {
//       print("Error fetching analytics: $e");
//       return {'Present': 0, 'Absent': 0, 'Late': 0};
//     }
//   }

//   // Function to parse time string (AM/PM) into a DateTime object
//   DateTime parseTime(String date, String? time) {
//     try {
//       if (time == null || time.isEmpty) {
//         throw FormatException('Invalid time: $time');
//       }

//       // Remove any extra spaces and handle cases with or without spaces between time and AM/PM
//       time = time.trim().replaceAll(RegExp(r'\s+'), ' '); // Normalize the spaces

//       // Use regex to capture the time and the AM/PM portion separately
//       final timeParts =
//           RegExp(r'(\d{1,2}:\d{2})\s?(AM|PM)', caseSensitive: false)
//               .firstMatch(time);

//       if (timeParts == null || timeParts.groupCount < 2) {
//         throw FormatException('Invalid time format: $time');
//       }

//       final hourMinute = timeParts.group(1)!.split(':');
//       final hour = int.parse(hourMinute[0]);
//       final minute = int.parse(hourMinute[1]);
//       final timeOfDay = timeParts.group(2)!.toUpperCase();
//       final isAM = timeOfDay == 'AM';

//       return DateTime(
//         int.parse(date.split('-')[2]),
//         int.parse(date.split('-')[1]),
//         int.parse(date.split('-')[0]),
//         hour == 12 ? (isAM ? 0 : 12) : (isAM ? hour : hour + 12),
//         minute,
//       );
//     } catch (e) {
//       throw FormatException('Error parsing time: $e');
//     }
//   }

//   // Function to determine if the punch-in time is late or on time
//   String getInStatus(DateTime dateTime) {
//     final hour = dateTime.hour;
//     final minute = dateTime.minute;

//     if (hour < 9 || (hour == 9 && minute <= 45)) {
//       return 'Present';
//     } else {
//       return 'Late';
//     }
//   }
// }

// // Example call to the function
// Future<Function?> pp() async {
//   final attendanceAnalytics = AttendanceAnalytics();

//   final result = await attendanceAnalytics.getAttendanceAnalytics('72', 9, 2024);

//   print('Present: ${result['Present']}');
//   print('Absent: ${result['Absent']}');
//   print('Late: ${result['Late']}');
//   return null;
// }








import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceAnalytics {
  Future<Map<String, int>> getAttendanceAnalytics(
      String employeeId, int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final currentDate = DateTime.now();
    final lastDay = (month == currentDate.month && year == currentDate.year)
        ? currentDate.day
        : DateTime(year, month + 1, 0).day;

    try {
      final responseAttendance = await http.post(Uri.parse(
          'http://13.201.213.5:4080/admin/fetchallattendancebystartandenddate?startingdate=${startDate.day}-${startDate.month}-${startDate.year}&enddate=$lastDay-$month-$year'));

      if (responseAttendance.statusCode == 200) {
        final Map<String, dynamic> attendanceData =
            json.decode(responseAttendance.body);
        final body = attendanceData['body'];

        if (body == null || body is! List) {
          return {'Present': 0, 'Absent': 0, 'Late': 0};
        }

        int presentCount = 0;
        int absentCount = 0;
        int lateCount = 0;

        // Track days with attendance records
        List<DateTime> attendedDays = [];

        // Process attendance for the specific employee
        for (var employee in body) {
          if (employee['emp_Code'].toString() == employeeId) {
            final dayAndDate = employee['dayAndDate'];
            if (dayAndDate != null && dayAndDate is List) {
              for (var dayEntry in dayAndDate) {
                final date = dayEntry['date'];
                final attendance = (dayEntry['attendance'] ?? '').toLowerCase();
                final attendanceDetails = dayEntry['attendance_Details'] ?? [];

                final dateObj = DateTime.parse(
                    "${date.split('-')[2]}-${date.split('-')[1]}-${date.split('-')[0]}");

                // Track attended days
                attendedDays.add(dateObj);

                if (dateObj.month == month && dateObj.year == year) {
                  if (attendance == 'absent') {
                    // Exclude Sundays from absent count
                    if (dateObj.weekday != DateTime.sunday) {
                      absentCount++;
                    }
                  } else {
                    bool firstPunchInIsLate = false;

                    for (var i = 0; i < attendanceDetails.length; i++) {
                      var detail = attendanceDetails[i];
                      if (detail['attendance_status'] != null &&
                          detail['attendance_status']
                              .toLowerCase()
                              .contains('punch in')) {
                        final punchInTime = parseTime(date, detail['time']);

                        // Only consider the first punch-in status
                        if (i == 0) {
                          firstPunchInIsLate =
                              getInStatus(punchInTime) == 'Late';
                        }
                      }
                    }

                    // Increment present count for all valid punch-ins, including late
                    presentCount++;
                    if (firstPunchInIsLate) {
                      lateCount++;
                    }
                  }
                }
              }
            }
          }
        }

        // Calculate absent days excluding Sundays without attendance
        for (int day = 1; day <= lastDay; day++) {
          final currentDay = DateTime(year, month, day);
          if (!attendedDays.any((d) => d.day == currentDay.day)) {
            // Count as absent only if it's not a Sunday
            if (currentDay.weekday != DateTime.sunday) {
              absentCount++;
            }
          }
        }

        // Return the computed values for present (including late), absent, and late counts
        return {
          'Present': presentCount, // Includes late as well
          'Absent': absentCount, // Excludes Sundays
          'Late': lateCount, // Separate late count
        };
      } else {
        print(
            'Failed to load attendance data. Status Code: ${responseAttendance.statusCode}');
        return {'Present': 0, 'Absent': 0, 'Late': 0};
      }
    } catch (e) {
      print("Error fetching analytics: $e");
      return {'Present': 0, 'Absent': 0, 'Late': 0};
    }
  }

  DateTime parseTime(String date, String time) {
    try {
      time = time.trim().replaceAll(RegExp(r'\s+'), ' ');
      final timeParts =
          RegExp(r'(\d{1,2}:\d{2})\s?(AM|PM)', caseSensitive: false)
              .firstMatch(time);

      if (timeParts == null || timeParts.groupCount < 2) {
        throw FormatException('Invalid time format: $time');
      }

      final hourMinute = timeParts.group(1)!.split(':');
      final hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      final timeOfDay = timeParts.group(2)!.toUpperCase();
      final isAM = timeOfDay == 'AM';

      return DateTime(
        int.parse(date.split('-')[2]),
        int.parse(date.split('-')[1]),
        int.parse(date.split('-')[0]),
        hour == 12 ? (isAM ? 0 : 12) : (isAM ? hour : hour + 12),
        minute,
      );
    } catch (e) {
      throw FormatException('Error parsing time: $e');
    }
  }

  String getInStatus(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    if (hour < 9 || (hour == 9 && minute <= 45)) {
      return 'Present';
    } else {
      return 'Late';
    }
  }
}

// Example call to the function
Future<void> main() async {
  final attendanceAnalytics = AttendanceAnalytics();
  final result = await attendanceAnalytics.getAttendanceAnalytics('72', 9, 2024);

  print('Present: ${result['Present']}');
  print('Absent: ${result['Absent']}');
  print('Late: ${result['Late']}');
}
