import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static Future<void> saveBlogs(String userId, List<Map<String, dynamic>> blogs) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/blogs_$userId.json');
    List<Map<String, dynamic>> existingBlogs = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      existingBlogs = List<Map<String, dynamic>>.from(json.decode(content));
    }

    existingBlogs.addAll(blogs);
    await file.writeAsString(json.encode(existingBlogs));
  }

  static Future<List<Map<String, dynamic>>> loadBlogs(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/blogs_$userId.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(json.decode(content));
    }
    return [];
  }
}



/*import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static Future<void> saveBlogs(List<Map<String, dynamic>> blogs) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/blogs.json');
    List<Map<String, dynamic>> existingBlogs = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      existingBlogs = List<Map<String, dynamic>>.from(json.decode(content));
    }

    existingBlogs.addAll(blogs);
    await file.writeAsString(json.encode(existingBlogs));
  }

  static Future<List<Map<String, dynamic>>> loadBlogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/blogs.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      return List<Map<String, dynamic>>.from(json.decode(content));
    }
    return [];
  }
}






import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static late Box blogBox;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    blogBox = await Hive.openBox('blogBox');
  }

  static Future<void> saveBlogs(List<Map<String, dynamic>> blogs) async {
    if (!Hive.isBoxOpen('blogBox')) {
      await init();
    }

    List<Map<String, dynamic>> existingBlogs = blogBox.get('blogs')?.cast<Map<String, dynamic>>() ?? [];
    existingBlogs.addAll(blogs);
    await blogBox.put('blogs', existingBlogs);
  }

  static List<Map<String, dynamic>>? getBlogs() {
    if (!Hive.isBoxOpen('blogBox')) {
      return null;
    }
    return blogBox.get('blogs')?.cast<Map<String, dynamic>>();
  }
}



import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static late Box blogBox;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    blogBox = await Hive.openBox('blogBox');
  }

  static Future<void> saveBlogs(List<Map<String, dynamic>> blogs) async {
    if (!Hive.isBoxOpen('blogBox')) {
      await init();
    }
    await blogBox.put('blogs', blogs);
  }

  static List<Map<String, dynamic>>? getBlogs() {
    if (!Hive.isBoxOpen('blogBox')) {
      return null;
    }
    return blogBox.get('blogs')?.cast<Map<String, dynamic>>();
  }
}






import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static late Box blogBox;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    blogBox = await Hive.openBox('blogBox');
  }

  static Future<void> saveBlogs(List<Map<String, dynamic>> blogs) async {
    await blogBox.put('blogs', blogs);
  }

  static List<Map<String, dynamic>>? getBlogs() {
    return blogBox.get('blogs')?.cast<Map<String, dynamic>>();
  }
}



import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class LocalStorage {
  static late Box _blogBox;

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    _blogBox = await Hive.openBox('blogBox');
  }

  static Future<void> saveBlogs(List<Map<String, dynamic>> blogs) async {
    await _blogBox.put('blogs', blogs);
  }

  static List<Map<String, dynamic>>? getBlogs() {
    return _blogBox.get('blogs')?.cast<Map<String, dynamic>>();
  }
}


 */