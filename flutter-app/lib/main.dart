// lib/main.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/flower_provider.dart';
import 'providers/drone_provider.dart';
import 'screens/predictive_analytics_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlowerProvider()..loadFlowers()),
        ChangeNotifierProvider(
            create: (_) => DroneProvider()..initializeDrone()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pollination Assistant',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const ResearchScreen(),
    const RobotScreen(),
    const AnalyticsScreen(),
    const PredictiveAnalyticsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSearch() {
    showSearch(context: context, delegate: DataSearch());
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('No new notifications — all chill for now.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pollination Assistant'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _openSearch),
          IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: _showNotifications),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text('Research'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('Robot Control'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Predictive Analytics'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(5);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Now'),
              onTap: () {
                Navigator.pop(context);
                final flowerProv =
                    Provider.of<FlowerProvider>(context, listen: false);
                final droneProv =
                    Provider.of<DroneProvider>(context, listen: false);
                flowerProv.loadFlowers();
                droneProv.syncStatus();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync started...')));
              },
            )
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Research'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Robot'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: 'Predict'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Field scan initialized (placeholder).')),
          );
        },
        label: const Text('Scan Field'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// -------------------- Home --------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowerProv = Provider.of<FlowerProvider>(context);
    final flowerCount = (flowerProv.flowers).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Smart Pollination Research System',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.grass, color: Colors.green),
                    title: const Text('Pumpkin Crops'),
                    subtitle: Text('$flowerCount monitored plants'),
                    onTap: () {
                      final parent =
                          context.findAncestorStateOfType<_MainScreenState>();
                      parent?._onItemTapped(1);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.smart_toy, color: Colors.green),
                    title: const Text('Robot Status'),
                    subtitle: const Text('Pollination automation metrics'),
                    onTap: () {
                      final parent =
                          context.findAncestorStateOfType<_MainScreenState>();
                      parent?._onItemTapped(3);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HomeFeatureCard(
            icon: Icons.smart_toy,
            title: 'Artificial Pollination System',
            subtitle: 'Humanoid robot-assisted pollination for pumpkin crops.',
          ),
          HomeFeatureCard(
            icon: Icons.local_florist,
            title: 'Crop Health Monitoring',
            subtitle: 'Track flowering success and pollination efficiency.',
          ),
          HomeFeatureCard(
            icon: Icons.map,
            title: 'Field Mapping',
            subtitle: 'Deploy and navigate robot across field locations.',
          ),
        ],
      ),
    );
  }
}

class HomeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const HomeFeatureCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Open $title (placeholder)')));
        },
      ),
    );
  }
}

// -------------------- Research --------------------

class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    await Provider.of<FlowerProvider>(context, listen: false).loadFlowers();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Research data refreshed')));
  }

  @override
  Widget build(BuildContext context) {
    final flowerProv = Provider.of<FlowerProvider>(context);
    final flowers = flowerProv.flowers;

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Research Categories',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResearchItem(
              title: 'Pumpkin Pollination Efficiency',
              description:
                  'Metrics on reproductive success with robot-assisted pollination.'),
          ResearchItem(
              title: 'Robot Deployment Patterns',
              description:
                  'Optimal navigation routes and scheduling for field coverage.'),
          ResearchItem(
              title: 'Flowering Stage Analysis',
              description:
                  'Timing and identification of optimal pollination windows.'),
          const SizedBox(height: 12),
          const Text('Monitored Pumpkin Crops',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (flowers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('No crops loaded — pull to refresh.')),
            )
          else
            ...flowers.map((f) => Card(
                  child: ListTile(
                    leading: Icon(Icons.local_florist, color: Colors.green),
                    title: Text(f.name),
                    subtitle: Text(f.species),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Open ${f.name} details')));
                    },
                  ),
                )),
          const SizedBox(height: 24),
          const Text('Field Map',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.map, color: Colors.green),
              title: Text('Field Deployment Map'),
              subtitle: Text('View robot deployment zones and coverage areas.'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Map view (placeholder)')));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ResearchItem extends StatelessWidget {
  final String title;
  final String description;

  const ResearchItem(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Open $title (placeholder)')));
        },
      ),
    );
  }
}

// -------------------- Robot Control --------------------

class RobotScreen extends StatelessWidget {
  const RobotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final droneProv = Provider.of<DroneProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.smart_toy, color: Colors.green),
              title: Text('Robot Status'),
              subtitle: Text(droneProv.droneStatus ?? 'Idle'),
              trailing: TextButton(
                onPressed: () {
                  if (droneProv.isFlying == true) {
                    droneProv.stop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Robot returning to dock...')));
                  } else {
                    droneProv.start();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Robot deployment initiated...')));
                  }
                },
                child: Text(droneProv.isFlying == true ? 'Stop' : 'Deploy'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.timeline, color: Colors.green),
              title: Text('Last Operation'),
              subtitle: Text(droneProv.lastTelemetry ?? 'No operations yet'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Operation details (placeholder)')));
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.smart_toy, size: 80, color: Colors.green),
                  SizedBox(height: 8),
                  Text(
                    'Robot operational dashboard coming soon',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Analytics --------------------

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('Analytics Dashboard',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.pie_chart, color: Colors.green),
              title: Text('Pollination Success Rate'),
              subtitle: Text('Current: 87% (robot-assisted)'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Open detailed chart (placeholder)')));
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.show_chart, color: Colors.green),
              title: Text('Robot Deployment Hours'),
              subtitle: Text('Weekly: 42 hours operational'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.local_florist, color: Colors.green),
              title: Text('Crop Pollination Coverage'),
              subtitle: Text(
                  '1) Field Zone A: 95%\n2) Field Zone B: 88%\n3) Field Zone C: 92%'),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Profile --------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool offlineMode = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text('User Profile', style: TextStyle(fontSize: 22)),
          const Text('Manage your account and preferences.'),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Offline Field Mode'),
            subtitle: const Text('Cache observations for offline use'),
            value: offlineMode,
            onChanged: (val) {
              setState(() => offlineMode = val);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('Offline mode ${val ? 'enabled' : 'disabled'}')));
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<FlowerProvider>(context, listen: false).exportData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Export started (placeholder)')));
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Export Data'),
          ),
        ],
      ),
    );
  }
}

// -------------------- Search --------------------

class DataSearch extends SearchDelegate<String> {
  final List<String> data = [
    'Artificial Pollination System',
    'Crop Health Monitoring',
    'Field Mapping',
    'Pumpkin Pollination Efficiency',
    'Robot Deployment Patterns',
    'Flowering Stage Analysis'
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Selected: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = data
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index]),
        onTap: () {
          query = suggestionList[index];
          showResults(context);
        },
      ),
    );
  }
}
