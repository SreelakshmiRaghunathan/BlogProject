import 'dart:io';

import 'package:blogs_updated/screens/home/widgets/edit_profile_screen.dart';
import 'package:blogs_updated/screens/welcome/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart';
import 'downloaded_blogs_screen.dart';
import '../home/local_storage.dart';
import '../add_blog/add_blog_screen.dart';
import 'package:image_picker/image_picker.dart'; // For image selection

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({required this.user, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isEditing = false;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    displayNameController.text = widget.user.displayName ?? '';
    emailController.text = widget.user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    setState(() {
      loading = true;
    });

    try {
      // Update display name
      if (displayNameController.text.isNotEmpty) {
        await widget.user.updateDisplayName(displayNameController.text);
      }

      // Update photo URL
      if (_pickedImage != null) {
        // Upload the image to a storage service and get the URL
        // Example:
        // String photoURL = await uploadImage(_pickedImage!);
        // await widget.user.updatePhotoURL(photoURL);
      }

      await widget.user.reload();
      setState(() {
        loading = false;
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> loadSavedBlogs() async {
    return LocalStorage.loadBlogs(widget.user.uid);
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: isEditing ? pickImage : null,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: _pickedImage != null
                            ? FileImage(File(_pickedImage!.path))
                            : widget.user.photoURL != null
                            ? NetworkImage(widget.user.photoURL!)
                            : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
                        child: isEditing
                            ? const Icon(Icons.edit, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        enabled: isEditing,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfileScreen(user: widget.user)),
                        ).then((_) {
                          // Reload user profile data after editing
                          setState(() {
                            widget.user.reload();
                          });
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add new article'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('My article'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)),
                    );
                  },
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: loadSavedBlogs(),
                  builder: (context, snapshot) {
                    final savedBlogsCount = snapshot.data?.length ?? 0;
                    return ListTile(
                      leading: const Icon(Icons.save_alt),
                      title: Text('Saved ($savedBlogsCount)'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => WelcomeScreen()),
                            (route) => false,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart';
import 'downloaded_blogs_screen.dart';
import '../home/local_storage.dart';
import '../add_blog/add_blog_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({required this.user, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isEditingName = false;
  bool isEditingEmail = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = widget.user.displayName ?? '';
    emailController.text = widget.user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    setState(() {
      loading = true;
    });

    try {
      await widget.user.updateDisplayName(displayNameController.text);
      await widget.user.reload();
      setState(() {
        loading = false;
        isEditingName = false;
        isEditingEmail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> loadSavedBlogs() async {
    return LocalStorage.loadBlogs(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.user.photoURL != null
                          ? NetworkImage(widget.user.photoURL!)
                          : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        controller: displayNameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          suffixIcon: isEditingName
                              ? IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                updateUserProfile();
                              }
                            },
                          )
                              : IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                isEditingName = true;
                              });
                            },
                          ),
                        ),
                        readOnly: !isEditingName,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Email editing is not allowed')),
                              );
                            },
                          ),
                        ),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Blog'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('My Blogs'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)),
                    );
                  },
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: loadSavedBlogs(),
                  builder: (context, snapshot) {
                    final savedBlogsCount = snapshot.data?.length ?? 0;
                    return ListTile(
                      leading: const Icon(Icons.save_alt),
                      title: Text('Downloaded Blogs ($savedBlogsCount)'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
                            (route) => false,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/





/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart';
import 'downloaded_blogs_screen.dart';
import '../home/local_storage.dart';
import '../add_blog/add_blog_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({required this.user, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = widget.user.displayName ?? '';
    emailController.text = widget.user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    setState(() {
      loading = true;
    });

    try {
      await widget.user.updateDisplayName(displayNameController.text);
      await widget.user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> loadSavedBlogs() async {
    return LocalStorage.loadBlogs(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.user.photoURL != null
                          ? NetworkImage(widget.user.photoURL!)
                          : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          updateUserProfile();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        updateUserProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Blog'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('My Blogs'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)),
                    );
                  },
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: loadSavedBlogs(),
                  builder: (context, snapshot) {
                    final savedBlogsCount = snapshot.data?.length ?? 0;
                    return ListTile(
                      leading: const Icon(Icons.save_alt),
                      title: Text('Downloaded Blogs ($savedBlogsCount)'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
                            (route) => false,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

*/








/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart';
import 'downloaded_blogs_screen.dart';
import '../home/local_storage.dart'; // Import LocalStorage
import '../add_blog/add_blog_screen.dart'; // Import AddBlogScreen

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({required this.user, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = widget.user.displayName ?? '';
    emailController.text = widget.user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    setState(() {
      loading = true;
    });

    try {
      await widget.user.updateDisplayName(displayNameController.text);
      await widget.user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<List<String>> loadSavedBlogs() async {
    return LocalStorage.getBlogs(widget.user.uid); // Use LocalStorage to get blogs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.user.photoURL != null
                          ? NetworkImage(widget.user.photoURL!)
                          : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          updateUserProfile();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        updateUserProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Blog'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('My Blogs'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)),
                    );
                  },
                ),
                FutureBuilder<List<String>>(
                  future: loadSavedBlogs(),
                  builder: (context, snapshot) {
                    final savedBlogsCount = snapshot.data?.length ?? 0;
                    return ListTile(
                      leading: const Icon(Icons.save_alt),
                      title: Text('Downloaded Blogs ($savedBlogsCount)'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
                            (route) => false,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/



/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart'; // Import HomeScreen
import 'downloaded_blogs_screen.dart'; // Import the new screen
import '../home/local_storage.dart'; // Import LocalStorage

class UserProfileScreen extends StatefulWidget {
  final User user; // Add this line

  const UserProfileScreen({super.key, required this.user}); // Add user to the constructor

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = widget.user.displayName ?? ''; // Use widget.user
    emailController.text = widget.user.email ?? ''; // Use widget.user
  }

  Future<void> updateUserProfile() async {
    setState(() {
      loading = true;
    });

    try {
      await widget.user.updateDisplayName(displayNameController.text); // Use widget.user
      await widget.user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)), // Pass user
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<List<String>> loadSavedBlogs() async {
    // Replace with actual implementation for loading saved blogs
    return []; // Example return, replace with actual implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          FutureBuilder<List<String>>(
            future: loadSavedBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return IconButton(
                  icon: const Icon(Icons.error),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to load blogs')),
                    );
                  },
                );
              }
              final savedBlogs = snapshot.data ?? [];
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'my_blogs') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyBlogScreen()), // Pass user
                    );
                  } else if (value == 'downloaded_blogs') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DownloadedBlogsScreen()), // Pass user
                    );
                  } else if (value == 'logout') {
                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)), // Pass user
                            (route) => false,
                      );
                    });
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'my_blogs',
                      child: Text('My Blogs'),
                    ),
                    PopupMenuItem<String>(
                      value: 'downloaded_blogs',
                      child: Text('Downloaded Blogs (${savedBlogs.length})'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

*/

/*

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart'; // Import HomeScreen
import 'downloaded_blogs_screen.dart'; // Import the new screen
import '../home/local_storage.dart'; // Import LocalStorage

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({required this.user, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = widget.user.displayName ?? '';
    emailController.text = widget.user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    setState(() {
      loading = true;
    });

    try {
      await widget.user.updateDisplayName(displayNameController.text);
      await widget.user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<List<String>> loadSavedBlogs() async {
    // Replace with actual implementation for loading saved blogs
    return []; // Example return, replace with actual implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          FutureBuilder<List<String>>(
            future: loadSavedBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return IconButton(
                  icon: const Icon(Icons.error),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to load blogs')),
                    );
                  },
                );
              }
              final savedBlogs = snapshot.data ?? [];
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'my_blogs') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)),
                    );
                  } else if (value == 'downloaded_blogs') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)),
                    );
                  } else if (value == 'logout') {
                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
                            (route) => false,
                      );
                    });
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'my_blogs',
                      child: Text('My Blogs'),
                    ),
                    PopupMenuItem<String>(
                      value: 'downloaded_blogs',
                      child: Text('Downloaded Blogs (${savedBlogs.length})'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:blogs_updated/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final User user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.photoURL ?? ''),
            ),
            const SizedBox(height: 20),
            Text(user.displayName ?? 'No Name'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart'; // Import HomeScreen
import 'downloaded_blogs_screen.dart'; // Import the new screen
import '../home/local_storage.dart'; // Import LocalStorage

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<List<String>> loadSavedBlogs() async {
    final userId = user.uid;
    final blogs = await LocalStorage.loadBlogs(userId);
    return blogs.map((blog) => blog['title'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          FutureBuilder<List<String>>(
            future: loadSavedBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return IconButton(
                  icon: const Icon(Icons.error),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load blogs')),
                    );
                  },
                );
              }
              final savedBlogs = snapshot.data ?? [];
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'my_blogs') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBlogScreen()),
                    );
                  } else if (value == 'downloaded_blogs') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DownloadedBlogsScreen()),
                    );
                  } else if (value == 'logout') {
                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                      );
                    });
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'my_blogs',
                      child: Text('My Blogs'),
                    ),
                    PopupMenuItem<String>(
                      value: 'downloaded_blogs',
                      child: Text('Downloaded Blogs (${savedBlogs.length})'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}





import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart'; // Import HomeScreen
import 'downloaded_blogs_screen.dart'; // Import the new screen
import '../home/local_storage.dart'; // Import LocalStorage

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<List<String>> loadSavedBlogs() async {
    final blogs = await LocalStorage.loadBlogs(widget.uid);
    return blogs.map((blog) => blog['title'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          FutureBuilder<List<String>>(
            future: loadSavedBlogs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return IconButton(
                  icon: const Icon(Icons.error),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load blogs')),
                    );
                  },
                );
              }
              final savedBlogs = snapshot.data ?? [];
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'my_blogs') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBlogScreen()),
                    );
                  } else if (value == 'downloaded_blogs') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DownloadedBlogsScreen()),
                    );
                  } else if (value == 'logout') {
                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                      );
                    });
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'my_blogs',
                      child: Text('My Blogs'),
                    ),
                    PopupMenuItem<String>(
                      value: 'downloaded_blogs',
                      child: Text('Downloaded Blogs (${savedBlogs.length})'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}





import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart'; // Import HomeScreen
import 'downloaded_blogs_screen.dart';
import 'local_storage.dart'; // Import the new screen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'my_blogs') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBlogScreen()),
                );
              } else if (value == 'downloaded_blogs') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DownloadedBlogsScreen()),
                );
              } else if (value == 'logout') {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'my_blogs',
                child: Text('My Blogs'),
              ),
              const PopupMenuItem<String>(
                value: 'downloaded_blogs',
                child: Text('Downloaded Blogs'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}










import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart';  // Import HomeScreen
import 'downloaded_blogs_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'my_blogs') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBlogScreen()),
                );
              } else if (value == 'downloaded_blogs') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DownloadedBlogsScreen()),
                );
              } else if (value == 'logout') {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'my_blogs',
                child: Text('My Blogs'),
              ),
              const PopupMenuItem<String>(
                value: 'downloaded_blogs',
                child: Text('Downloaded Blogs'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,  // Button background color
                        foregroundColor: Colors.white,  // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}






import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../models/blog.dart';
import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart';
import 'detail_view_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  List<String> downloadedBlogs = [];

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
    _loadDownloadedBlogs();
  }

  Future<void> _loadDownloadedBlogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      final blogIds = files.map((file) => file.uri.pathSegments.last.split('.').first).toList();
      setState(() {
        downloadedBlogs = blogIds;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _viewDownloadedBlogs() async {
    // Navigate to a screen or show a dialog with downloaded blogs
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadedBlogsScreen(downloadedBlogs: downloadedBlogs),
      ),
    );
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'my_blogs') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBlogScreen()),
                );
              } else if (value == 'downloaded_blogs') {
                _viewDownloadedBlogs();
              } else if (value == 'logout') {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'my_blogs',
                child: Text('My Blogs'),
              ),
              const PopupMenuItem<String>(
                value: 'downloaded_blogs',
                child: Text('Downloaded Blogs'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,  // Button background color
                        foregroundColor: Colors.white,  // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DownloadedBlogsScreen extends StatelessWidget {
  final List<String> downloadedBlogs;
  const DownloadedBlogsScreen({super.key, required this.downloadedBlogs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Blogs'),
      ),
      body: ListView.builder(
        itemCount: downloadedBlogs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(downloadedBlogs[index]),
            onTap: () async {
              final directory = await getApplicationDocumentsDirectory();
              final file = File('${directory.path}/${downloadedBlogs[index]}.json');
              if (await file.exists()) {
                final blogData = jsonDecode(await file.readAsString());
                final blog = Blog.fromMap(blogData);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailViewScreen(blog: blog),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}





import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart';  // Import HomeScreen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'my_blogs') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBlogScreen()),
                );
              } else if (value == 'logout') {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'my_blogs',
                child: Text('My Blogs'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,  // Button background color
                        foregroundColor: Colors.white,  // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart';  // Import HomeScreen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,  // Button background color
                        foregroundColor: Colors.white,  // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],  // Button background color
                        foregroundColor: Colors.black,  // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('My Blogs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart'; // Import HomeScreen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();
      await user.updatePhotoURL(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : NetworkImage(user.photoURL ?? '') as ImageProvider,
                        child: _image == null
                            ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('My Blogs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateUserProfile() async {
    try {
      if (_image != null) {
        await _uploadProfileImage();
      }
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }
}



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../my_blogs/my_blog_screen.dart';
import '../home/home_screen.dart'; // Import HomeScreen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Update the user's profile image in Firebase (add your implementation)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : NetworkImage(user.photoURL ?? '') as ImageProvider,
                        child: _image == null
                            ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        foregroundColor: Colors.white, // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Button background color
                        foregroundColor: Colors.black, // Button text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('My Blogs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }
}



import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../my_blogs/my_blog_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Update the user's profile image in Firebase (add your implementation)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : NetworkImage(user.photoURL ??
                            'https://www.gravatar.com/avatar/placeholder') as ImageProvider,
                        child: _image == null
                            ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                      },
                      child: const Text('My Blogs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../my_blogs/my_blog_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    displayNameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Update the user's profile image in Firebase (add your implementation)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : NetworkImage(user.photoURL ??
                            'https://www.gravatar.com/avatar/placeholder') as ImageProvider,
                        child: _image == null
                            ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                      },
                      child: const Text('My Blogs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayNameController.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }
}



import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final displayName = TextEditingController();
  final email = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayName.text = user.displayName ?? '';
    email.text = user.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.photoURL ??
                          'https://www.gravatar.com/avatar/placeholder'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: displayName,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          updateUserProfile();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateUserProfile() async {
    try {
      await user.updateDisplayName(displayName.text);
      await user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }
}

 */
