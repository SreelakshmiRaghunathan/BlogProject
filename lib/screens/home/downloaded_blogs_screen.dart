import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class DownloadedBlogsScreen extends StatelessWidget {
  final User user;
  const DownloadedBlogsScreen({required this.user, super.key});

  Future<List<Map<String, dynamic>>> _loadBlogs() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/blogs_$userId.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(json.decode(content));
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded Blogs')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading blogs'));
          }
          final blogs = snapshot.data ?? [];
          if (blogs.isEmpty) {
            return const Center(child: Text('No downloaded blogs found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    blog['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(blog['desc']),
                  contentPadding: const EdgeInsets.all(15),
                ),
              );
            },
          );
        },
      ),
    );
  }
}





/*
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class DownloadedBlogsScreen extends StatelessWidget {
  final User user;
  const DownloadedBlogsScreen({required this.user,super.key});

  Future<List<Map<String, dynamic>>> _loadBlogs() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/blogs_$userId.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(json.decode(content));
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded Blogs')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading blogs'));
          }
          final blogs = snapshot.data ?? [];
          return ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
              return ListTile(
                title: Text(blog['title']),
                subtitle: Text(blog['desc']),
              );
            },
          );
        },
      ),
    );
  }
}




import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class DownloadedBlogsScreen extends StatelessWidget {
  const DownloadedBlogsScreen({super.key});

  Future<List<Map<String, dynamic>>> _loadBlogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/blogs.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(json.decode(content));
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded Blogs')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading blogs'));
          }
          final blogs = snapshot.data ?? [];
          return ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
              return ListTile(
                title: Text(blog['title']),
                subtitle: Text(blog['desc']),
              );
            },
          );
        },
      ),
    );
  }
}










import 'package:flutter/material.dart';
import '../../models/blog.dart';
import 'detail_view_screen.dart';
import '../home/local_storage.dart';

class DownloadedBlogsScreen extends StatelessWidget {
  const DownloadedBlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Blogs'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDownloadedBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final blogs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = Blog.fromMap(blogs[index]);
                return ListTile(
                  title: Text(blog.title),
                  subtitle: Text(blog.desc),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewScreen(blog: blog),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('No downloaded blogs.'));
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getDownloadedBlogs() async {
    final blogs = LocalStorage.getBlogs();
    return blogs ?? [];
  }
}





import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/blog.dart';
import 'detail_view_screen.dart'; // Ensure this import path is correct
import 'local_storage.dart';

class DownloadedBlogsScreen extends StatelessWidget {
  const DownloadedBlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Blogs'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDownloadedBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final blogs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = Blog.fromMap(blogs[index]);
                return ListTile(
                  title: Text(blog.title),
                  subtitle: Text(blog.desc),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewScreen(blog: blog),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('No downloaded blogs.'));
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getDownloadedBlogs() async {
    final blogs = LocalStorage.getBlogs();
    return blogs ?? [];
  }
}


import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/blog.dart';
import 'detail_view_screen.dart';
import 'local_storage.dart';  // Ensure this import path is correct

class DownloadedBlogsScreen extends StatelessWidget {
  const DownloadedBlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Blogs'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDownloadedBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final blogs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = Blog.fromMap(blogs[index]);
                return ListTile(
                  title: Text(blog.title),
                  subtitle: Text(blog.desc),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewScreen(blog: blog),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('No downloaded blogs.'));
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getDownloadedBlogs() async {
    final blogs = LocalStorage.getBlogs();
    return blogs ?? [];
  }
}

 */
