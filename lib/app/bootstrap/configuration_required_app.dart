import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class ConfigurationRequiredApp extends StatelessWidget {
  const ConfigurationRequiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      home: Scaffold(
        backgroundColor: const Color(0xFF050B16),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF111A2B),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF2E425F)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF9DD8FF),
                        size: 42,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Production configuration required',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'This release build was started without a NASA API key. Rebuild with --dart-define=NASA_API_KEY=your_key so the app can load NASA content without embedding a fallback secret.',
                        style: TextStyle(
                          color: Color(0xFFD5E1EF),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
