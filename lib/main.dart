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
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

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

  // เพิ่มฟังก์ชันในการเปลี่ยนหน้า
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: const Text(
          '🌤️ แอพพยากรณ์อากาศ',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Column(
        children: [
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Other Cities',
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  'https:${cityWeather['condition']['icon']}',
                  width: 100, // You can still define a larger width or height for the container
                  height: 100, // to control the space
                  fit: BoxFit
                      .contain, // Ensures the icon scales up without distortion
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centers vertically
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centers horizontally
                  children: [
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
              ),
              const SizedBox(height: 20),
              // Box for temperature feels like
              _buildInfoBox(
                title: 'อุณหภูมิที่รู้สึก:',
                value: '${cityWeather['feelslike_c']}°C',
              ),
              const SizedBox(height: 10),
              // Box for wind speed and direction
              _buildInfoBox(
                title: 'ความเร็วลม:',
                value:
                    '${cityWeather['wind_kph']} km/h (${cityWeather['wind_dir']})',
              ),
              const SizedBox(height: 10),
              // Box for humidity
              _buildInfoBox(
                title: 'ความชื้นในอากาศ:',
                value: '${cityWeather['humidity']}%',
              ),
              const SizedBox(height: 10),
              // Box for pressure
              _buildInfoBox(
                title: 'ความดันอากาศ:',
                value: '${cityWeather['pressure_mb']} mb',
              ),
              const SizedBox(height: 10),
              // Box for visibility
              _buildInfoBox(
                title: 'การมองเห็น:',
                value: '${cityWeather['vis_km']} km',
              ),
              const SizedBox(height: 10),
              // Box for UV index
              _buildInfoBox(
                title: 'ดัชนี UV:',
                value: '${cityWeather['uv']}',
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function to build information boxes
  Widget _buildInfoBox({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
