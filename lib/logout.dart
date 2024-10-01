import 'package:audiofusion/dashbord.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout extends StatefulWidget {
  const Logout({Key? key}) : super(key: key);

  @override
  State<Logout> createState() => LogoutState();
}

class LogoutState extends State<Logout> {
  @override
  void initState() {
    super.initState();
    clearSharedPreferencesAndNavigateToDashboard();
  }

  Future<void> clearSharedPreferencesAndNavigateToDashboard() async {
    print("+++++++++");
    // Response();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("==========");
    // After clearing SharedPreferences, navigate to the Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
