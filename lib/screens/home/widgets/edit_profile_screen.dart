import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({required this.user, super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  String? profilePicUrl;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayNameController.text = widget.user.displayName ?? '';
    emailController.text = widget.user.email ?? '';
    profilePicUrl = widget.user.photoURL;
  }

  Future<void> updateUserProfile() async {
    setState(() {
      loading = true;
    });

    try {
      await widget.user.updateDisplayName(displayNameController.text);
      await widget.user.updateEmail(emailController.text);
      await widget.user.updatePhotoURL(profilePicUrl);
      await widget.user.reload();
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context); // Go back to the UserProfileScreen
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<void> pickProfilePic() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profilePicUrl = image.path; // For simplicity, using the local path
        // In a real app, upload to Firebase Storage and get the URL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickProfilePic,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profilePicUrl != null
                    ? FileImage(File(profilePicUrl!))
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                child: profilePicUrl == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
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
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (displayNameController.text.isNotEmpty &&
                      emailController.text.isNotEmpty) {
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
          ],
        ),
      ),
    );
  }
}
