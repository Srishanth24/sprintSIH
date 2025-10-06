import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'upload_screen.dart';
import 'records_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final api = Provider.of<ApiService>(context, listen: false);
    
    try {
      final data = await api.getDashboard(auth.token!);
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              child: Text(
                                (_dashboardData?['user']?['name'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${_dashboardData?['user']?['name'] ?? 'User'}!',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  Text(
                                    _dashboardData?['user']?['email'] ?? '',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildQuickActionCard(
                          'Upload File',
                          Icons.cloud_upload,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UploadScreen()),
                          ),
                        ),
                        _buildQuickActionCard(
                          'Manage Records',
                          Icons.list,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RecordsScreen()),
                          ),
                        ),
                        _buildQuickActionCard(
                          'Analytics',
                          Icons.analytics,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                          ),
                        ),
                        _buildQuickActionCard(
                          'Settings',
                          Icons.settings,
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings coming soon!')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Records',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ..._buildRecentRecords(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRecentRecords() {
    final records = _dashboardData?['records'] as List? ?? [];
    if (records.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No records yet. Start by uploading a file or creating a record!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ];
    }

    return records.take(3).map((record) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.description),
          title: Text(record['title'] ?? 'Untitled'),
          subtitle: Text(
            'Created: ${record['created_at']?.toString().split('T')[0] ?? 'Unknown'}',
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordsScreen()),
          ),
        ),
      );
    }).toList();
  }
}