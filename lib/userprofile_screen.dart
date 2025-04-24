import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:women_safety_application/screens/home_screen.dart';
import 'package:women_safety_application/screens/map_screen.dart';
import 'package:women_safety_application/screens/saferoute_screen.dart';
import 'package:women_safety_application/screens/sos_screen.dart';
import 'package:women_safety_application/screens/chatbot_screen.dart'; // Make sure to create this file

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Future<bool> _handleBack(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (route) => false,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String username = user?.displayName ?? user?.email?.split('@')[0] ?? "User";

    return WillPopScope(
      onWillPop: () => _handleBack(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('User Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: Text('LogOut', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Hello, $username!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(context, 'SOS', Icons.warning, Colors.red, SOSScreen()),
                      _buildFeatureCard(context, 'Live Location', Icons.location_on, Colors.blue, MapScreen()),
                      _buildFeatureCard(context, 'Safe Routes', Icons.map, Colors.green, SafeRouteScreen()),
                      _buildFeatureCard(context, 'More Features', Icons.more_horiz, Colors.purple, null),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatbotScreen()),
            );
          },
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.chat_bubble_outline),
          tooltip: 'Ask Neha',
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.redAccent),
            accountName: Text("Welcome!"),
            accountEmail: Text("Stay Safe, Stay Strong"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.security, color: Colors.redAccent, size: 30),
            ),
          ),
          ListTile(leading: Icon(Icons.info_outline), title: Text('About'), onTap: () {}),
          ListTile(leading: Icon(Icons.warning_amber_rounded), title: Text('Emergency'), onTap: () {}),
          ListTile(leading: Icon(Icons.share_location_outlined), title: Text('Share Location'), onTap: () {}),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Color color, Widget? screen) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: color.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15)),
                padding: EdgeInsets.all(12),
                child: Icon(icon, size: 18, color: color),
              ),
              SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
