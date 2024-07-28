import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/blog.dart';
import '../home/widgets/item_blog.dart';
import '../edit_blog/edit_blog_screen.dart'; // Import your EditBlogScreen

class MyBlogScreen extends StatefulWidget {
  final User user;
  const MyBlogScreen({required this.user, super.key});

  @override
  State<MyBlogScreen> createState() => _MyBlogScreenState();
}

class _MyBlogScreenState extends State<MyBlogScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _deleteBlog(String blogId) async {
    try {
      await FirebaseFirestore.instance.collection('blogs').doc(blogId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete blog: $e')),
      );
    }
  }

  void _editBlog(Blog blog, String blogId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBlogScreen(blog: blog, blogId: blogId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blogs'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              Blog blog = Blog.fromMap(element.data());
              blogs.add(blog);
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
                    title: Text(blog.title),
                    subtitle: Text(blog.desc),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editBlog(blog, data[index].id), // Pass blogId to EditBlogScreen
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Blog'),
                                  content: const Text('Are you sure you want to delete this blog?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteBlog(data[index].id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text('No blogs found'),
          );
        },
      ),
    );
  }
}





/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/blog.dart';
import '../home/widgets/item_blog.dart';
import '../edit_blog/edit_blog_screen.dart'; // Import your EditBlogScreen

class MyBlogScreen extends StatefulWidget {
  final User user;
  const MyBlogScreen({required this.user, super.key});

  @override
  State<MyBlogScreen> createState() => _MyBlogScreenState();
}

class _MyBlogScreenState extends State<MyBlogScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _deleteBlog(String blogId) async {
    try {
      await FirebaseFirestore.instance.collection('blogs').doc(blogId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete blog: $e')),
      );
    }
  }

  void _editBlog(Blog blog) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBlogScreen(blog: blog)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blogs'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              Blog blog = Blog.fromMap(element.data());
              blogs.add(blog);
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
                    title: Text(blog.title),
                    subtitle: Text(blog.desc),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editBlog(blog),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Blog'),
                                  content: const Text('Are you sure you want to delete this blog?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteBlog(blog.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text('No blogs found'),
          );
        },
      ),
    );
  }
}




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/blog.dart';
import '../home/widgets/item_blog.dart';

class MyBlogScreen extends StatefulWidget {
  final User user;
  const MyBlogScreen({required this.user, super.key});

  @override
  State<MyBlogScreen> createState() => _MyBlogScreenState();
}

class _MyBlogScreenState extends State<MyBlogScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blogs'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              Blog blog = Blog.fromMap(element.data());
              blogs.add(blog);
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
                  child: ItemBlog(blog: blog),
                );
              },
            );
          }
          return const Center(
            child: Text('No blogs found'),
          );
        },
      ),
    );
  }
}





import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/edit_blog/edit_blog_screen.dart'; // Import EditBlogScreen
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../home/detail_view_screen.dart';
import '../home/user_profile_screen.dart';

class MyBlogScreen extends StatefulWidget {
  const MyBlogScreen({super.key});

  @override
  State<MyBlogScreen> createState() => _MyBlogScreenState();
}

class _MyBlogScreenState extends State<MyBlogScreen> {
  final auth = FirebaseAuth.instance;

  Future<void> _deleteBlog(String blogId) async {
    await FirebaseFirestore.instance.collection('blogs').doc(blogId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blog deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blogs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  await auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .where('userId', isEqualTo: auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              Blog blog = Blog.fromMap(element.data());
              blogs.add(blog);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                return BlogCard(
                  blog: blogs[index],
                  onDelete: () => _deleteBlog(data[index].id),
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBlogScreen(blog: blogs[index], blogId: data[index].id),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBlogScreen()));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BlogCard({super.key, required this.blog, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/blogs_thumbnail.jpg'), // Placeholder image
        ),
        title: Text(blog.title, style: Theme.of(context).textTheme.headlineSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailViewScreen(blog: blog),
            ),
          );
        },
      ),
    );
  }
}







import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/blog.dart';
import '../home/widgets/item_blog.dart';

class MyBlogScreen extends StatefulWidget {
  final User user;
  const MyBlogScreen({required this.user,super.key});

  @override
  State<MyBlogScreen> createState() => _MyBlogScreenState();
}

class _MyBlogScreenState extends State<MyBlogScreen> {
  final user =FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blogs'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').where('userId', isEqualTo: user?.uid).snapshots(),
        builder: (context,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              Blog blog = Blog.fromMap(element.data());
              blogs.add(blog);

            }
            return ListView(
              padding: const EdgeInsets.all(15),
              children: [
                for(var blog in blogs)
                  ItemBlog(blog: blog)
              ],

            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
*/
