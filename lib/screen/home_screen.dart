import 'package:flutter/material.dart';

import '../dht11/dht11_class.dart';

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
