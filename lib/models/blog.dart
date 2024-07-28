



class Blog {
  String id;
  String userId;
  String title;
  String desc;
  DateTime createdAt;
  String category;

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.createdAt,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'desc': desc,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'] ?? '', // Provide a default value or handle the null case
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(), // Handle null case
      category: map['category'] ?? 'Uncategorized', // Handle null case
    );
  }
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String userId;
  final String title;
  final String desc;
  final String category;
  final DateTime createdAt;

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'desc': desc,
      'category': category,
      'createdAt': createdAt,
    };
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      desc: map['desc'],
      category: map['category'],
      createdAt: (map['createdAt'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }
}




import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String userId;
  final String title;
  final String desc;
  final DateTime createdAt;
  final String category;
  int visitCount; // Use this parameter

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.createdAt,
    required this.category,
    this.visitCount = 0,
  });

  factory Blog.fromMap(Map<String, dynamic> data) {
    return Blog(
      id: data['id'],
      userId: data['userId'],
      title: data['title'],
      desc: data['desc'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      category: data['category'],
      visitCount: data['visitCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'desc': desc,
      'createdAt': createdAt,
      'category': category,
      'visitCount': visitCount,
    };
  }
}



import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String userId;
  final String title;
  final String desc;
  final DateTime createdAt;
  final String category;
  int visitCount;

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.createdAt,
    required this.category,
    this.visitCount = 0,
  });

  factory Blog.fromMap(Map<String, dynamic> data) {
    return Blog(
      id: data['id'],
      userId: data['userId'],
      title: data['title'],
      desc: data['desc'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      category: data['category'],
      visitCount: data['visitCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'desc': desc,
      'createdAt': createdAt,
      'category': category,
      'visitCount': visitCount,
    };
  }
}




import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  String id;
  String userId;
  String title;
  String desc;
  DateTime createdAt;
  String category;
  int viewCount;

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.createdAt,
    required this.category,
    required this.viewCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'desc': desc,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
      'viewCount': viewCount,
    };
  }

  static Blog fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      category: map['category'] ?? '',
      viewCount: map['viewCount'] ?? 0,
    );
  }
}






class Blog {
  String id;
  String userId;
  String title;
  String desc;
  DateTime createdAt;
  String category;

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.createdAt,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'desc': desc,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'] ?? '', // Provide a default value or handle the null case
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(), // Handle null case
      category: map['category'] ?? 'Uncategorized', // Handle null case
    );
  }
}





class Blog {
  String id;
  String userId;
  String title;
  String desc;
  DateTime createdAt;
  String category; // Add this line

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.createdAt,
    required this.category, // Add this line
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'desc': desc,
      'createdAt': createdAt.toIso8601String(),
      'category': category, // Add this line
    };
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      desc: map['desc'],
      createdAt: DateTime.parse(map['createdAt']),
      category: map['category'], // Add this line
    );
  }
}



import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String userId;
  final String title;
  final dynamic desc; // Change to dynamic to store JSON data
  final DateTime createdAt;

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'desc': desc, // Store as JSON
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      desc: map['desc'], // Retrieve JSON data
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
*/






/*class Blog {
  String id, userId,title, desc;
  DateTime createdAt;

  Blog({required this.id,required this.userId,required this.title,required this.desc,required this.createdAt});

  factory Blog.fromMap(map) {
    return Blog(
        id: map['id'],
        userId: map['userId'],
        title:map['title'],
        desc: map['desc'],
        createdAt: DateTime.parse(map['createdAt'])
    );
  }

  Map<String, dynamic> toMap() {
  return{
    'id':id,
    'userId':userId,
    'title':title,
    'desc':desc,
    'createdAt':createdAt.toString()
  };
}
}*/