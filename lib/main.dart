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
      title: 'พยากรณ์อากาศ',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: Colors.lightBlueAccent),
        fontFamily: 'Noto', // ใช้ฟอนต์ Noto
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
    'Bangkok': 'กรุงเทพมหานคร',
    'Chiang Mai': 'เชียงใหม่',
    'Phuket': 'ภูเก็ต',
    'Ayutthaya': 'พระนครศรีอยุธยา',
    'Khon Kaen': 'ขอนแก่น',
    'Chonburi': 'ชลบุรี',
    'Nakhon Ratchasima': 'นครราชสีมา',
    'Hua Hin': 'หัวหิน',
    'Samut Prakan': 'สมุทรปราการ',
    'Nakhon Pathom': 'นครปฐม',
    'Songkhla': 'สงขลา',
    'Udon Thani': 'อุดรธานี',
    'Surat Thani': 'สุราษฎร์ธานี',
    'Nonthaburi': 'นนทบุรี',
    'Pathum Thani': 'ปทุมธานี',
    'Chachoengsao': 'ฉะเชิงเทรา',
    'Sukhothai': 'สุโขทัย',
    'Nakhon Si Thammarat': 'นครศรีธรรมราช',
    'Pattaya': 'พัทยา',
    'Lampang': 'ลำปาง',
    'Nakhon Sawan': 'นครสวรรค์',
    'Rayong': 'ระยอง',
    'Loei': 'เลย',
    'Prachuap Khiri Khan': 'ประจวบคีรีขันธ์',
    'Roi Et': 'ร้อยเอ็ด',
    'Sakon Nakhon': 'สกลนคร',
    'Trang': 'ตรัง',
    'Ubon Ratchathani': 'อุบลราชธานี',
    'Kanchanaburi': 'กาญจนบุรี',
    'Krabi': 'กระบี่',
    'Chaiyaphum': 'ชัยภูมิ',
    'Amnat Charoen': 'อำนาจเจริญ',
    'Chumphon': 'ชุมพร',
    'Kalasin': 'กาฬสินธุ์',
    'Phetchabun': 'เพชรบูรณ์',
    'Mae Hong Son': 'แม่ฮ่องสอน',
    'Samut Songkhram': 'สมุทรสงคราม',
    'Singburi': 'สิงห์บุรี',
    'Satun': 'สตูล',
    'Nakhon Nayok': 'นครนายก',
    'Yasothon': 'ยโสธร',
    'Phetchaburi': 'เพชรบุรี',
    'Nong Khai': 'หนองคาย',
    'Buriram': 'บุรีรัมย์',
    'Chai Nat': 'ชัยนาท',
    'Phayao': 'พะเยา',
    'Phichit': 'พิษณุโลก',
    'Phrae': 'แพร่',
    'Tak': 'ตาก',
    'Nan': 'น่าน',
    'Mukdahan': 'มุกดาหาร',
    'Surin': 'สุรินทร์',
    'Phatthalung': 'พัทลุง',
  };
  final Map<String, dynamic> _weatherData = {};
  final PageController pageController = PageController();

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

  void _searchCity(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String query = '';
        return AlertDialog(
          title: const Text('ค้นหาเมือง'),
          content: TextField(
            onChanged: (value) {
              query = value;
            },
            decoration: const InputDecoration(hintText: 'กรอกชื่อเมือง'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (query.isNotEmpty) {
                  setState(() {
                    cities[query] = query; // Add the searched city dynamically
                  });
                  _fetchWeatherData(query); // ฟังก์ชันค้นหาข้อมูลเมือง
                }
                Navigator.pop(context);
              },
              child: const Text('ค้นหา'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: const Text(
          '🌤️ พยากรณ์อากาศ',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _searchCity(context), // เพิ่มปุ่มค้นหา
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _weatherData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SwiperWidget(
                    cities: cities,
                    weatherData: _weatherData,
                    pageController: pageController, // แก้เป็น pageController
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  'https:${cityWeather['condition']['icon']}',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
      padding: const EdgeInsets.all(12), // ลดขนาด padding
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8), // ปรับความทึบของสีให้เบาลง
        borderRadius: BorderRadius.circular(8), // ลดขนาด border radius
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16, // ลดขนาดฟอนต์
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16, // ลดขนาดฟอนต์
            ),
          ),
        ],
      ),
    );
  }
}
