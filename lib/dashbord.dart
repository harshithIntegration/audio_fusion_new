import 'dart:async';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audiofusion/Employee/empdashboard.dart';
import 'package:audiofusion/admin/adminpage.dart';
import 'package:audiofusion/contactus.dart';
import 'package:audiofusion/features.dart';
import 'package:audiofusion/logout.dart';
import 'package:audiofusion/privacypolicy.dart';
import 'package:audiofusion/profilepage.dart';
import 'package:audiofusion/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:audiofusion/aboutus.dart';
import 'package:audiofusion/speakers.dart';
import 'package:audiofusion/venue.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  Map<String, dynamic>? storedResponse;
  DateTime? currentBackPressTime;
  List<String>? names;
  bool isLoading = false;
  late FlutterTts flutterTts;
  late ColorizeAnimatedTextKit _animatedTextKit;
  late Timer _colorChangeTimer;
  List<Color> _currentColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];



  @override
  void initState() {
    super.initState();
    Response();
            flutterTts=FlutterTts();
    fetchBirthdayMessage();
    _colorChangeTimer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentColors = _getRandomColors();
        _updateAnimatedTextKit();
      });
    });

  }

    @override
  void dispose() {
    _colorChangeTimer.cancel();
     flutterTts.stop();
    super.dispose();
  }

  Future<void> fetchBirthdayMessage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(Uri.parse('http://13.201.213.5:4080/pte/dobreminder'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          names = (data['body'] as String)
              .split(',')
              .map((name) => name.trim())
              .toList();

          _updateAnimatedTextKit();
          if(true){
          _speakNames();
          }
        });
      } else {
        setState(() {
          names = null;
        });
      }
    } catch (e) {
      setState(() {
        names = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateAnimatedTextKit() {
    if (names == null || names!.isEmpty) return;

    final combinedNames = names!.map((name) => '☆  $name ').join('\n');
    _animatedTextKit = ColorizeAnimatedTextKit(
      text: [combinedNames],
      colors: _currentColors,
      textStyle: TextStyle(
        fontSize: 32,
        fontFamily: 'Cursive',
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      repeatForever: true,
    );
  }


Future<void> _speakNames() async {
  if (names == null || names!.isEmpty) return;

  await flutterTts.setLanguage("en-IN");

  await flutterTts.setSpeechRate(0.5); 
  await flutterTts.setPitch(1.0); 
  await flutterTts.setVolume(1.0);
  for (var name in names!) {
    final message = "Cheers to another beautiful year! Wishing you a very Happy Birthday $name!";
    await flutterTts.speak(message);
    await Future.delayed(Duration(seconds: 2));
  }
}

  List<Color> _getRandomColors() {
    final List<Color> colors = [
      const Color.fromARGB(255, 224, 203, 7),
      Colors.blue,
      Colors.green,
      const Color.fromARGB(255, 212, 22, 203),
      Colors.orange,
    ];
    colors.shuffle(); 
    return colors.take(5).toList();
  }


Widget _buildAnimatedTextColumn() {
    if (names == null || names!.isEmpty) {
      return const SizedBox.shrink();
    }
    return _animatedTextKit; 
  }

  Future<void> Response() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('response');
    if (jsonString != null) {
      setState(() {
        storedResponse = jsonDecode(jsonString);
      });
      print(storedResponse);
    } else {
      print("Stored response is null");
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blueGrey,
      toolbarHeight: 70,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/banner.png',
              height: 600,
              width: 270,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    ),
    drawer: SizedBox(
      width: 250,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 180,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (storedResponse != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          }
                        },
                        child: const CircleAvatar(
                          radius: 31,
                          backgroundImage: AssetImage('assets/avatar.png'),
                        ),
                      ),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cast_for_education_sharp),
              title: const Text('Features'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Features()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicy()),
                );
              },
            ),
            if (storedResponse == null)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                  );
                },
              ),
            if (storedResponse != null)
              if (storedResponse?['body']['customerStatus'] == false &&
                  storedResponse?['body']['adminStatus'] == false)
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('employee'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmployeeDashboard()),
                    );
                  },
                ),
            if (storedResponse != null)
              if (storedResponse?['body']['adminStatus'] == true)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('admin'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminPage()),
                    );
                  },
                ),
            if (storedResponse != null)
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('logout'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Logout()),
                  );
                },
              ),
          ],
        ),
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              'assets/audio.jpg',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 25),
          if (names != null && names!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'cakeIcon',
                    child: SizedBox(
                      width: 450,
                      height: 320,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.black54,
                        color: Colors.white,
                        margin: const EdgeInsets.all(2),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.lightBlueAccent.withOpacity(0.2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cake,
                                  color: Colors.purple,
                                  size: 60,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  '🎉 Happy Birthday 🎉',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                    fontFamily: 'Cursive',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Flexible(
                                  child: _buildAnimatedTextColumn(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 25),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              DashboardItem(
                icon: Icons.co_present_outlined,
                label: 'AboutUs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutUs(),
                    ),
                  );
                },
              ),
              DashboardItem(
                icon: Icons.spatial_tracking_rounded,
                label: 'Speakers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Speakers(),
                    ),
                  );
                },
              ),
              DashboardItem(
                icon: Icons.add_call,
                label: 'ContactUs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactUsPage(),
                    ),
                  );
                },
              ),
              DashboardItem(
                icon: Icons.location_on,
                label: 'Venue',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Venue(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              color: Colors.blueGrey,
              padding: const EdgeInsets.all(11.0),
              child: const Text(
                '©Copyright 2024 All Rights Reserved by AudioVisual Fusion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  DashboardItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50.0),
            SizedBox(height: 10.0),
            Text(
              label,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
