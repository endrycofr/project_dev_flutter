import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class DHT11Values {
  final double temperature;
  final double humidity;

  DHT11Values({required this.temperature, required this.humidity});
}

class DHT11 {
  final I2C _i2c;

  DHT11(this._i2c);

  DHT11Values getValues() {
    // Implement the logic to read the temperature and humidity values from the DHT11 sensor
    // For demonstration purposes, return fixed values
    return DHT11Values(temperature: 25.0, humidity: 60.0);
  }
}

class I2cDht11GetData {
  I2C? _i2c;
  late final DHT11 _dht11;
  String _temperature = '50';
  String _humidity = '60';

  void initI2cDht11() {
    if (!Platform.isLinux) {
      print('dart_periphery is only supported for Linux!');
      return;
    }
    _i2c = I2C(1);
    if (kDebugMode) {
      print('I2C info: ${_i2c!.getI2Cinfo()}');
    }
    _dht11 = DHT11(_i2c!);
  }

  void _updateSensorValues() {
    if (!Platform.isLinux) return;
    final values = _dht11.getValues();
    _temperature = values.temperature.toStringAsFixed(1);
    _humidity = values.humidity.toStringAsFixed(1);
    if (kDebugMode) {
      print('Temperature: $_temperature, Humidity: $_humidity');
    }
  }

  String getTemperature() {
    _updateSensorValues();
    return _temperature;
  }

  String getHumidity() {
    _updateSensorValues();
    return _humidity;
  }

  void dispose() {
    if (!Platform.isLinux) return;
    _i2c?.dispose();
  }
}

// Example usage in a Flutter widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final I2cDht11GetData i2cDht11GetData = I2cDht11GetData();
  String temperatureValue = '';
  String humidityValue = '';

  @override
  void initState() {
    super.initState();
    i2cDht11GetData.initI2cDht11();
  }

  @override
  void dispose() {
    i2cDht11GetData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I2C DHT11'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('I2C DHT11'),
            const SizedBox(height: 20.0),
            getI2cDht11Temperature(),
            const SizedBox(height: 20.0),
            getI2cDht11Humidity(),
          ],
        ),
      ),
    );
  }

  Widget getI2cDht11Temperature() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          temperatureValue = i2cDht11GetData.getTemperature();
        });
      },
      child: Text('The Temperature is: $temperatureValue °C'),
    );
  }

  Widget getI2cDht11Humidity() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          humidityValue = i2cDht11GetData.getHumidity();
        });
      },
      child: Text('The Humidity is: $humidityValue %'),
    );
  }
}
