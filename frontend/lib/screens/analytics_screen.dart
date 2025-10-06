import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<dynamic> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final api = Provider.of<ApiService>(context, listen: false);

    try {
      final records = await api.getRecords(auth.token!);
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildLineChart(),
                    const SizedBox(height: 24),
                    _buildBarChart(),
                    const SizedBox(height: 24),
                    _buildPieChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    final totalRecords = _records.length;
    final avgValue = _records.isNotEmpty
        ? _records
                .map((r) => (r['data']?['value'] as num?)?.toDouble() ?? 0.0)
                .reduce((a, b) => a + b) /
            _records.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.list,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalRecords',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text('Total Records'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 32,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    avgValue.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text('Average Value'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    if (_records.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(child: Text('No data available for line chart')),
        ),
      );
    }

    final spots = _records.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = (entry.value['data']?['value'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(index, value);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Value Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt() + 1}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(0));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
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

  Widget _buildBarChart() {
    if (_records.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(child: Text('No data available for bar chart')),
        ),
      );
    }

    final bars = _records.take(5).toList().asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = (entry.value['data']?['value'] as num?)?.toDouble() ?? 0.0;
      return BarChartGroupData(
        x: index.toInt(),
        barRods: [
          BarChartRodData(
            toY: value,
            color: Theme.of(context).colorScheme.secondary,
            width: 20,
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Values (Latest 5)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _records
                      .map((r) => (r['data']?['value'] as num?)?.toDouble() ?? 0.0)
                      .reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _records.length) {
                            return Text('R${value.toInt() + 1}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(0));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: bars,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_records.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(child: Text('No data available for pie chart')),
        ),
      );
    }

    // Group records by value ranges
    final ranges = <String, int>{
      'Low (0-25)': 0,
      'Medium (26-50)': 0,
      'High (51-75)': 0,
      'Very High (76+)': 0,
    };

    for (final record in _records) {
      final value = (record['data']?['value'] as num?)?.toDouble() ?? 0.0;
      if (value <= 25) {
        ranges['Low (0-25)'] = ranges['Low (0-25)']! + 1;
      } else if (value <= 50) {
        ranges['Medium (26-50)'] = ranges['Medium (26-50)']! + 1;
      } else if (value <= 75) {
        ranges['High (51-75)'] = ranges['High (51-75)']! + 1;
      } else {
        ranges['Very High (76+)'] = ranges['Very High (76+)']! + 1;
      }
    }

    final sections = ranges.entries.where((e) => e.value > 0).map((entry) {
      final colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.red,
      ];
      final index = ranges.keys.toList().indexOf(entry.key);
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Value Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ranges.entries.where((e) => e.value > 0).map((entry) {
                      final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
                      final index = ranges.keys.toList().indexOf(entry.key);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: colors[index % colors.length],
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}