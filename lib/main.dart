import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'แอพพยากรณ์อากาศ',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: Colors.lightBlueAccent),
        fontFamily: 'Roboto', // ใช้ฟอนต์ Roboto
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  final Map<String, String> cities = {
  'Doem Bang Nang Buat': 'เดิมบางนางบวช',
  'Uthai Thani': 'อุทัยธานี',
  'Song Phi Nong': 'สองพี่น้อง',
  'Don Chedi': 'ดอนเจดีย์',
  'Bang Pla Ma': 'บางปลาม้า',
  'Si Prachan': 'ศรีประจันต์',
  'Kanchanadit': 'กันทรารมย์',
};
  final Map<String, dynamic> _weatherData = {};
  final TextEditingController _cityController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    for (var city in cities.keys) {
      _fetchWeatherData(city);
    }
  }

  Future<void> _fetchWeatherData(String cityName) async {
    if (_weatherData.containsKey(cityName)) return;

    const apiKey = '286ff72d898b423fb80142821250203';
    final url =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$cityName&aqi=no';

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
      debugPrint('Error fetching $cityName: $error');
    }
  }

  void _addCity() {
    final cityName = _cityController.text.trim();
    if (cityName.isNotEmpty && !cities.containsValue(cityName)) {
      setState(() {
        cities[cityName] = cityName;
      });
      _fetchWeatherData(cityName);
      _cityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: const Text('🌤️ แอพพยากรณ์อากาศ'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: '🔍 เพิ่มเมือง (ภาษาอังกฤษ)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addCity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'เพิ่ม',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _weatherData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SwiperWidget(
                    cities: cities,
                    weatherData: _weatherData,
                    pageController: _pageController,
                  ),
          ),
        ],
      ),
    );
  }
}

class SwiperWidget extends StatelessWidget {
  final Map<String, String> cities;
  final Map<String, dynamic> weatherData;
  final PageController pageController;

  const SwiperWidget({
    required this.cities,
    required this.weatherData,
    required this.pageController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final cityEnglish = cities.keys.elementAt(index);
        final cityThai = cities[cityEnglish]!;
        final cityWeather = weatherData[cityEnglish]?['current'];

        if (cityWeather == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Text('กำลังโหลดข้อมูลของ $cityThai...',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade300],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                'https:${cityWeather['condition']['icon']}',
                width: 100,
                height: 100,
              ),
              Text(
                '${cityWeather['temp_c']}°C',
                style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                cityThai,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'สภาพอากาศ: ${cityWeather['condition']['text']}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
