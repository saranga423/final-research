// lib/main.dart
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlowerProvider()..loadFlowers()),
        ChangeNotifierProvider(
            create: (_) => DroneProvider()..initializeDrone()),
        ChangeNotifierProvider(
            create: (_) => EnvironmentProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(
            create: (_) => AnalyticsProvider()..loadAnalytics()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/* ============================================================
   APP ROOT
============================================================ */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pollination Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const MainScreen(),
    );
  }
}

/* ============================================================
   MAIN SHELL
============================================================ */

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ResearchScreen(),
    RobotScreen(),
    AnalyticsScreen(),
    AnticipatoryDecisionScreen(),
    EnvironmentalMonitoringScreen(),
    PredictiveModelScreen(),
    TaskManagementScreen(),
    ProfileScreen(),
    CloudScreen(),
    ReadinessScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AlertProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pollination Assistant'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () => _showAlerts(context),
              ),
              if (alerts.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${alerts.unreadCount}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(onNavigate: (i) {
        Navigator.pop(context);
        setState(() => _index = i);
      }),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.science), label: 'Research'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'Robot'),
          NavigationDestination(
              icon: Icon(Icons.analytics), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.psychology), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'Env'),
          NavigationDestination(icon: Icon(Icons.model_training), label: 'ML'),
          NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.cloud_queue), label: 'Cloud'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Readiness'),
        ],
      ),
    );
  }

  void _showAlerts(BuildContext context) {
    final alerts = context.read<AlertProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) => AlertsSheet(),
    );
    alerts.markAllRead();
  }
}

/* ============================================================
   MODELS
============================================================ */

class Flower {
  final String id;
  final String name;
  final int ageHours;
  final double temperature;
  final double humidity;
  final double pollenViability;
  final bool isReceptive;
  final String location;
  final DateTime lastChecked;

  Flower({
    required this.id,
    required this.name,
    required this.ageHours,
    required this.temperature,
    required this.humidity,
    required this.pollenViability,
    required this.isReceptive,
    required this.location,
    required this.lastChecked,
  });
}

enum DecisionType { pollinate, delay, skip }

class PollinationDecision {
  final DecisionType decision;
  final double confidence;
  final String explanation;
  final List<String> factors;

  PollinationDecision({
    required this.decision,
    required this.confidence,
    required this.explanation,
    required this.factors,
  });
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.priority,
  });

  Task copyWith({bool? isCompleted}) {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority,
    );
  }
}

class Alert {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String severity;
  final String alertType; // 'optimal_pollination', 'rain_warning', 'humidity_warning', etc.
  final List<String> channels; // 'in_app', 'sms'
  bool isRead;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
    required this.alertType,
    this.channels = const ['in_app'],
    this.isRead = false,
  });
}

/* ============================================================
   PROVIDERS
============================================================ */

class FlowerProvider extends ChangeNotifier {
  final List<Flower> _flowers = [];
  List<Flower> get flowers => _flowers;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadFlowers() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _flowers.clear();

    final locations = ['Greenhouse A', 'Greenhouse B', 'Field 1', 'Field 2'];

    for (int i = 0; i < 12; i++) {
      final age = Random().nextInt(15) + 1;
      _flowers.add(
        Flower(
          id: 'flower_$i',
          name: 'Pumpkin Flower ${i + 1}',
          ageHours: age,
          temperature: 24 + Random().nextDouble() * 6,
          humidity: 50 + Random().nextDouble() * 25,
          pollenViability: age >= 6 && age <= 10
              ? 0.85 + Random().nextDouble() * 0.1
              : 0.3 + Random().nextDouble() * 0.2,
          isReceptive: age >= 6 && age <= 10,
          location: locations[Random().nextInt(locations.length)],
          lastChecked:
              DateTime.now().subtract(Duration(hours: Random().nextInt(3))),
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  PollinationDecision evaluate(Flower f) {
    List<String> factors = [];

    if (f.temperature < 20 || f.temperature > 32) {
      factors.add('Temperature outside optimal range');
    } else {
      factors.add('Temperature optimal');
    }

    if (f.humidity < 60 || f.humidity > 80) {
      factors.add('Humidity suboptimal');
    } else {
      factors.add('Humidity ideal');
    }

    factors.add(
        'Pollen viability: ${(f.pollenViability * 100).toStringAsFixed(0)}%');
    factors.add('Age: ${f.ageHours} hours');

    if (f.isReceptive && f.pollenViability > 0.8) {
      return PollinationDecision(
        decision: DecisionType.pollinate,
        confidence: 0.88 + Random().nextDouble() * 0.1,
        explanation: 'Optimal conditions detected - proceed with pollination',
        factors: factors,
      );
    }
    if (f.ageHours < 6) {
      return PollinationDecision(
        decision: DecisionType.delay,
        confidence: 0.6 + Random().nextDouble() * 0.15,
        explanation:
            'Flower not yet mature - wait ${6 - f.ageHours} more hours',
        factors: factors,
      );
    }
    return PollinationDecision(
      decision: DecisionType.skip,
      confidence: 0.75 + Random().nextDouble() * 0.1,
      explanation: 'Receptivity window has passed - mark for next cycle',
      factors: factors,
    );
  }

  Flower? getFlowerById(String id) {
    try {
      return _flowers.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
}

class DroneProvider extends ChangeNotifier {
  bool isActive = false;
  int battery = 85;
  String currentTask = 'Idle';
  int tasksCompleted = 0;
  double distanceTraveled = 0.0;

  void initializeDrone() => notifyListeners();

  void toggle() {
    isActive = !isActive;
    if (isActive) {
      currentTask = 'Scanning greenhouse...';
      battery = max(0, battery - 5);
      tasksCompleted++;
      distanceTraveled += Random().nextDouble() * 50;
    } else {
      currentTask = 'Idle';
    }
    notifyListeners();
  }

  void updateStatus(String task) {
    currentTask = task;
    battery = max(0, battery - 2);
    notifyListeners();
  }

  void rechargeBattery() {
    battery = 100;
    notifyListeners();
  }
}

class EnvironmentProvider extends ChangeNotifier {
  double temperature = 28;
  double humidity = 65;
  double lightIntensity = 850;
  double soilMoisture = 45;
  List<EnvironmentReading> history = [];

  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate history
    history.clear();
    for (int i = 24; i >= 0; i--) {
      history.add(
        EnvironmentReading(
          timestamp: DateTime.now().subtract(Duration(hours: i)),
          temperature: 26 + Random().nextDouble() * 4,
          humidity: 60 + Random().nextDouble() * 15,
          lightIntensity: 800 + Random().nextDouble() * 200,
        ),
      );
    }

    notifyListeners();
  }

  void refreshData() {
    temperature = 26 + Random().nextDouble() * 4;
    humidity = 60 + Random().nextDouble() * 15;
    lightIntensity = 800 + Random().nextDouble() * 200;
    soilMoisture = 40 + Random().nextDouble() * 20;
    notifyListeners();
  }
}

class EnvironmentReading {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double lightIntensity;

  EnvironmentReading({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
  });
}

class PredictionResult {
  final String flowerId;
  final String name;
  final double probability;
  final String recommendation;

  PredictionResult(
      this.flowerId, this.name, this.probability, this.recommendation);
}

class PredictionProvider extends ChangeNotifier {
  final List<PredictionResult> predictions = [];
  bool isTraining = false;
  double modelAccuracy = 0.0;

  void generate(List<Flower> flowers) {
    predictions.clear();
    for (final f in flowers) {
      final prob = f.isReceptive
          ? 0.82 + Random().nextDouble() * 0.15
          : 0.2 + Random().nextDouble() * 0.2;
      String rec;
      if (prob > 0.8) {
        rec = 'Pollinate now';
      } else if (prob > 0.5) {
        rec = 'Monitor closely';
      } else {
        rec = 'Wait for optimal time';
      }

      predictions.add(
        PredictionResult(f.id, f.name, prob, rec),
      );
    }
    modelAccuracy = 0.87 + Random().nextDouble() * 0.1;
    notifyListeners();
  }

  Future<void> trainModel() async {
    isTraining = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    modelAccuracy = 0.9 + Random().nextDouble() * 0.08;
    isTraining = false;
    notifyListeners();
  }
}

class AnalyticsDataPoint {
  final String label;
  final double value;
  final double confidence;

  AnalyticsDataPoint(this.label, this.value, this.confidence);
}

class AnalyticsProvider extends ChangeNotifier {
  final List<AnalyticsDataPoint> successTrend = [];
  double averageConfidence = 0;
  int totalPollinations = 0;
  int successfulPollinations = 0;
  double successRate = 0;

  Future<void> loadAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 400));

    successTrend.clear();
    for (int i = 0; i < 12; i++) {
      successTrend.add(
        AnalyticsDataPoint(
          'M${i + 1}',
          65 + i.toDouble() * 1.5 + Random().nextDouble() * 5,
          0.75 + Random().nextDouble() * 0.2,
        ),
      );
    }

    averageConfidence = successTrend.fold<double>(
          0.0,
          (sum, p) => sum + p.confidence,
        ) /
        successTrend.length;

    totalPollinations = 450 + Random().nextInt(100);
    successfulPollinations = (totalPollinations * 0.82).round();
    successRate = successfulPollinations / totalPollinations;

    notifyListeners();
  }
}

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  Future<void> loadTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));

    _tasks.clear();
    _tasks.addAll([
      Task(
        id: 'task_1',
        title: 'Morning greenhouse inspection',
        description: 'Check all flowers in Greenhouse A',
        dueDate: DateTime.now().add(Duration(hours: 2)),
        isCompleted: false,
        priority: 'High',
      ),
      Task(
        id: 'task_2',
        title: 'Pollinate receptive flowers',
        description: 'Focus on flowers aged 6-10 hours',
        dueDate: DateTime.now().add(Duration(hours: 4)),
        isCompleted: false,
        priority: 'High',
      ),
      Task(
        id: 'task_3',
        title: 'Update environmental sensors',
        description: 'Calibrate temperature and humidity sensors',
        dueDate: DateTime.now().add(Duration(days: 1)),
        isCompleted: false,
        priority: 'Medium',
      ),
      Task(
        id: 'task_4',
        title: 'Review ML model performance',
        description: 'Analyze prediction accuracy from last week',
        dueDate: DateTime.now().add(Duration(days: 2)),
        isCompleted: true,
        priority: 'Low',
      ),
    ]);

    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] =
          _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      notifyListeners();
    }
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }
}

class AlertProvider extends ChangeNotifier {
  final List<Alert> _alerts = [];
  List<Alert> get alerts => _alerts;
  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  AlertProvider() {
    _generateInitialAlerts();
  }

  void _generateInitialAlerts() {
    _alerts.addAll([
      Alert(
        id: 'alert_1',
        title: 'Optimal Pollination Window',
        message: '12 flowers are in optimal receptivity window. Recommend pollination within next 2 hours.',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        severity: 'info',
        alertType: 'optimal_pollination',
        channels: ['in_app', 'sms'],
      ),
      Alert(
        id: 'alert_2',
        title: 'High Humidity Warning',
        message: 'Humidity at 89%. Pollination not recommended due to high humidity conditions.',
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        severity: 'warning',
        alertType: 'humidity_warning',
        channels: ['in_app', 'sms'],
      ),
      Alert(
        id: 'alert_3',
        title: 'Rain Warning',
        message: 'Rain forecasted in next 3 hours. Protect flowers and postpone pollination activities.',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
        severity: 'warning',
        alertType: 'rain_warning',
        channels: ['in_app', 'sms'],
      ),
      Alert(
        id: 'alert_4',
        title: 'Optimal Pollination Window',
        message: '8 flowers ready for pollination. Weather conditions are favorable.',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        severity: 'info',
        alertType: 'optimal_pollination',
        channels: ['in_app'],
      ),
    ]);
  }

  void addAlert(Alert alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }

  void markAllRead() {
    for (var alert in _alerts) {
      alert.isRead = true;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index].isRead = true;
      notifyListeners();
    }
  }
}

/* ============================================================
   SCREENS
============================================================ */

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowers = context.watch<FlowerProvider>().flowers;
    final drone = context.watch<DroneProvider>();
    final env = context.watch<EnvironmentProvider>();
    final tasks = context.watch<TaskProvider>();

    final receptiveFlowers = flowers.where((f) => f.isReceptive).length;
    final pendingTasks = tasks.pendingTasks.length;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<FlowerProvider>().loadFlowers();
        await context.read<EnvironmentProvider>().loadData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Dashboard Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 16),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_florist,
                  label: 'Total Flowers',
                  value: '${flowers.length}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'Receptive',
                  value: '$receptiveFlowers',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.task_alt,
                  label: 'Pending Tasks',
                  value: '$pendingTasks',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.battery_charging_full,
                  label: 'Battery',
                  value: '${drone.battery}%',
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Robot status
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Robot Status',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Divider(height: 24),
                  ListTile(
                    leading: Icon(
                      drone.isActive
                          ? Icons.play_circle_filled
                          : Icons.pause_circle_filled,
                      color: drone.isActive ? Colors.green : Colors.grey,
                    ),
                    title: Text(drone.isActive ? 'Active' : 'Idle'),
                    subtitle: Text(drone.currentTask),
                    trailing: Text('${drone.tasksCompleted} tasks'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Environmental snapshot
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Environment',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _EnvIndicator(
                        icon: Icons.thermostat,
                        label: 'Temp',
                        value: '${env.temperature.toStringAsFixed(1)}°C',
                      ),
                      _EnvIndicator(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '${env.humidity.toStringAsFixed(0)}%',
                      ),
                      _EnvIndicator(
                        icon: Icons.wb_sunny,
                        label: 'Light',
                        value: '${env.lightIntensity.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent flowers
          Text('Recent Flowers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          ...flowers.take(3).map((f) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: f.isReceptive ? Colors.green : Colors.grey,
                    child: Icon(Icons.local_florist,
                        color: Colors.white, size: 20),
                  ),
                  title: Text(f.name),
                  subtitle: Text('${f.location} • ${f.ageHours}h old'),
                  trailing: Text(
                    f.isReceptive ? 'Ready' : 'Not ready',
                    style: TextStyle(
                      color: f.isReceptive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EnvIndicator({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlowerProvider>();
    final flowers = provider.flowers;

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${flowers.length} Flowers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => provider.loadFlowers(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: flowers.length,
            itemBuilder: (context, index) {
              final f = flowers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _showFlowerDetails(context, f),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  f.isReceptive ? Colors.green : Colors.grey,
                              child: Icon(Icons.local_florist,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    f.location,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: f.isReceptive
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                f.isReceptive ? 'Receptive' : 'Not Ready',
                                style: TextStyle(
                                  color: f.isReceptive
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FlowerStat(Icons.access_time, '${f.ageHours}h'),
                            _FlowerStat(Icons.thermostat,
                                '${f.temperature.toStringAsFixed(1)}°C'),
                            _FlowerStat(Icons.water_drop,
                                '${f.humidity.toStringAsFixed(0)}%'),
                            _FlowerStat(Icons.science,
                                '${(f.pollenViability * 100).toStringAsFixed(0)}%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFlowerDetails(BuildContext context, Flower f) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FlowerDetailsSheet(flower: f),
    );
  }
}

class _FlowerStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _FlowerStat(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class FlowerDetailsSheet extends StatelessWidget {
  final Flower flower;

  const FlowerDetailsSheet({super.key, required this.flower});

  @override
  Widget build(BuildContext context) {
    final decision = context.read<FlowerProvider>().evaluate(flower);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          flower.isReceptive ? Colors.green : Colors.grey,
                      radius: 30,
                      child: Icon(Icons.local_florist,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(flower.name,
                              style: Theme.of(context).textTheme.headlineSmall),
                          Text(flower.location,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text('Flower Metrics',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _DetailRow('Age', '${flower.ageHours} hours'),
                _DetailRow('Temperature',
                    '${flower.temperature.toStringAsFixed(1)}°C'),
                _DetailRow(
                    'Humidity', '${flower.humidity.toStringAsFixed(1)}%'),
                _DetailRow('Pollen Viability',
                    '${(flower.pollenViability * 100).toStringAsFixed(0)}%'),
                _DetailRow(
                    'Receptive Status', flower.isReceptive ? 'Yes' : 'No'),
                _DetailRow('Last Checked', _formatTime(flower.lastChecked)),
                const Divider(height: 32),
                Text('AI Recommendation',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        _getDecisionColor(decision.decision).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getDecisionIcon(decision.decision),
                              color: _getDecisionColor(decision.decision)),
                          const SizedBox(width: 8),
                          Text(
                            _getDecisionLabel(decision.decision),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getDecisionColor(decision.decision),
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${(decision.confidence * 100).toStringAsFixed(0)}% confidence',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(decision.explanation),
                      const SizedBox(height: 12),
                      Text('Factors:',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      ...decision.factors.map((f) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 6),
                                const SizedBox(width: 8),
                                Text(f,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  Color _getDecisionColor(DecisionType type) {
    switch (type) {
      case DecisionType.pollinate:
        return Colors.green;
      case DecisionType.delay:
        return Colors.orange;
      case DecisionType.skip:
        return Colors.red;
    }
  }

  IconData _getDecisionIcon(DecisionType type) {
    switch (type) {
      case DecisionType.pollinate:
        return Icons.check_circle;
      case DecisionType.delay:
        return Icons.schedule;
      case DecisionType.skip:
        return Icons.cancel;
    }
  }

  String _getDecisionLabel(DecisionType type) {
    switch (type) {
      case DecisionType.pollinate:
        return 'Pollinate Now';
      case DecisionType.delay:
        return 'Wait';
      case DecisionType.skip:
        return 'Skip';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class RobotScreen extends StatelessWidget {
  const RobotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final drone = context.watch<DroneProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 80,
                    color: drone.isActive ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    drone.isActive ? 'Robot Active' : 'Robot Idle',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(drone.currentTask),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: drone.battery / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text('Battery: ${drone.battery}%'),
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
                  Text('Statistics',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Divider(height: 24),
                  _DetailRow('Tasks Completed', '${drone.tasksCompleted}'),
                  _DetailRow('Distance Traveled',
                      '${drone.distanceTraveled.toStringAsFixed(1)}m'),
                  _DetailRow('Current Status', drone.currentTask),
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: drone.toggle,
            icon: Icon(drone.isActive ? Icons.stop : Icons.play_arrow),
            label: Text(drone.isActive ? 'Stop Robot' : 'Start Robot'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: drone.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (drone.battery < 30)
            ElevatedButton.icon(
              onPressed: drone.rechargeBattery,
              icon: Icon(Icons.battery_charging_full),
              label: Text('Recharge Battery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
            ),
        ],
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();

    return RefreshIndicator(
      onRefresh: () => analytics.loadAnalytics(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Performance Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          '${(analytics.successRate * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text('Success Rate'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.psychology, color: Colors.blue, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          '${(analytics.averageConfidence * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text('Avg Confidence'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.agriculture, color: Colors.orange, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          '${analytics.totalPollinations}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text('Total'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.done_all, color: Colors.purple, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          '${analytics.successfulPollinations}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text('Successful'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Success Trend',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: ChartPainter(analytics.successTrend),
                      size: Size.infinite,
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
}

class ChartPainter extends CustomPainter {
  final List<AnalyticsDataPoint> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y =
          size.height - ((data[i].value - minValue) / range * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnticipatoryDecisionScreen extends StatelessWidget {
  const AnticipatoryDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlowerProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('AI Decision Support',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 8),
        Text('AI-powered pollination recommendations based on real-time data'),
        const SizedBox(height: 16),
        ...provider.flowers.map((f) {
          final d = provider.evaluate(f);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getDecisionColor(d.decision),
                        child: Icon(_getDecisionIcon(d.decision),
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.name,
                                style: Theme.of(context).textTheme.titleMedium),
                            Text(f.location,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getDecisionColor(d.decision).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(d.confidence * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: _getDecisionColor(d.decision),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(d.explanation),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: d.factors
                        .map((factor) => Chip(
                              label:
                                  Text(factor, style: TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getDecisionColor(DecisionType type) {
    switch (type) {
      case DecisionType.pollinate:
        return Colors.green;
      case DecisionType.delay:
        return Colors.orange;
      case DecisionType.skip:
        return Colors.red;
    }
  }

  IconData _getDecisionIcon(DecisionType type) {
    switch (type) {
      case DecisionType.pollinate:
        return Icons.check_circle;
      case DecisionType.delay:
        return Icons.schedule;
      case DecisionType.skip:
        return Icons.cancel;
    }
  }
}

class EnvironmentalMonitoringScreen extends StatelessWidget {
  const EnvironmentalMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final env = context.watch<EnvironmentProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Environmental Monitoring',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _EnvironmentGauge(
                  icon: Icons.thermostat,
                  label: 'Temperature',
                  value: env.temperature,
                  unit: '°C',
                  min: 20,
                  max: 35,
                  optimal: 28,
                  color: Colors.red,
                ),
                const Divider(height: 32),
                _EnvironmentGauge(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: env.humidity,
                  unit: '%',
                  min: 40,
                  max: 90,
                  optimal: 70,
                  color: Colors.blue,
                ),
                const Divider(height: 32),
                _EnvironmentGauge(
                  icon: Icons.wb_sunny,
                  label: 'Light Intensity',
                  value: env.lightIntensity,
                  unit: 'lux',
                  min: 600,
                  max: 1200,
                  optimal: 900,
                  color: Colors.orange,
                ),
                const Divider(height: 32),
                _EnvironmentGauge(
                  icon: Icons.grass,
                  label: 'Soil Moisture',
                  value: env.soilMoisture,
                  unit: '%',
                  min: 30,
                  max: 70,
                  optimal: 50,
                  color: Colors.brown,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: env.refreshData,
          icon: Icon(Icons.refresh),
          label: Text('Refresh Data'),
        ),
      ],
    );
  }
}

class _EnvironmentGauge extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final String unit;
  final double min;
  final double max;
  final double optimal;
  final Color color;

  const _EnvironmentGauge({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.optimal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final isOptimal = (value - optimal).abs() < (max - min) * 0.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Spacer(),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          minHeight: 12,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(
            isOptimal ? Colors.green : color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.toStringAsFixed(0)}$unit',
                style: Theme.of(context).textTheme.bodySmall),
            Text(isOptimal ? 'Optimal' : 'Suboptimal',
                style: TextStyle(
                  color: isOptimal ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                )),
            Text('${max.toStringAsFixed(0)}$unit',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class PredictiveModelScreen extends StatelessWidget {
  const PredictiveModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowers = context.watch<FlowerProvider>().flowers;
    final model = context.watch<PredictionProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('ML Prediction Model',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 8),
        Text('Machine learning-based pollination success prediction'),
        const SizedBox(height: 16),
        if (model.modelAccuracy > 0)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.model_training, size: 40, color: Colors.blue),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model Accuracy'),
                      Text(
                        '${(model.modelAccuracy * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: model.isTraining ? null : () => model.generate(flowers),
          icon: Icon(Icons.psychology),
          label:
              Text(model.isTraining ? 'Generating...' : 'Generate Predictions'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: model.isTraining ? null : () => model.trainModel(),
          icon: Icon(Icons.model_training),
          label: Text(model.isTraining ? 'Training Model...' : 'Train Model'),
        ),
        if (model.isTraining)
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
        const SizedBox(height: 16),
        if (model.predictions.isNotEmpty) ...[
          Text('Predictions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
        ],
        ...model.predictions.map(
          (p) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    p.probability > 0.7 ? Colors.green : Colors.grey,
                child: Text(
                  '${(p.probability * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text(p.name),
              subtitle: Text(p.recommendation),
              trailing: Icon(
                p.probability > 0.7 ? Icons.trending_up : Icons.trending_flat,
                color: p.probability > 0.7 ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final pending = taskProvider.pendingTasks;
    final completed = taskProvider.completedTasks;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Task Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.pending_actions,
                          color: Colors.orange, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '${pending.length}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text('Pending'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '${completed.length}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text('Completed'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (pending.isNotEmpty) ...[
          Text('Pending Tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          ...pending.map((task) => _TaskCard(task: task)),
        ],
        const SizedBox(height: 20),
        if (completed.isNotEmpty) ...[
          Text('Completed Tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          ...completed.map((task) => _TaskCard(task: task)),
        ],
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    final isOverdue =
        task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => taskProvider.toggleTask(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14),
                const SizedBox(width: 4),
                Text(
                  _formatDueDate(task.dueDate),
                  style: TextStyle(
                    color: isOverdue ? Colors.red : null,
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getPriorityColor(task.priority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.isNegative) return 'Overdue';
    if (diff.inHours < 1) return 'Due in ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Due in ${diff.inHours}h';
    return 'Due in ${diff.inDays}d';
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Research Administrator',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'admin@pollicare.com',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help & Support'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.red[50],
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class CloudScreen extends StatelessWidget {
  const CloudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final env = context.watch<EnvironmentProvider>();

    // Calculate flower counts (using existing data structure)
    final femaleFlowersReady = 8; // From dashboard data
    final maleFlowersReady = 12; // From dashboard data
    
    // Determine pollination status based on weather
    final hasHighHumidity = env.humidity > 85;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<EnvironmentProvider>().loadData();
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Welcome, Farmer!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Weather Alert Section
          if (hasHighHumidity)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300, width: 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade800, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weather Alert: High Humidity Detected!',
                          style: Theme.of(context)
                              .textTheme.titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pollination not recommended due to high humidity',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${env.humidity.toStringAsFixed(0)}% Humidity, ${env.temperature.toStringAsFixed(0)}°C',
                          style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.local_florist,
                      color: Colors.yellow.shade700, size: 40),
                ],
              ),
            ),

          // Pollination Readiness Section
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_florist,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Pollination Readiness',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Female Flowers Ready:',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$femaleFlowersReady',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Male Flowers Ready:',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$maleFlowersReady',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

          // Field Sensors Section
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Field Sensors',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: _EnvIndicator(
                            icon: Icons.water_drop,
                            label: 'Soil Moisture',
                            value: '${env.soilMoisture.toStringAsFixed(0)}%',
                          ),
                        ),
                        Expanded(
                          child: _EnvIndicator(
                            icon: Icons.thermostat,
                            label: 'Temp',
                            value: '${env.temperature.toStringAsFixed(1)}°C',
                          ),
                        ),
                        Expanded(
                          child: _EnvIndicator(
                            icon: Icons.wb_sunny,
                            label: 'Light',
                            value: '${env.lightIntensity.toStringAsFixed(0)}',
                          ),
                        ),
                        Expanded(
                          child: _EnvIndicator(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '${env.humidity.toStringAsFixed(0)}%',
                          ),
                        ),
                        Expanded(
                          child: _EnvIndicator(
                            icon: Icons.access_time,
                            label: 'Time',
                            value: _formatTime(DateTime.now()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recommended: Pollinate Tomorrow',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Farm Info Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Green Valley Farm',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Central Valley, CA',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
                Text(
                  'Last updated: ${_formatTime(DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ReadinessScreen extends StatefulWidget {
  const ReadinessScreen({super.key});

  @override
  State<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends State<ReadinessScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  Map<String, dynamic>? _readinessResult;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _image = File(image.path);
          _readinessResult = null; // Reset previous results
        });
        // Automatically analyze the image
        _analyzeReadiness();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _analyzeReadiness() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call to backend (CNN model inference)
    await Future.delayed(const Duration(seconds: 2));

    // Simulated readiness result
    final isReady = Random().nextBool();
    final result = {
      "flowerType": Random().nextBool() ? "Male" : "Female",
      "isReady": isReady,
      "confidenceScore": (0.65 + Random().nextDouble() * 0.33), // 0.65 to 0.98
      "status": isReady ? "Ready" : "Not Ready",
    };

    setState(() {
      _readinessResult = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        Text(
          'Flower Readiness Check',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        // Image Upload Section
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Flower Image',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const Divider(height: 24),
                if (_image == null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No image selected',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Readiness Result Section
        if (_isLoading)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing flower image...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          )
        else if (_readinessResult != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Readiness Result',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Divider(height: 24),
                  // Flower Type
                  ListTile(
                    leading: Icon(
                      _readinessResult!["flowerType"] == "Male"
                          ? Icons.male
                          : Icons.female,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Flower Type'),
                    trailing: Text(
                      _readinessResult!["flowerType"],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  const Divider(),
                  // Ready/Not Ready Status
                  ListTile(
                    leading: Icon(
                      _readinessResult!["isReady"]
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _readinessResult!["isReady"]
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: const Text('Status'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _readinessResult!["isReady"]
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _readinessResult!["status"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _readinessResult!["isReady"]
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  // Confidence Score
                  ListTile(
                    leading: Icon(Icons.analytics,
                        color: Theme.of(context).colorScheme.primary),
                    title: const Text('Confidence Score'),
                    trailing: Text(
                      '${(_readinessResult!["confidenceScore"] * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  // Progress indicator for confidence
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      value: _readinessResult!["confidenceScore"],
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Info Card
        Card(
          color: Colors.blue.shade50,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'CNN model inference combines image analysis with sensor fusion data for accurate readiness assessment.',
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AlertsSheet extends StatelessWidget {
  const AlertsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final alerts = alertProvider.alerts;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notifications & Alerts',
                  style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  if (alerts.isNotEmpty)
                    TextButton(
                      onPressed: () => alertProvider.markAllRead(),
                      child: const Text('Mark all read'),
                    ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: alerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No notifications',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: alert.isRead ? 1 : 2,
                        color: alert.isRead ? Colors.grey.shade50 : Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getSeverityColor(alert.severity),
                            child: Icon(
                              _getAlertTypeIcon(alert.alertType),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.title,
                                  style: TextStyle(
                                    fontWeight: alert.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!alert.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(alert.message),
                              const SizedBox(height: 8),
                              // Alert type badge
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getAlertTypeColor(alert.alertType)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getAlertTypeColor(alert.alertType)
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getAlertTypeLabel(alert.alertType),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: _getAlertTypeColor(alert.alertType),
                                      ),
                                    ),
                                  ),
                                  // Timestamp
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 12, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatTimestamp(alert.timestamp),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Channels
                              Row(
                                children: [
                                  Icon(Icons.notifications,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Channels: ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  ...alert.channels.map((channel) => Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              channel == 'sms'
                                                  ? Icons.sms
                                                  : Icons.phone_android,
                                              size: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              channel == 'sms' ? 'SMS' : 'In-App',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: false,
                          onTap: () {
                            // Mark as read when tapped
                            if (!alert.isRead) {
                              alertProvider.markAsRead(alert.id);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertTypeIcon(String alertType) {
    switch (alertType) {
      case 'optimal_pollination':
        return Icons.local_florist;
      case 'rain_warning':
        return Icons.umbrella;
      case 'humidity_warning':
        return Icons.water_drop;
      default:
        return Icons.notifications;
    }
  }

  Color _getAlertTypeColor(String alertType) {
    switch (alertType) {
      case 'optimal_pollination':
        return Colors.green;
      case 'rain_warning':
        return Colors.blue;
      case 'humidity_warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getAlertTypeLabel(String alertType) {
    switch (alertType) {
      case 'optimal_pollination':
        return 'Optimal Pollination Window';
      case 'rain_warning':
        return 'Rain Warning';
      case 'humidity_warning':
        return 'Humidity Warning';
      default:
        return 'Alert';
    }
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/* ============================================================
   DRAWER
============================================================ */

class AppDrawer extends StatelessWidget {
  final Function(int) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.local_florist, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  'Polli Care',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Smart Pollination System',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _item(context, 'Home', Icons.home, 0),
          _item(context, 'Research', Icons.science, 1),
          _item(context, 'Robot Control', Icons.smart_toy, 2),
          _item(context, 'Analytics', Icons.analytics, 3),
          const Divider(),
          _item(context, 'AI Decisions', Icons.psychology, 4),
          _item(context, 'Environment', Icons.cloud, 5),
          _item(context, 'ML Model', Icons.model_training, 6),
          _item(context, 'Tasks', Icons.task, 7),
          const Divider(),
          _item(context, 'Profile', Icons.person, 8),
          _item(context, 'Cloud', Icons.cloud_queue, 9),
          _item(context, 'Readiness', Icons.check_circle, 10),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String label, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => onNavigate(index),
    );
  }
}
