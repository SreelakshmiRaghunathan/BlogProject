import 'package:blogs_updated/models/blog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditBlogScreen extends StatefulWidget {
  final Blog blog;
  final String blogId;

  const EditBlogScreen({super.key, required this.blog, required this.blogId});

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.blog.title;
    _descController.text = widget.blog.desc;
  }

  Future<void> _updateBlog() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      await FirebaseFirestore.instance.collection('blogs').doc(widget.blogId).update({
        'title': _titleController.text,
        'desc': _descController.text,
      });

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog updated successfully')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Blog'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
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
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateBlog,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
