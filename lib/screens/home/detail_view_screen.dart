import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../home/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailViewScreen extends StatelessWidget {
  final Blog blog;

  const DetailViewScreen({super.key, required this.blog});

  Future<void> _downloadBlog(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await LocalStorage.saveBlogs(userId, [blog.toMap()]); // Save blog for offline access
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog downloaded for offline access.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download blog: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadBlog(context),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200], // Background color similar to home screen
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2, // Add elevation to give a card effect
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blog.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          blog.desc,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../home/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailViewScreen extends StatelessWidget {
  final Blog blog;

  const DetailViewScreen({super.key, required this.blog});

  Future<void> _downloadBlog(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await LocalStorage.saveBlogs(userId, [blog.toMap()]); // Save blog for offline access
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog downloaded for offline access.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download blog: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadBlog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              blog.desc,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}




import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../home/local_storage.dart';

class DetailViewScreen extends StatelessWidget {
  final Blog blog;

  const DetailViewScreen({super.key, required this.blog});

  Future<void> _downloadBlog(BuildContext context) async {
    try {
      await LocalStorage.saveBlogs([blog.toMap()]); // Save blog for offline access
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog downloaded for offline access.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download blog: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadBlog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              blog.desc,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}






import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../home/local_storage.dart';

class DetailViewScreen extends StatelessWidget {
  final Blog blog;

  const DetailViewScreen({super.key, required this.blog});

  Future<void> _downloadBlog(BuildContext context) async {
    try {
      await LocalStorage.saveBlogs([blog.toMap()]); // Save blog for offline access
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog downloaded for offline access.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download blog: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadBlog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              blog.desc,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}





import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import 'local_storage.dart';  // Make sure this import path is correct

class DetailViewScreen extends StatelessWidget {
  final Blog blog;
  const DetailViewScreen({super.key, required this.blog});

  Future<void> _downloadBlog(BuildContext context) async {
    try {
      await LocalStorage.saveBlogs([blog.toMap()]); // Save blog for offline access
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog downloaded for offline access.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download blog: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadBlog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              blog.desc,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
*/











/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class DetailViewScreen extends StatelessWidget {
  final Blog blog;
  const DetailViewScreen({super.key, required this.blog});

  Future<void> _downloadBlog(BuildContext context) async {
    try {
      // Get the directory to store the file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${blog.id}.json');

      // Write blog data to file
      await file.writeAsString(jsonEncode(blog.toMap()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog downloaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download blog: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadBlog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              blog.desc,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}






import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog.dart';

class DetailViewScreen extends StatelessWidget {
  final Blog blog;
  const DetailViewScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(
              blog.desc,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
*/
