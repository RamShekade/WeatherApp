import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _lastCity;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _loadLastCityAndWeather();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _loadLastCityAndWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString('last_city');
    if (lastCity != null && lastCity.isNotEmpty) {
      setState(() {
        _lastCity = lastCity;
      });
      await Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).loadLastSearchedCityWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('🌞', style: TextStyle(fontSize: 18)),
                  Consumer<ThemeProvider>(
                    builder:
                        (context, themeProvider, _) => Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                        ),
                  ),
                  const Text('🌙', style: TextStyle(fontSize: 18)),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        weatherProvider.getWeather(_controller.text.trim());
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      weatherProvider.getWeatherByLocation();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Section for Last Searched City
              if (_lastCity != null) ...[
                const Text(
                  "Last searched city:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(
                      _lastCity!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: const Text(
                      "This is your previously searched location",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        weatherProvider.getWeather(_lastCity!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Current Weather Card
              if (weatherProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (weatherProvider.error != null)
                Text(
                  weatherProvider.error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                )
              else if (weatherProvider.weather != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: WeatherCard(weather: weatherProvider.weather!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
