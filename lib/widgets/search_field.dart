import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WeatherSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final VoidCallback onDirectionsPressed;
  final List<Map<String, dynamic>> suggestions;
  final Function(Map<String, dynamic>) onSuggestionSelected;

  const WeatherSearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onDirectionsPressed,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search location...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
              suffixIcon: IconButton(
                icon: Icon(Icons.directions, color: Colors.white.withOpacity(0.6)),
                onPressed: onDirectionsPressed,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: onSubmitted,
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  title: Text(
                    suggestion['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    suggestion['country'],
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  onTap: () => onSuggestionSelected(suggestion),
                ).animate().fadeIn().slideY(
                  begin: 0.1,
                  duration: Duration(milliseconds: 200 + (index * 50)),
                );
              },
            ),
          ),
      ],
    );
  }
}
