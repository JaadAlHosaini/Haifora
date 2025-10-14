import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AppColors {
  static const Color darkNavy = Color(0xFF2C3A47);
  static const Color tealBlue = Color(0xFF5CA4A9);
  static const Color coral = Color(0xFFF18F01);
  static const Color warmYellow = Color(0xFFF6AE2D);
  static const Color beigeBackground = Color(0xFFFAF3E0);
  static const Color darkBackground = Color(0xFF1E1B16);
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  String? _selectedYear;
  List<String> _interests = [];
  String _photoUrl = '';
  XFile? _pickedFile;

  bool _isSaving = false;
  bool isLoading = true;
  double _uploadProgress = 0; // 👈 visible progress %
  bool _isUploading = false;

  final List<String> yearOptions = [
    'Year 1',
    'Year 2',
    'Year 3',
    'Year 4',
    'Year 5',
    'Year 6',
    'Year 7',
    'Postgraduate',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _selectedYear = (data['year'] != null &&
            yearOptions.contains(data['year']))
            ? data['year']
            : null;
        _interests = List<String>.from(data['interests'] ?? []);
        _photoUrl = data['photoUrl'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked != null) {
      setState(() => _pickedFile = picked);
    }
  }

  Future<String> _uploadImage(XFile file) async {
    final user = FirebaseAuth.instance.currentUser!;
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${user.uid}.jpg');

    setState(() {
      _uploadProgress = 0;
      _isUploading = true;
    });

    UploadTask uploadTask;
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    } else {
      uploadTask = ref.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
    }

    // Listen for progress events
    uploadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() => _uploadProgress = progress);
    });

    await uploadTask.whenComplete(() {});
    final url = await ref.getDownloadURL();

    setState(() {
      _uploadProgress = 0;
      _isUploading = false;
    });

    return url;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser!;
    setState(() => _isSaving = true);

    String imageUrl = _photoUrl;

    try {
      // Upload image (show progress)
      if (_pickedFile != null) {
        imageUrl = await _uploadImage(_pickedFile!);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'year': _selectedYear ?? '',
        'interests': _interests,
        'photoUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile updated successfully!')),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.code}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addInterest() {
    final interest = _interestController.text.trim();
    if (interest.isNotEmpty && !_interests.contains(interest)) {
      setState(() {
        _interests.add(interest);
        _interestController.clear();
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() => _interests.remove(interest));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.coral,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _pickedFile != null
                          ? (kIsWeb
                          ? NetworkImage(_pickedFile!.path)
                          : FileImage(File(_pickedFile!.path))
                      as ImageProvider)
                          : (_photoUrl.isNotEmpty
                          ? NetworkImage(_photoUrl)
                          : null),
                      child: (_pickedFile == null && _photoUrl.isEmpty)
                          ? const Icon(Icons.person,
                          size: 60, color: Colors.white)
                          : null,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.coral,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),

              // ✅ Show upload progress bar dynamically
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 6,
                        color: AppColors.coral,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploading: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: yearOptions.contains(_selectedYear)
                    ? _selectedYear
                    : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Year of Study',
                ),
                items: yearOptions
                    .map((y) => DropdownMenuItem(
                  value: y,
                  child: Text(y),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedYear = v),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _interests
                    .map((i) => Chip(
                  label: Text(i),
                  onDeleted: () => _removeInterest(i),
                  backgroundColor:
                  AppColors.tealBlue.withOpacity(0.2),
                  deleteIconColor: AppColors.tealBlue,
                ))
                    .toList(),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _interestController,
                      decoration: const InputDecoration(
                        labelText: 'Add Interest',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addInterest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealBlue,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
