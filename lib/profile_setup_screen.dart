import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> faculties = [
    'BUILT ENVIRONMENT',
    'LANGUAGES AND LINGUISTICS',
    'PHARMACY',
    'ENGINEERING',
    'EDUCATION',
    'DENTISTRY',
    'BUSINESS AND ECONOMICS',
    'MEDICINE',
    'SCIENCE',
    'COMPUTER SCIENCE AND INFORMATION TECHNOLOGY',
    'ARTS AND SOCIAL SCIENCES',
    'CREATIVE ARTS',
    'LAW',
    'SPORT & EXERCISE SCIENCES',
  ];

  final List<String> interestsList = [
    'Music',
    'Sports',
    'Gaming',
    'Tech',
    'Travel',
    'Movies',
    'Art',
    'Cooking',
    'Fitness',
    'Reading',
    'Photography',
    'Volunteering',
    'Study Groups',
    'Hangouts',
  ];

  String? selectedFaculty;
  final List<String> selectedInterests = [];
  bool _isLoading = false;

  void _toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedFaculty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your faculty')),
      );
      return;
    }

    if (selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one interest')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user signed in');

      final userDoc =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.set({
        'uid': user.uid,
        'name': user.displayName ?? '', // ✅ Added for your teammate
        'email': user.email,
        'faculty': selectedFaculty,
        'interests': selectedInterests,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            onToggleTheme: () {},
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Select Your Faculty',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // 🔹 Faculty Dropdown
                DropdownButtonFormField<String>(
                  value: selectedFaculty,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Faculty',
                  ),
                  items: faculties
                      .map((faculty) => DropdownMenuItem(
                    value: faculty,
                    child: Text(faculty),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedFaculty = value),
                  validator: (value) =>
                  value == null ? 'Please select your faculty' : null,
                ),

                const SizedBox(height: 32),

                Text(
                  'Select Your Interests',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // 🔹 Interests Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interestsList.map((interest) {
                    final isSelected = selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (_) => _toggleInterest(interest),
                      selectedColor:
                      theme.colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: theme.colorScheme.primary,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),

                // 🔹 Save Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Save Profile'),
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
