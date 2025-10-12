import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onToggleTheme;

  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haifora Theme Preview'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Text(
                isDarkMode ? 'Dark Mode' : 'Light Mode',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildColorTile('Primary', colorScheme.primary),
            _buildColorTile('Secondary', colorScheme.secondary),
            _buildColorTile('Tertiary', colorScheme.tertiary),
            _buildColorTile('Background', colorScheme.background),
            _buildColorTile('Surface', colorScheme.surface),
            _buildColorTile('Error', colorScheme.error),
            const Divider(height: 32),
            Text(
              'Sample Text Styles:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
            Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
            Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
            Text('Display Small',
                style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTile(String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      height: 50,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
