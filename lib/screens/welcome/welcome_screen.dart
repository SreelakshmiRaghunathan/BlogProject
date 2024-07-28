import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.jpg', height: 150), // Reduced height for the logo

              const SizedBox(height: 30),

              // Caption with standard font
              Text(
                'Tell Your Story With Us .',
                style: TextStyle(
                  fontSize: 20, // Reduced font size
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontFamily: 'Arial', // Standard font
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: 200, // Reduced button width
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Semi-square border
                    ),
                    side: const BorderSide(color: Colors.black), // Black border
                    foregroundColor: Colors.black, // Black text color
                    elevation: 5,
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 16)), // Reduced font size
                ),
              ),

              const SizedBox(height: 20),

              // "New here" text
              Text(
                'New here?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 20),

              // Register Button
              SizedBox(
                width: 200, // Reduced button width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Semi-square border
                    ),
                    foregroundColor: Colors.white, // White text color
                    elevation: 5,
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 16)), // Reduced font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}











/*import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/auth/register_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // No longer need to navigate after delay, as this is now a welcome screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.jpg', height: 200),

              const SizedBox(height: 30),

              // Caption with standard font
              Text(
                'Tell Your Story With Us .',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontFamily: 'Arial', // Standard font
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity, // Ensures button width matches the screen width
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Semi-square border
                    ),
                    side: const BorderSide(color: Colors.black), // Black border
                    foregroundColor: Colors.black, // Black text color
                    elevation: 5,
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 20),

              // "New here" text
              Text(
                'New here?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 20),

              // Register Button
              SizedBox(
                width: double.infinity, // Ensures button width matches the screen width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Semi-square border
                    ),
                    foregroundColor: Colors.white, // White text color
                    elevation: 5,
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/auth/register_screen.dart'; // Import the register screen
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // No longer need to navigate after delay, as this is now a welcome screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.jpg', height: 200),

              const SizedBox(height: 30),

              // Caption
              Text(
                'Tell Your Story With Us',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.grey[400], // Ash color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Semi-square border
                  ),
                  elevation: 5,
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.black; // Change to black on hover
                    }
                    return Colors.grey[400]!; // Ash color when not hovered
                  }),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 20),

              // "New here" text
              Text(
                'New here?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 20),

              // Register Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Semi-square border
                  ),
                  side: BorderSide(color: Colors.grey[400]!), // Ash color
                ).copyWith(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.white; // Change text color on hover
                    }
                    return Colors.black; // Text color when not hovered
                  }),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.black; // Change to black on hover
                    }
                    return Colors.white; // Default background color
                  }),
                ),
                child: const Text('Register', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}







import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/auth/register_screen.dart'; // Import the register screen
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // No longer need to navigate after delay, as this is now a welcome screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.jpg', height: 200),

              const SizedBox(height: 30),

              // Caption
              Text(
                'Welcome to Blog App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 20),

              // Register Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.blue[700]!),
                ),
                child: const Text('Register', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    Future.delayed( const Duration(seconds: 3)).then((value) {
      if (auth.currentUser == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logo.jpg',height: 200),

      )
    );
  }
}*/
