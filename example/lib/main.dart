import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide_reveal_screen/slider_reveal_screen.dart';

void main() => runApp(MyApp());

/// Main app: pass in a left hidden page and a right hidden page.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late final SlideRevealController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SlideRevealController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slide Left and Right to reveal hidden pages',
      home: Material(
        child: SlideRevealScreen(
          controller: _controller,
          onProgressChanged: (progress) {},
          leftHiddenPage: LeftHiddenPage(controller: _controller),
          rightHiddenPage: RightHiddenPage(controller: _controller),
          leftWidgetVisibilityThreshold:
              0.5, // 50% of screen width should be visibile to activate actual widget
          leftPlaceHolderWidget: Center(child: Text('LEFT PLACEHOLDER')),
          rightWidgetVisibilityThreshold:
              0.5, // 50% of screen width should be visibile to activate actual widget
          rightPlaceHolderWidget: Center(child: Text('RIGHT PLACEHOLDER')),
          child: MainContent(),
        ),
      ),
    );
  }
}

/// HomeScreen displays a horizontal PageView for three inner tabs.
/// CreatePostPage is the left hidden page.
class LeftHiddenPage extends StatelessWidget {
  const LeftHiddenPage({super.key, required SlideRevealController controller})
    : _controller = controller;
  final SlideRevealController _controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'LEFT HIDDEN PAGE\nyou can either swipe to go back or tap the button',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                _controller.close();
              },
              child: const Text(
                'Get back',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// RightHiddenPage is a placeholder for the right hidden page.
class RightHiddenPage extends StatelessWidget {
  const RightHiddenPage({super.key, required SlideRevealController controller})
    : _controller = controller;
  final SlideRevealController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RIGHT HIDDEN PAGE\nyou can either swipe to go back or tap the button',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                _controller.close();
              },
              child: Text(
                'Get back',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MainContent builds a CupertinoTabScaffold with five tabs.
/// For the Home tab (index 0), it passes a callback to report inner tab changes.
class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: Colors.grey,
      tabBar: CupertinoTabBar(
        onTap: (index) {
          log('Tab $index selected');
          if (index == 2) {
            log('Create tab selected');
            // getIt<DraggableScreenController>().openLeft();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: 'Likes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 0) {
          return Center(
            child: Text(
              'Drag/Slide your finger from the right or left edge to reveal hidden pages',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          );
        }
        return Center(child: Text('Tab $index'));
      },
    );
  }
}
