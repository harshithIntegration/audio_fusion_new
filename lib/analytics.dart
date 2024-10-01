import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceAnalytics {
  Future<Map<String, int>> getAttendanceAnalytics(
      String employeeId, int month, int year) async {
    print("Employee ID: $employeeId");
    print("Month: $month");
    print("Year: $year");

    final startDate = DateTime(year, month, 1);
    final currentDate = DateTime.now(); // Today's date

    // We'll stop counting days after today's date
    final lastDay = (month == currentDate.month && year == currentDate.year)
        ? currentDate.day
        : DateTime(year, month + 1, 0).day; // Last day of the month or today

    try {
      final responseAttendance = await http.post(Uri.parse(
          'http://13.201.213.5:4040/admin/fetchallattendancebystartandenddate?startingdate=${startDate.day}-${startDate.month}-${startDate.year}&enddate=$lastDay-$month-$year'));

      if (responseAttendance.statusCode == 200) {
        final Map<String, dynamic> attendanceData =
            json.decode(responseAttendance.body);
        final body = attendanceData['body'];
        // print("Attendance Data: $body");

        // Check if the body is null or not a List
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
                    absentCount++;
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

                        if (getInStatus(punchInTime) == 'Late') {
                        }
                      }
                    }

                    // Include late as present, count only first punch-in
                    if (firstPunchInIsLate) {
                      lateCount++;
                    }
                    presentCount++;
                  }
                }
              }
            }
          }
        }

        // Calculate absent days excluding Sundays without attendance
        for (int day = 1; day <= lastDay; day++) {
          final currentDay = DateTime(year, month, day);

          // If it's not attended and not a Sunday, or it's a Sunday without attendance
          if (!attendedDays.any((d) => d.day == currentDay.day)) {
            // Only count non-Sundays as absent or Sundays without attendance
            if (currentDay.weekday != DateTime.sunday) {
              absentCount++;
            }
          }
        }

        // Return the computed values for present (including late), absent, and late counts
        return {
          'Present': presentCount, // Present count includes late as well
          'Absent': absentCount, // Excludes Sundays without attendance
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

  // Function to parse time string (AM/PM) into a DateTime object
  DateTime parseTime(String date, String time) {
    try {
      // Remove any extra spaces and handle cases with or without spaces between time and AM/PM
      time = time.trim().replaceAll(RegExp(r'\s+'), ' '); // Normalize the spaces

      // Use regex to capture the time and the AM/PM portion separately
      final timeParts = RegExp(r'(\d{1,2}:\d{2})\s?(AM|PM)', caseSensitive: false).firstMatch(time);
      
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

  // Function to determine if the punch-in time is late or on time
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
Future<Function?> pp() async {
  final attendanceAnalytics = AttendanceAnalytics();

  final result = await attendanceAnalytics.getAttendanceAnalytics(
      '72', 9, 2024); // Get analytics for employee with code '72' for September 2024

  print('Present: ${result['Present']}');
  print('Absent: ${result['Absent']}');
  print('Late: ${result['Late']}');
  return null;
}

