import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide_reveal_screen/slide_reveal_screen.dart';

void main() => runApp(MyApp());

/// Main app: pass in a left hidden page and a right hidden page.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slide Left and Right to reveal hidden pages',
      home: Material(
        child: SlideRevealScreen(
          leftHiddenPage: CreatePostPage(),
          rightHiddenPage: RightHiddenPage(),
          leftWidgetVisibilityThreshold: 0.3,
          leftPlaceHolderWidget: Center(
            child: Text('Control threshold to open left hidden page'),
          ),
          child: MainContent(),
        ),
      ),
    );
  }
}

/// HomeScreen displays a horizontal PageView for three inner tabs.
/// CreatePostPage is the left hidden page.
class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: Center(
        child: TextButton(
          onPressed: () {
            log('Create post button pressed');
          },
          child: const Text(
            'Create Post',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// RightHiddenPage is a placeholder for the right hidden page.
class RightHiddenPage extends StatelessWidget {
  const RightHiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: TextButton(
          onPressed: () {
            log('Right hidden page button pressed');
          },
          child: const Text(
            'Right Hidden Page',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
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
      backgroundColor: Colors.pinkAccent,
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
              'Slide from left or right'
              'as you swipe left or right',
            ),
          );
        }
        return Center(child: Text('Tab $index'));
      },
    );
  }
}
