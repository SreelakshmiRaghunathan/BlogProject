import 'dart:io';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool loading = false;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _uploadProfileImage(User user) async {
    if (_image != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
    }
  }

  Future<void> starRegister() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      final user = result.user;
      if (user != null) {
        await user.updateDisplayName(name.text);
        await _uploadProfileImage(user);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error occurred')),
      );
    }
  }

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
                  const SizedBox(height: 60),
                  const Text(
                    "Start Your Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(hintText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
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
                        starRegister();
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      minimumSize: const Size(50, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Already have an account? Login now"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}






/*import 'dart:io';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool loading = false;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _uploadProfileImage(User user) async {
    if (_image != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
    }
  }

  Future<void> starRegister() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      final user = result.user;
      if (user != null) {
        await user.updateDisplayName(name.text);
        await _uploadProfileImage(user);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error occurred')),
      );
    }
  }

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
                  const SizedBox(height: 60),
                  const Text(
                    "Start Your Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(hintText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
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
                        starRegister();
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      minimumSize: const Size(50, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Already have an account? Login now"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}





import 'dart:io';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool loading = false;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _uploadProfileImage(User user) async {
    if (_image != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
    }
  }

  Future<void> starRegister() async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      final user = result.user;
      if (user != null) {
        await user.updateDisplayName(name.text);
        await _uploadProfileImage(user);

        setState(() {
          loading = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(profileImagePath: user.photoURL ?? '')),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error occurred')),
      );
    }
  }

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
                  const SizedBox(height: 60),
                  const Text(
                    "Start Your Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(hintText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
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
                        starRegister();
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      minimumSize: const Size(50, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Already have an account? Login now"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}




import 'dart:io';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  bool loading = false;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

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
                  const SizedBox(height: 60),

                  // "Start Your Profile" Text
                  const Text(
                    "Start Your Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Profile Picture Section
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),

                  //const SizedBox(height: 30),

                  //Text('Register', style: Theme.of(context).textTheme.displaySmall),
                  //const Text('Please enter Name, Email, and Password to get started.'),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(hintText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
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
                        starRegister();
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18, // Increase font size
                        fontWeight: FontWeight.bold, // Make text bold
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      minimumSize: const Size(50, 50), // Set minimum size for the button
                    ),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Already have an account? Login now"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Future<void> starRegister() async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      await result.user?.updateDisplayName(name.text);
      if (_image != null) {
        // You can upload the image to Firebase Storage and save the URL to the user's profile here
      }
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
        SnackBar(content: Text(e.message ?? '')),
      );
    }
  }
}





import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
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
                padding:const EdgeInsets.all(15),
                children: [
                  const SizedBox(height: 100),
                  Text('Register',style: Theme.of(context).textTheme.displaySmall),
                  const Text('Please enter Name,Email and Password to get started.'),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                        hintText: 'Name'
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 35),
                  loading? const Center(child: CircularProgressIndicator()):
                  ElevatedButton(
                    onPressed: (){
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          loading=true;
                        });
                        starRegister();
                      }
                    },
                    child: const Text('Register'),
                  )
                ],


              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Already have an account ?Login now"),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
  starRegister() async{
    try {
      final result = await auth.createUserWithEmailAndPassword(email: email.text, password: password.text);
      await result.user?.updateDisplayName(name.text);
      setState(() {
        loading= false;
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
    }on FirebaseAuthException catch(e){
      setState(() {
        loading= false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar
        (content: Text(e.message?? ''),
      ));

    }
    }

}
*/

