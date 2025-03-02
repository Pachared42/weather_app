import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.lightBlueAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final List<String> cities = ['Bangkok', 'Chiang Mai', 'Phuket'];
  int _currentIndex = 0;
  var _weatherData = <String, dynamic>{};
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(cities[_currentIndex]);
  }

  Future<void> _fetchWeatherData(String cityName) async {
    final apiKey = '286ff72d898b423fb80142821250203';
    final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$cityName&aqi=no';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _weatherData[cityName] = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        backgroundColor: Colors.blue,
      ),
      body: _weatherData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SwiperWidget(
              weatherData: _weatherData,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  if (!_weatherData.containsKey(cities[_currentIndex])) {
                    _fetchWeatherData(cities[_currentIndex]);
                  }
                });
              },
              pageController: _pageController,
            ),
    );
  }
}

class SwiperWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final Function(int) onPageChanged;
  final PageController pageController;

  SwiperWidget({required this.weatherData, required this.onPageChanged, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,  // ใช้ controller เพื่อควบคุมการเปลี่ยนหน้า
      itemCount: 3,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final cityName = ['Bangkok', 'Chiang Mai', 'Phuket'][index];
        final cityWeather = weatherData[cityName]?['current'];

        if (cityWeather == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Loading data for $cityName...', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${cityWeather['temp_c']}°C',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              Text(
                weatherData[cityName]['location']['name'],
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Condition: ${cityWeather['condition']['text']}',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}