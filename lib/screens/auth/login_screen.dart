/*import 'package:blogs_updated/screens/auth/register_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    "Welcome to The Talking",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const Text('Please enter Email and Password'),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                        hintText: 'Email'
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: 'Password'
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 100),
                  loading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        startLogin();
                        setState(() {
                          loading = true;
                        });
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
            },
            child: const Text("Don't have an account? Register now"),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  startLogin() async {
    try {
      await auth.signInWithEmailAndPassword(email: email.text, password: password.text);
      final user = auth.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? '')
      ));
    }
  }
}



import 'package:blogs_updated/screens/auth/register_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    "Welcome to The Talking",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Please enter Email and Password',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(hintText: 'Email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Password'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 100),
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        startLogin();
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: const Text("Don't have an account? Register now"),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Future<void> startLogin() async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      setState(() {
        loading = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error occurred')),
      );
    }
  }
}
*/

import 'package:blogs_updated/screens/auth/register_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    "Welcome to The Talking",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const Text('Please enter Email and Password '),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 100),
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        startLogin();
                        loading = true;
                      }
                    },
                    child: const Text('Login'),
                  )
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
            },
            child: const Text("Don't have an account? Register now"),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  startLogin() async {
    setState(() {
      loading = true;
    });

    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      final User user = userCredential.user!;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? ''),
      ));
    }
  }
}

