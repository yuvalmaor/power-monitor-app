import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:battery_plus/battery_plus.dart';

void main() {
  runApp(const PowerMonitorApp());
}

class PowerMonitorApp extends StatelessWidget {
  const PowerMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PowerMonitorHome(),
    );
  }
}

class PowerMonitorHome extends StatefulWidget {
  const PowerMonitorHome({super.key});

  @override
  State<PowerMonitorHome> createState() => _PowerMonitorHomeState();
}

class _PowerMonitorHomeState extends State<PowerMonitorHome> {
  final Battery _battery = Battery();
  BatteryState _batteryState = BatteryState.unknown;
  String _lastApiCallResult = 'No API calls yet';
  
  @override
  void initState() {
    super.initState();
    _battery.batteryState.then(_updateBatteryState);
    _battery.onBatteryStateChanged.listen(_updateBatteryState);
  }

  void _updateBatteryState(BatteryState state) async {
    if (state != _batteryState) {
      setState(() {
        _batteryState = state;
      });
      
      // Make API call when power state changes
      await _makeApiCall();
    }
  }

  Future<void> _makeApiCall() async {
    try {
      // Replace with your actual API endpoint
      final response = await http.post(
        Uri.parse('https://api.example.com/power-status'),
        body: {
          'deviceStatus': _batteryState == BatteryState.charging 
            ? 'connected' 
            : 'disconnected',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _lastApiCallResult = 'API Call Result: ${response.statusCode} - ${response.body}';
      });
    } catch (e) {
      setState(() {
        _lastApiCallResult = 'API Call Failed: $e';
      });
    }
  }

  String _getBatteryStateString() {
    switch (_batteryState) {
      case BatteryState.charging:
        return 'Connected to Power';
      case BatteryState.discharging:
        return 'On Battery Power';
      case BatteryState.full:
        return 'Battery Full';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Monitor'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _batteryState == BatteryState.charging
                    ? Icons.battery_charging_full
                    : Icons.battery_std,
                size: 48,
                color: _batteryState == BatteryState.charging
                    ? Colors.green
                    : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Power Status: ${_getBatteryStateString()}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Text(
                _lastApiCallResult,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
