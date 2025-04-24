import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:women_safety_application/screens/map_screen.dart';
import 'package:women_safety_application/screens/saferoute_screen.dart';
import 'sos_screen.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFDFD),
      appBar: AppBar(
        elevation: 4,
        title: Text(
          'SafeZone',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => SignUpScreen())),
            child: Text('Sign Up', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => LoginScreen())),
            child: Text('Log In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: Drawer(
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
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.warning_amber_rounded),
              title: Text('Emergency'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.share_location_outlined),
              title: Text('Share Location'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully!')),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? screen,
  ) {
    return GestureDetector(
      onTap: () {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          // Not logged in, go to Login screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to access $title')),
          );
        } else {
          // Logged in, go to the actual feature screen if it's provided
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          }
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                padding: EdgeInsets.all(12),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
