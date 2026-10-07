import 'package:flutter/material.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradientScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TestoraLogo(size: 92),
            SizedBox(height: 22),
            Text(
              'Testora',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Practice. Learn. Excel.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: .3,
              ),
            ),
            SizedBox(height: 64),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
