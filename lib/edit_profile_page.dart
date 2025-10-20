import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool isLoading = true;

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
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _selectedYear = data['year'];
        _interests = List<String>.from(data['interests'] ?? []);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'year': _selectedYear ?? '',
      'interests': _interests,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: AppColors.tealBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // go back to profile page
    }
  }

  void addInterest() {
    final newInterest = _interestController.text.trim();
    if (newInterest.isNotEmpty && !_interests.contains(newInterest)) {
      setState(() => _interests.add(newInterest));
      _interestController.clear();
    }
  }

  void removeInterest(String interest) {
    setState(() => _interests.remove(interest));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      appBar: AppBar(
        backgroundColor: AppColors.coral,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Name
                const Text(
                  "Name",
                  style: TextStyle(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Enter your full name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Name cannot be empty" : null,
                ),
                const SizedBox(height: 20),

                // 💬 Bio
                const Text(
                  "Bio",
                  style: TextStyle(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Tell something about yourself...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🎓 Year of Study
                const Text(
                  "Year of Study",
                  style: TextStyle(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    hint: const Text("Select your year"),
                    underline: const SizedBox(),
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() => _selectedYear = newValue);
                    },
                    items: yearOptions
                        .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // 🎯 Interests
                const Text(
                  "Interests",
                  style: TextStyle(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _interests
                      .map(
                        (interest) => Chip(
                      label: Text(interest),
                      backgroundColor:
                      AppColors.tealBlue.withOpacity(0.15),
                      labelStyle: const TextStyle(
                          color: AppColors.tealBlue),
                      deleteIcon: const Icon(Icons.close,
                          color: AppColors.tealBlue, size: 18),
                      onDeleted: () => removeInterest(interest),
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _interestController,
                        decoration: InputDecoration(
                          hintText: "Add a new interest",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onFieldSubmitted: (_) => addInterest(), // ✅ Enter key adds interest
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: addInterest, // ✅ Click adds interest
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 💾 Save Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveChanges();
                      }
                    },
                    icon:
                    const Icon(Icons.save, color: Colors.white, size: 20),
                    label: const Text(
                      "Save Changes",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
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