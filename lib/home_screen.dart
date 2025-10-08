import 'package:flutter/material.dart';
import 'theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haifora'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline example
            Text(
              'Welcome to Haifora!',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),

            // Body text example
            Text(
              'A playful and social way to connect with your university community. '
                  'This screen shows how the Haifora theme looks in light and dark mode.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Buttons
            ElevatedButton(
              onPressed: () {},
              child: const Text('Create Event'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: HaiforaTheme.tealBlue,
              ),
              child: const Text('Find Friends'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: HaiforaTheme.warmYellow,
                foregroundColor: Colors.black,
              ),
              child: const Text('Join Hangout'),
            ),

            const Spacer(),

            // Footer note
            Center(
              child: Text(
                'Made with 💛 by the Haifora Team',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
