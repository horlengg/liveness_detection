

import 'package:flutter/material.dart';
import 'package:sample_liveness_app/pages/face_anti_spoofing_page.dart';
import 'package:sample_liveness_app/pages/liveness_check_page.dart';
import 'package:sample_liveness_app/pages/mask_detection_page.dart';
import 'package:sample_liveness_app/widgets/button.dart';

void main() async {
  runApp(const SampleLivenessApp());
}

class SampleLivenessApp extends StatelessWidget {
  const SampleLivenessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        
        switch (settings.name) {
          case '/':
            page = const HomePage();
            break;
          case '/do_liveness':
            page = const LivenessCheckPage();
          case '/do_face_anti_spoofing':
            page = const FaceAntiSpoofingPage();
          case '/do_mask_detection':
            page = const MaskDetectionPage();
            break;
          // case '/done':
          //   page = const PageDone();
          //   break;
          default:
            page = const HomePage();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // slide from right
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC7D9E9),
      appBar: AppBar(
        title: Text("Sample Liveness Check",style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF035F9E),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              SizedBox(height: 20),

              AppButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/do_liveness");
                },
                label: "Start Liveness Detection",
                radius: 0,
              ),
              AppButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/do_mask_detection");
                },
                label: "Start Mask Detection",
                radius: 0,
              ),
              AppButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/do_face_anti_spoofing");
                },
                label: "Start Face Anti Spoofing",
                radius: 0,
              ),


            ],
          ),
        ),
      ),
    );
  }
}


class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  const CustomPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // No animation for first route
    if (route.settings.name == '/') return child;

    // Example: slide from right + fade
    final tween = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOut));

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}