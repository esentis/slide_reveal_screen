import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slide_reveal_screen/slider_reveal_screen.dart';

void main() => runApp(MyApp());

/// Main app showcasing SlideRevealScreen with full-screen gestures
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late final SlideRevealController _controller;
  final PageController pageController = PageController();
  late final TabController tabController = TabController(
    length: 4,
    vsync: this,
  );
  bool isRightActive = false;
  bool isLeftActive = false;
  void _preparePageViewBoundaries() {
    // This method can be used to prepare any specific boundaries or settings
    // for the PageView if needed in the future.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Example: Set initial active state based on pageController
        if (pageController.hasClients) {
          isRightActive =
              pageController.page == 5; // Assuming 5 is the last page
          isLeftActive =
              pageController.page == 0; // Assuming 0 is the first page
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = SlideRevealController(vsync: this);
    _preparePageViewBoundaries();
    pageController.addListener(() {
      setState(() {
        // Example: Set initial active state based on pageController
        if (pageController.hasClients) {
          isRightActive =
              pageController.page == 4; // Assuming 5 is the last page
          isLeftActive =
              pageController.page == 0; // Assuming 0 is the first page
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlideRevealScreen Full-Screen Gestures Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Material(
        child: SlideRevealScreen(
          controller: _controller,
          enableFullScreenGestures: true,
          onProgressChanged: (progress) {
            log(
              'Progress: ${progress.value}, Side: ${progress.activeSide}, State: ${progress.state}',
            );
          },
          leftHiddenPage: LeftHiddenPage(controller: _controller),
          rightHiddenPage: RightHiddenPage(controller: _controller),
          leftWidgetVisibilityThreshold: 0.3,
          leftPlaceHolderWidget: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          rightWidgetVisibilityThreshold: 0.3,
          rightPlaceHolderWidget: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),

          isRightActive:
              tabController.index == 1
                  ? isRightActive
                      ? true
                      : false
                  : true, // Only show PageView when isRightActive is false,
          isLeftActive:
              tabController.index == 1
                  ? isLeftActive
                      ? true
                      : false
                  : true, // Only show LeftHiddenPage when isLeftActive is false
          child: MainContent(
            pageController: pageController,
            tabController: tabController,
          ),
        ),
      ),
    );
  }
}

/// Quick Actions Page - Left hidden page with interactive elements
class LeftHiddenPage extends StatelessWidget {
  const LeftHiddenPage({super.key, required SlideRevealController controller})
    : _controller = controller;
  final SlideRevealController _controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueAccent, Colors.blue],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _controller.close(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Try dragging left to close this page!\nAll buttons below are tappable.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      subtitle: 'Take a photo',
                      onTap: () => _showSnackBar(context, 'Camera opened!'),
                    ),
                    _buildActionCard(
                      icon: Icons.note_add,
                      title: 'New Note',
                      subtitle: 'Create note',
                      onTap: () => _showSnackBar(context, 'Note created!'),
                    ),
                    _buildActionCard(
                      icon: Icons.location_on,
                      title: 'Location',
                      subtitle: 'Share location',
                      onTap: () => _showSnackBar(context, 'Location shared!'),
                    ),
                    _buildActionCard(
                      icon: Icons.favorite,
                      title: 'Favorites',
                      subtitle: 'View favorites',
                      onTap: () => _showSnackBar(context, 'Favorites opened!'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Settings Menu - Right hidden page with scrollable content
class RightHiddenPage extends StatelessWidget {
  const RightHiddenPage({super.key, required SlideRevealController controller})
    : _controller = controller;
  final SlideRevealController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.green, Colors.teal],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _controller.close(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.settings, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Try dragging right to close this page!\nThis ListView is scrollable.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    _buildSettingsTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      trailing: Switch(value: true, onChanged: (value) {}),
                    ),

                    _buildSettingsTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy',
                      subtitle: 'Control your privacy settings',
                      onTap: () {},
                    ),

                    _buildSettingsTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark theme',
                      trailing: Switch(value: false, onChanged: (value) {}),
                    ),

                    _buildSettingsTile(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'Choose your preferred language',
                      onTap: () {},
                    ),

                    _buildSettingsTile(
                      icon: Icons.help,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: () {},
                    ),

                    _buildSettingsTile(
                      icon: Icons.info,
                      title: 'About',
                      subtitle: 'App version and information',
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),

                    // Demo content to show scrolling
                    ...List.generate(
                      10,
                      (index) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text('${index + 1}'),
                          ),
                          title: Text('Demo Setting ${index + 1}'),
                          subtitle: Text(
                            'This is a demo setting to show scrolling capability',
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// MainContent with different tabs showcasing various interaction types
class MainContent extends StatelessWidget {
  const MainContent({
    super.key,
    required this.pageController,
    required this.tabController,
  });
  final PageController pageController;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full-Screen Gestures Demo'),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'ListView'),
            Tab(icon: Icon(Icons.view_carousel), text: 'PageView'),
            Tab(icon: Icon(Icons.touch_app), text: 'Buttons'),
            Tab(icon: Icon(Icons.info), text: 'Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListViewTab(),
          PageViewTab(pageViewController: pageController),
          ButtonsTab(),
          InfoTab(),
        ],
      ),
    );
  }
}

/// Tab 1: ListView demonstration
class ListViewTab extends StatelessWidget {
  const ListViewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: const Text(
            '📱 Try vertical scrolling (works normally) and horizontal dragging (reveals pages)',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 50,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text('${index + 1}'),
                  ),
                  title: Text('List Item ${index + 1}'),
                  subtitle: Text(
                    'This item is fully tappable • Scroll works normally',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tapped item ${index + 1} menu'),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped item ${index + 1}')),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tab 2: PageView demonstration (only shows when isRightActive is false)
class PageViewTab extends StatelessWidget {
  const PageViewTab({required this.pageViewController, super.key});
  final PageController pageViewController;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade50,
          child: const Text(
            '🔄 This tab would show PageView demo when isRightActive: false\n(Right swipes → PageView, Left swipes → Slide reveal)',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: pageViewController,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pages, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Page ${index + 1}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Swipe horizontally to navigate',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tab 3: Buttons and interactive elements
class ButtonsTab extends StatefulWidget {
  const ButtonsTab({super.key});

  @override
  State<ButtonsTab> createState() => _ButtonsTabState();
}

class _ButtonsTabState extends State<ButtonsTab> {
  int _counter = 0;
  bool _isToggled = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🎯 All these buttons work normally while horizontal dragging reveals pages',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Counter section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Counter Demo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_counter',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => _counter--),
                        child: const Icon(Icons.remove),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => _counter = 0),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => _counter++),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Toggle section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Toggle Demo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Toggle Switch'),
                    subtitle: Text(_isToggled ? 'ON' : 'OFF'),
                    value: _isToggled,
                    onChanged: (value) => setState(() => _isToggled = value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Various button types
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Button Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _showMessage('Elevated Button'),
                        child: const Text('Elevated'),
                      ),
                      OutlinedButton(
                        onPressed: () => _showMessage('Outlined Button'),
                        child: const Text('Outlined'),
                      ),
                      TextButton(
                        onPressed: () => _showMessage('Text Button'),
                        child: const Text('Text'),
                      ),
                      IconButton(
                        onPressed: () => _showMessage('Icon Button'),
                        icon: const Icon(Icons.favorite),
                      ),
                      FloatingActionButton.small(
                        onPressed: () => _showMessage('FAB'),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$message tapped!')));
  }
}

/// Tab 4: Information about the demo
class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎉 Full-Screen Gestures Demo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This demo showcases the new enableFullScreenGestures feature:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    '✅ Horizontal drags from anywhere reveal hidden pages',
                  ),
                  _buildInfoItem(
                    '✅ Vertical scrolling works normally (ListView)',
                  ),
                  _buildInfoItem(
                    '✅ All tap events work normally (buttons, navigation)',
                  ),
                  _buildInfoItem(
                    '✅ PageView compatibility (when isRightActive: false)',
                  ),
                  _buildInfoItem(
                    '✅ Revealed pages can be dragged back to close',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 Try These Gestures:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildGestureItem(
                    '➡️ Drag right',
                    'Reveals blue Quick Actions page',
                  ),
                  _buildGestureItem(
                    '⬅️ Drag left',
                    'Reveals green Settings page',
                  ),
                  _buildGestureItem(
                    '⬅️ From revealed page',
                    'Drag back to close',
                  ),
                  _buildGestureItem(
                    '⬆️⬇️ Vertical scroll',
                    'Works normally in ListView/Settings',
                  ),
                  _buildGestureItem(
                    '👆 Tap anywhere',
                    'All buttons and interactions work',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚙️ Configuration Used:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SlideRevealScreen(\n'
                      '  enableFullScreenGestures: true,\n'
                      '  isLeftActive: true,\n'
                      '  isRightActive: true,\n'
                      '  leftWidgetVisibilityThreshold: 0.3,\n'
                      '  rightWidgetVisibilityThreshold: 0.3,\n'
                      '  // ... other properties\n'
                      ')',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildGestureItem(String gesture, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              gesture,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
