// lib/main.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/flower_provider.dart';
import 'providers/drone_provider.dart';

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
      title: 'Pollination Research App',
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
    const DroneScreen(),
    const AnalyticsScreen(),
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
        title: const Text('Pollination Research App'),
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
              leading: const Icon(Icons.air),
              title: const Text('Drone'),
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
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(4);
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
          BottomNavigationBarItem(icon: Icon(Icons.air), label: 'Drone'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'Analytics'),
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
            const SnackBar(content: Text('Open camera scanner (placeholder).')),
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
            'Welcome to Pollination Research App',
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
                    title: const Text('Local Flowers'),
                    subtitle: Text('$flowerCount tracked species'),
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
                    leading: const Icon(Icons.bug_report, color: Colors.green),
                    title: const Text('Bee Study'),
                    subtitle: const Text('Latest bee activity snapshots'),
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
            icon: Icons.bug_report,
            title: 'Bee Population Study',
            subtitle: 'Ongoing research on bee pollination patterns.',
          ),
          HomeFeatureCard(
            icon: Icons.local_florist,
            title: 'Flower Diversity',
            subtitle: 'Tracking flower species diversity in your area.',
          ),
          HomeFeatureCard(
            icon: Icons.map,
            title: 'Field Mapping',
            subtitle: 'Log field observations and site locations.',
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
              title: 'Pumpkin Pollination Data',
              description: 'Detailed stats on pumpkin reproductive success.'),
          ResearchItem(
              title: 'Bee Behavior Patterns',
              description: 'Tracking bee movement and foraging behavior.'),
          ResearchItem(
              title: 'Flower Species Analysis',
              description: 'Comparing pollinator attraction across species.'),
          const SizedBox(height: 12),
          const Text('Tracked Flowers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (flowers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child:
                  Center(child: Text('No flowers loaded — pull to refresh.')),
            )
          else
            ...flowers.map((f) => Card(
                  child: ListTile(
                    leading: Icon(Icons.local_florist, color: Colors.green),
                    title: Text(f.name ?? 'Unknown'),
                    subtitle: Text(f.species ?? ''),
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
              title: Text('Open Field Map (placeholder)'),
              subtitle: Text('Tap to view map and site markers.'),
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

// -------------------- Drone --------------------

class DroneScreen extends StatelessWidget {
  const DroneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final droneProv = Provider.of<DroneProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.air, color: Colors.green),
              title: Text('Drone Status'),
              subtitle: Text(droneProv.droneStatus ?? 'Unknown'),
              trailing: TextButton(
                onPressed: () {
                  if (droneProv.isFlying == true) {
                    droneProv.stop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Drone landing...')));
                  } else {
                    droneProv.start();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Drone taking off...')));
                  }
                },
                child: Text(droneProv.isFlying == true ? 'Land' : 'Launch'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.timeline, color: Colors.green),
              title: Text('Last Telemetry'),
              subtitle: Text(droneProv.lastTelemetry ?? 'No telemetry yet'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Telemetry details (placeholder)')));
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.flight, size: 80, color: Colors.green),
                  SizedBox(height: 8),
                  Text(
                    'Live map & flight path coming soon',
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
          const Text('Analytics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.pie_chart, color: Colors.green),
              title: Text('Pollination Success Rate'),
              subtitle: Text('Current: 72% (sample)'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Open detailed chart (placeholder)')));
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.show_chart, color: Colors.green),
              title: Text('Bee Visits / Day'),
              subtitle: Text('Avg: 120 visits'),
            ),
          ),
          
          // flower power
          Card(
            child: ListTile(
               leading: Icon(Icons.local_florist, color: Colors.green),
              title: Text('Top Flower Attractiveness'),
              subtitle: Text('1) Flower A\n2) Flower B\n3) Flower C'),
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
    'Bee Population Study',
    'Flower Diversity',
    'Field Mapping',
    'Pumpkin Pollination Data',
    'Bee Behavior Patterns',
    'Flower Species Analysis'
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
