import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
        setState(() {
          showCategoryFilter = false;
        });
        break;

      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Handle notification icon press
              // You can navigate to a notifications screen or display notifications
            },
          ),
        ]
            : null,
        bottom: _selectedIndex == 1
            ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        )
            : null,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                if (_selectedIndex != 1) _buildCategoryChips(),
                if (_selectedIndex != 1) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        },
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt, color: Colors.black),
            label: 'Saved Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.black),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0), // Add space between chips
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                    showCategoryFilter = category != 'All';
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => a.title.compareTo(b.title));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10), // Increase vertical space between cards
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
            title: Text(blog.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewScreen(blog: blog),
                      ),
                    );
                  },
                  child: const Text('Read More'),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: blogs.length,
    );
  }
}





/*import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
        setState(() {
          showCategoryFilter = false;
        });
        break;

      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: _selectedIndex == 1
            ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        )
            : null,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                if (_selectedIndex != 1) _buildCategoryChips(),
                if (_selectedIndex != 1) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        },
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'Search',
          ),
         // BottomNavigationBarItem(
           // icon: Icon(Icons.article, color: Colors.black),
           // label: 'My Blogs',
          //),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt, color: Colors.black),
            label: 'Saved Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.black),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0), // Add space between chips
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                    showCategoryFilter = category != 'All';
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => a.title.compareTo(b.title));


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10), // Increase vertical space between cards
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
            title: Text(blog.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewScreen(blog: blog),
                      ),
                    );
                  },
                  child: const Text('Read More'),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: blogs.length,
    );
  }
}








import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
        setState(() {
          showCategoryFilter = false;
        });
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: _selectedIndex == 1
            ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        )
            : null,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                if (_selectedIndex != 1) _buildCategoryChips(),
                if (_selectedIndex != 1) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        },
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, color: Colors.black),
            label: 'My Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt, color: Colors.black),
            label: 'Saved Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.black),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0), // Add space between chips
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                    showCategoryFilter = category != 'All';
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10), // Increase vertical space between cards
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
            title: Text(blog.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewScreen(blog: blog),
                      ),
                    );
                  },
                  child: const Text('Read More'),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: blogs.length,
    );
  }
}



import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
        setState(() {
          showCategoryFilter = false;
        });
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: _selectedIndex == 1
            ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        )
            : null,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                if (_selectedIndex != 1) _buildCategoryChips(),
                if (_selectedIndex != 1) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        },
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, color: Colors.black),
            label: 'My Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt, color: Colors.black),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0), // Add space between chips
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                    showCategoryFilter = category != 'All';
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /*Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }*/

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10), // Increase vertical space between cards
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
            title: Text(blog.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewScreen(blog: blog),
                      ),
                    );
                  },
                  child: const Text('Read More'),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: blogs.length,
    );
  }
}




import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
        setState(() {
          showCategoryFilter = false;
        });
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: _selectedIndex == 1
            ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        )
            : null,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                if (_selectedIndex != 1) _buildCategoryChips(),
                if (_selectedIndex != 1) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        },
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, color: Colors.black),
            label: 'My Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt, color: Colors.black),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
            title: Text(blog.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(blog.desc),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailViewScreen(blog: blog),
                      ),
                    );
                  },
                  child: const Text('Read More'),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: blogs.length,
    );
  }
}




import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
        setState(() {
          showCategoryFilter = false;
        });
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: _selectedIndex == 1
            ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        )
            : null,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                if (_selectedIndex != 1) _buildCategoryChips(),
                if (_selectedIndex != 1) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        },
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, color: Colors.black),
            label: 'My Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt, color: Colors.black),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
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
          ),
        );
      },
      itemCount: blogs.length,
    );
  }
}





import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
        setState(() {
          showCategoryFilter = false;
        });
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        },
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
         BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, color: Colors.black),
            label: 'My Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt, color: Colors.black),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
            title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              blog.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailViewScreen(blog: blog),
                ),
              );
            },
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailViewScreen(blog: blog),
                  ),
                );
              },
              child: const Text('Read More'),
            ),
          ),
        );
      },
    );
  }
}





import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen(user: widget.user)));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: widget.user)));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen(user: widget.user)));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
            );
          }
          return const Center(child: Text('No blogs available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBlogScreen(user: widget.user)));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'My Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
            title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              blog.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailViewScreen(blog: blog),
                ),
              );
            },
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailViewScreen(blog: blog),
                  ),
                );
              },
              child: const Text('Read More'),
            ),
          ),
        );
      },
    );
  }
}





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../add_blog/add_blog_screen.dart';
import '../auth/login_screen.dart';
import '../home/downloaded_blogs_screen.dart';
import '../home/user_profile_screen.dart';
import '../my_blogs/my_blog_screen.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0; // For bottom navigation bar

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Define the categories list here
  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      // Home
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)));
        break;
      case 1:
      // Add Blog
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBlogScreen()));
        break;
      case 2:
      // Saved Blogs / My Blogs
        Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadedBlogsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter ? [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        ] : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                // Handle any errors in deserialization
                print('Error deserializing blog: $e');
              }
            }
            // Filter blogs based on search query and selected category
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    // Filter blogs created within the last 7 days
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    // Sort blogs by the number of likes (or any other metric you have)
    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: ListTile(
            title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              blog.desc.length > 100 ? '${blog.desc.substring(0, 100)}...' : blog.desc,
            ),
            trailing: const Text('Read More'), // Add 'Read More' text
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
      },
    );
  }
}




import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBlogScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadedBlogsScreen()));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'My Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(getProfileImageForUser(index)),
            ),
            title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              blog.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailViewScreen(blog: blog),
                ),
              );
            },
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailViewScreen(blog: blog),
                  ),
                );
              },
              child: const Text('Read More'),
            ),
          ),
        );
      },
    );
  }
}




import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final String profileImagePath; // Add this property to receive profile image path
  const HomeScreen({super.key, required this.profileImagePath}); // Update constructor

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(profileImagePath: widget.profileImagePath)));
        break;
      case 1:
      // Implement search functionality
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBlogScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadedBlogsScreen()));
        break;
    //case 4:
    //Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); // Navigate to settings
    //break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage(widget.profileImagePath),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Saved Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return BlogCard(
          blog: blogs[index],
          profileImage: widget.profileImagePath, // Pass profile image path to BlogCard
        );
      },
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final String profileImage; // Add this property for profile image

  const BlogCard({required this.blog, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(profileImage),
                ),
              //  const SizedBox(width: 10),
                //Text(
                  //blog.authorName,
                  //style: const TextStyle(fontWeight: FontWeight.bold),
                //),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              blog.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              blog.desc,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailViewScreen(blog: blog)),
                  );
                },
                child: const Text('Read More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBlogScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadedBlogsScreen()));
        break;
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter
            ? [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                print('Error deserializing blog: $e');
              }
            }
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return BlogCard(
          blog: blogs[index],
          profileImage: getProfileImageForUser(index),
        );
      },
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final String profileImage;
  const BlogCard({Key? key, required this.blog, required this.profileImage}) : super(key: key);

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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

*/
/*






import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/downloaded_blogs_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;
  int _selectedIndex = 0; // For bottom navigation bar

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      // Home
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
      // Add Blog
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBlogScreen()));
        break;
      case 2:
      // Saved Blogs / My Blogs
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadedBlogsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter ? [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        ] : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                // Handle any errors in deserialization
                print('Error deserializing blog: $e');
              }
            }
            // Filter blogs based on search query and selected category
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt),
            label: 'Saved Blogs',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    // Filter blogs created within the last 7 days
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    // Sort blogs by the number of likes (or any other metric you have)
    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return BlogCard(
          blog: blogs[index],
          profileImage: getProfileImageForUser(index),
        );
      },
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../add_blog/add_blog_screen.dart';
import '../auth/login_screen.dart';
import '../home/user_profile_screen.dart';
import '../my_blogs/my_blog_screen.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter ? [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        ] : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                // Handle any errors in deserialization
                print('Error deserializing blog: $e');
              }
            }
            // Filter blogs based on search query and selected category
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    // Filter blogs created within the last 7 days
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    // Sort blogs by the number of likes (or any other metric you have)
    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return BlogCard(
          blog: blogs[index],
          profileImage: getProfileImageForUser(index),
        );
      },
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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




import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBlogScreen()),
                  );
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: DropdownButton<String>(
              value: _selectedCategory,
              items: <String>['All', 'Technology', 'Science', 'Art', 'Health', 'Travel']
                  .map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue ?? 'All';
                });
              },
              isExpanded: true,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final data = snapshot.data!.docs;
                  List<Blog> blogs = [];
                  for (var element in data) {
                    Blog blog = Blog.fromMap(element.data());
                    if (_selectedCategory == 'All' || blog.category == _selectedCategory) {
                      blogs.add(blog);
                    }
                  }

                  // Filter blogs based on search query
                  final filteredBlogs = blogs.where((blog) {
                    return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  // Shuffle and select trending blogs
                  final random = Random();
                  filteredBlogs.shuffle(random);
                  final trendingBlogs = filteredBlogs.take(5).toList();

                  return ListView(
                    padding: const EdgeInsets.all(15),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = 'Trending';
                                });
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: trendingBlogs.length,
                        itemBuilder: (context, index) {
                          return BlogCard(blog: trendingBlogs[index]);
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _selectedCategory == 'All' ? 'All Blogs' : _selectedCategory,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredBlogs.length,
                        itemBuilder: (context, index) {
                          return BlogCard(blog: filteredBlogs[index]);
                        },
                      ),
                    ],
                  );
                }
                return const Center(child: Text('No blogs available.'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBlogScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;

  const BlogCard({super.key, required this.blog});

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
        title: Text(blog.title, style: Theme.of(context).textTheme.headlineSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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



import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              items: ['Tech', 'Lifestyle', 'Food', 'Travel', 'Education']
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Text('Trending', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('blogs')
                  .orderBy('visitCount', descending: true) // Order by visitCount
                  .limit(5) // Limit to top 5 trending blogs
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
                        profileImage: getProfileImageForUser(index),
                      );
                    },
                  );
                }
                return const Center(child: Text('No blogs available.'));
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('blogs')
                  .where('category', isEqualTo: _selectedCategory)
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
                  // Filter blogs based on search query
                  final filteredBlogs = blogs.where((blog) {
                    return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: filteredBlogs.length,
                    itemBuilder: (context, index) {
                      return BlogCard(
                        blog: filteredBlogs[index],
                        profileImage: getProfileImageForUser(index),
                      );
                    },
                  );
                }
                return const Center(child: Text('No blogs available.'));
              },
            ),
          ),
        ],
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
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
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





import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<Blog>> getTrendingBlogs() {
    return FirebaseFirestore.instance
        .collection('blogs')
        .orderBy('viewCount', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Blog.fromMap(doc.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
              PopupMenuItem(
                onTap: () async {
                  FirebaseAuth.instance.signOut();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Blog>>(
        stream: getTrendingBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final blogs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                return BlogCard(
                  blog: blogs[index],
                  profileImage: getProfileImageForUser(index),
                );
              },
            );
          }
          return const Center(child: Text('No trending blogs available.'));
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
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(blog.title, style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (blog.category.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('Category: ${blog.category}', style: const TextStyle(fontStyle: FontStyle.italic)),
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
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../add_blog/add_blog_screen.dart';
import '../auth/login_screen.dart';
import '../home/user_profile_screen.dart';
import '../my_blogs/my_blog_screen.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  String selectedCategory = 'All';
  bool showCategoryFilter = false;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['All', 'Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showCategoryFilter
            ? Row(
          children: [
            BackButton(onPressed: () {
              setState(() {
                showCategoryFilter = false;
                selectedCategory = 'All';
              });
            }),
            Text(selectedCategory),
          ],
        )
            : const Text('Blog App'),
        actions: !showCategoryFilter ? [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        ] : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                // Handle any errors in deserialization
                print('Error deserializing blog: $e');
              }
            }
            // Filter blogs based on search query and selected category
            final filteredBlogs = blogs.where((blog) {
              final matchesCategory = selectedCategory == 'All' || blog.category == selectedCategory;
              final matchesSearch = blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                if (!showCategoryFilter) _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category;
                showCategoryFilter = category != 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    // Filter blogs created within the last 7 days
    final trendingBlogs = blogs.where((blog) {
      final now = DateTime.now();
      return blog.createdAt.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();

    // Sort blogs by the number of likes (or any other metric you have)
    trendingBlogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Trending', style: Theme.of(context).textTheme.headlineSmall),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              final blog = trendingBlogs[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailViewScreen(blog: blog),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return BlogCard(
          blog: blogs[index],
          profileImage: getProfileImageForUser(index),
        );
      },
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../add_blog/add_blog_screen.dart';
import '../auth/login_screen.dart';
import '../home/user_profile_screen.dart';
import '../my_blogs/my_blog_screen.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Blog> blogs = [];
            for (var element in data) {
              try {
                Blog blog = Blog.fromMap(element.data() as Map<String, dynamic>);
                blogs.add(blog);
              } catch (e) {
                // Handle any errors in deserialization
                print('Error deserializing blog: $e');
              }
            }
            // Filter blogs based on search query
            final filteredBlogs = blogs.where((blog) {
              return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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

  Widget _buildCategoryChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _searchQuery = categories[index];
                _searchController.text = _searchQuery;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    // You can define your own logic to determine trending blogs, e.g., based on view count or likes.
    final trendingBlogs = blogs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trending Blogs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: BlogCard(blog: trendingBlogs[index], profileImage: getProfileImageForUser(index)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blogs.map((blog) {
        return BlogCard(blog: blog, profileImage: getProfileImageForUser(blogs.indexOf(blog)));
      }).toList(),
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(
          blog.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../add_blog/add_blog_screen.dart';
import '../auth/login_screen.dart';
import '../home/user_profile_screen.dart';
import '../my_blogs/my_blog_screen.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
            // Filter blogs based on search query
            final filteredBlogs = blogs.where((blog) {
              return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView(
              children: [
                _buildCategoryChips(),
                _buildTrendingSection(blogs),
                _buildBlogList(filteredBlogs),
              ],
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

  Widget _buildCategoryChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _searchQuery = categories[index];
                _searchController.text = _searchQuery;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    // You can define your own logic to determine trending blogs, e.g., based on view count or likes.
    final trendingBlogs = blogs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trending Blogs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: BlogCard(blog: trendingBlogs[index], profileImage: getProfileImageForUser(index)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blogs.map((blog) {
        return BlogCard(blog: blog, profileImage: getProfileImageForUser(blogs.indexOf(blog)));
      }).toList(),
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(
          blog.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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
import 'package:intl/intl.dart';
import '../../models/blog.dart';
import '../add_blog/add_blog_screen.dart';
import '../auth/login_screen.dart';
import '../home/user_profile_screen.dart';
import '../my_blogs/my_blog_screen.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = ['Technology', 'Health', 'Lifestyle', 'Business', 'Education'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
            // Filter blogs based on search query
            final filteredBlogs = blogs.where((blog) {
              return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _buildCategorySection(),
                const SizedBox(height: 20),
                _buildTrendingSection(filteredBlogs),
                const SizedBox(height: 20),
                _buildBlogList(filteredBlogs),
              ],
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

  Widget _buildCategorySection() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _searchQuery = categories[index];
                _searchController.text = _searchQuery;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingSection(List<Blog> blogs) {
    // You can define your own logic to determine trending blogs, e.g., based on view count or likes.
    final trendingBlogs = blogs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trending Blogs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingBlogs.length,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: BlogCard(blog: trendingBlogs[index], profileImage: getProfileImageForUser(index)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogList(List<Blog> blogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blogs.map((blog) {
        return BlogCard(blog: blog, profileImage: getProfileImageForUser(blogs.indexOf(blog)));
      }).toList(),
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(
          blog.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import '../add_blog/add_blog_screen.dart';
import '../auth/login_screen.dart';
import '../home/user_profile_screen.dart';
import '../my_blogs/my_blog_screen.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  // List of categories
  final List<String> categories = [
    'Technology',
    'Health',
    'Lifestyle',
    'Education',
    'Business',
    'Entertainment',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search blogs...',
                    hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],  // Light grey background
                    prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Handle category selection
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.blue[700],
                        ),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
            // Filter blogs based on search query
            final filteredBlogs = blogs.where((blog) {
              return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            // Get top 3 trending blogs (assuming blogs sorted by likes/views)
            List<Blog> trendingBlogs = filteredBlogs.take(3).toList();

            return ListView(
              padding: const EdgeInsets.all(15),
              children: [
                if (trendingBlogs.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Trending Blogs',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...trendingBlogs.map((blog) {
                        return BlogCard(
                          blog: blog,
                          profileImage: getProfileImageForUser(filteredBlogs.indexOf(blog)),
                        );
                      }).toList(),
                    ],
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'All Blogs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...filteredBlogs.map((blog) {
                  return BlogCard(
                    blog: blog,
                    profileImage: getProfileImageForUser(filteredBlogs.indexOf(blog)),
                  );
                }).toList(),
              ],
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
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(
          blog.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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
import 'package:intl/intl.dart';

import '../../models/blog.dart';
import '../add_blog/add_blog_screen.dart';
import '../auth/login_screen.dart';
import '../home/user_profile_screen.dart';
import '../my_blogs/my_blog_screen.dart';
import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
            // Filter blogs based on search query
            final filteredBlogs = blogs.where((blog) {
              return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredBlogs.length,
              itemBuilder: (context, index) {
                return BlogCard(
                  blog: filteredBlogs[index],
                  profileImage: getProfileImageForUser(index),
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
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
        ),
        title: Text(
          blog.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy hh:mm a').format(blog.createdAt)),
            const SizedBox(height: 10),
            Text(blog.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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



import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
            // Filter blogs based on search query
            final filteredBlogs = blogs.where((blog) {
              return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredBlogs.length,
              itemBuilder: (context, index) {
                return BlogCard(
                  blog: filteredBlogs[index],
                  profileImage: getProfileImageForUser(index),
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
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
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





import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                hintStyle: TextStyle(color: Colors.grey[600]),  // Light grey hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey background
                prefixIcon: Icon(Icons.search, color: Colors.blue[700]),  // Search icon color
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
            // Filter blogs based on search query
            final filteredBlogs = blogs.where((blog) {
              return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredBlogs.length,
              itemBuilder: (context, index) {
                return BlogCard(
                  blog: filteredBlogs[index],
                  profileImage: getProfileImageForUser(index),
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
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
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





import 'package:blogs_updated/models/blog.dart';

import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
            // Filter blogs based on search query
            final filteredBlogs = blogs.where((blog) {
              return blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  blog.desc.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredBlogs.length,
              itemBuilder: (context, index) {
                return BlogCard(
                  blog: filteredBlogs[index],
                  profileImage: getProfileImageForUser(index),
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
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
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





import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  // List of asset images for profile pictures
  final List<String> profileImages = [
    'assets/images/profile1.jpg',
    'assets/images/profile2.jpg',
    'assets/images/profile3.jpg',
    'assets/images/profile4.jpg',
    'assets/images/profile5.jpg',
  ];

  String getProfileImageForUser(int index) {
    return profileImages[index % profileImages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
                  profileImage: getProfileImageForUser(index),
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
  final String profileImage;
  const BlogCard({super.key, required this.blog, required this.profileImage});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage(profileImage),
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





import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
                return BlogCard(blog: blogs[index]);
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
  const BlogCard({super.key, required this.blog});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile2.jpg'), // Placeholder image
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





import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [

          PopupMenuButton(
              itemBuilder: (context)  => [
                PopupMenuItem(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                  },
                  child: const Text('My blogs'),
                ),
                 PopupMenuItem(
                    onTap: () async {
                      final auth = FirebaseAuth.instance;
                      await auth.signOut();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()),(route) => false);
                    },
                    child: const Text('Logout')
                )
              ],
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBlogScreen()));
        },
        child: const Icon(CupertinoIcons.plus),
      ),
    );
  }
}


import 'package:blogs_updated/models/blog.dart';
import 'package:blogs_updated/screens/add_blog/add_blog_screen.dart';
import 'package:blogs_updated/screens/auth/login_screen.dart';
import 'package:blogs_updated/screens/home/user_profile_screen.dart';
import 'package:blogs_updated/screens/home/widgets/item_blog.dart';
import 'package:blogs_updated/screens/my_blogs/my_blog_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
      IconButton(
      icon: Icon(Icons.account_circle),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
      },
      ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBlogScreen()));
                },
                child: const Text('My Blogs'),
              ),
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
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
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
                return BlogCard(blog: blogs[index]);
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
  const BlogCard({super.key, required this.blog});

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
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile2.jpg'), // Placeholder
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




 */