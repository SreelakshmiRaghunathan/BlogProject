import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/blog.dart';

class AddBlogScreen extends StatefulWidget {
  final User user;
  const AddBlogScreen({required this.user,super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String selectedCategory = 'Technology';

  final List<String> categories = ['Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blog'),
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
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: desc,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
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
                          addBlog();
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

  addBlog() async {
    final db = FirebaseFirestore.instance.collection('blogs');
    final user = FirebaseAuth.instance.currentUser!;
    final id = db.doc().id; // Automatically generate a document ID
    Blog blog = Blog(
      id: id,
      userId: user.uid,
      //authorName: user.displayName ?? 'Anonymous', // Add this field
      title: title.text,
      desc: desc.text,
      createdAt: DateTime.now(),
      category: selectedCategory,
    );
    try {
      await db.doc(id).set(blog.toMap());
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'An error occurred'),
      ));
    }
  }
}





/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/blog.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String selectedCategory = 'Technology';

  final List<String> categories = ['Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blog'),
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
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: desc,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
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
                          addBlog();
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

  addBlog() async {
    final db = FirebaseFirestore.instance.collection('blogs');
    final user = FirebaseAuth.instance.currentUser!;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    Blog blog = Blog(
      id: id,
      userId: user.uid,
      title: title.text,
      desc: desc.text,
      createdAt: DateTime.now(),
      category: selectedCategory,
    );
    try {
      await db.doc(id).set(blog.toMap());
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'An error occurred'),
      ));
    }
  }
}




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/blog.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String? selectedCategory;
  final List<String> categories = ['Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blog'),
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
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: desc,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          addBlog();
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

  addBlog() async {
    final db = FirebaseFirestore.instance.collection('blogs');
    final user = FirebaseAuth.instance.currentUser!;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    Blog blog = Blog(
      id: id,
      userId: user.uid,
      title: title.text,
      desc: desc.text,
      createdAt: DateTime.now(),
      category: selectedCategory ?? '', // Add this line
    );
    try {
      await db.doc(id).set(blog.toMap());
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'An error occurred'),
      ));
    }
  }
}




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/blog.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String? selectedCategory;
  final List<String> categories = ['Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blog'),
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
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: desc,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          addBlog();
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

  addBlog() async {
    final db = FirebaseFirestore.instance.collection('blogs');
    final user = FirebaseAuth.instance.currentUser!;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    Blog blog = Blog(
      id: id,
      userId: user.uid,
      title: title.text,
      desc: desc.text,
      createdAt: DateTime.now(),
      category: selectedCategory ?? '',
    );
    try {
      await db.doc(id).set(blog.toMap());
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'An error occurred'),
      ));
    }
  }
}






import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/blog.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blog'),
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
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: desc,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          addBlog();
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

  addBlog() async {
    final db = FirebaseFirestore.instance.collection('blogs');
    final user = FirebaseAuth.instance.currentUser!;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    Blog blog = Blog(
      id: id,
      userId: user.uid,
      title: title.text,
      desc: desc.text,
      createdAt: DateTime.now(),
    );
    try {
      await db.doc(id).set(blog.toMap());
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'An error occurred'),
      ));
    }
  }
}





//import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/blog.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isBold = false;
  bool isItalic = false;

  TextStyle get _textStyle {
    return TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blog'),
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
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isBold ? Icons.format_bold : Icons.format_bold_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  isBold = !isBold;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isItalic ? Icons.format_italic : Icons.format_italic_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  isItalic = !isItalic;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: TextFormField(
                            controller: descController,
                            maxLines: 10,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            style: _textStyle,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter description';
                              }
                              return null;
                            },
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
                                addBlog();
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

  addBlog() async {
    final db = FirebaseFirestore.instance.collection('blogs');
    final user = FirebaseAuth.instance.currentUser!;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    Blog blog = Blog(
      id: id,
      userId: user.uid,
      title: titleController.text,
      desc: descController.text,
      createdAt: DateTime.now(),
    );
    try {
      await db.doc(id).set(blog.toMap());
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'An error occurred'),
      ));
    }
  }
}




import 'package:blogs_updated/models/blog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add blogs'),
        actions: [
          IconButton(
              onPressed: () {
                if(formKey.currentState!.validate()) {
                  setState(() {
                    loading= true;
                  });
                  addBlog();
                }
              },
              icon: const Icon(Icons.done),
          )
        ],
      ),
      body: loading? const Center(child: CircularProgressIndicator()):
      Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            TextFormField(
              controller: title,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder()
              ),
              validator: (value) {
                if (value!.isEmpty){
                  return 'Please enter title';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: desc,
              maxLines: 10,
              decoration: const InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder()
              ),
              validator: (value) {
                if (value!.isEmpty){
                  return 'Please enter description';
                }
                return null;
              },
            )
          ],
        ),
      ),
    );
  }
  addBlog() async{
    final db = FirebaseFirestore.instance.collection('blogs');
    final user = FirebaseAuth.instance.currentUser!;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    Blog blog = Blog(
        id: id,
        userId: user.uid,
        title: title.text,
        desc: desc.text,
        createdAt: DateTime.now()
    );
    try {
      await db.doc(id).set(blog.toMap());
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    }on FirebaseException catch(e) {
      setState(() {
        loading = false;
      });
    }
  }
}
*/