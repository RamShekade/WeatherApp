import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

  String _getAnimationPath(String condition) {
    final conditionLower = condition.toLowerCase();

    if (conditionLower.contains('rain')) {
      return 'assets/animations/rainy.json';
    } else if (conditionLower.contains('cloud')) {
      return 'assets/animations/cloudy.json';
    } else if (conditionLower.contains('clear') ||
        conditionLower.contains('sun')) {
      return 'assets/animations/sunny.json';
    } else if (conditionLower.contains('snow')) {
      return 'assets/animations/snow.json';
    } else {
      return 'assets/animations/cloudy.json'; // default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardColor = Theme.of(context).cardColor;
    final iconColor = Theme.of(context).iconTheme.color;

    return Card(
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              weather.city,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // 🌤️ Animated Weather Lottie
            Lottie.asset(
              _getAnimationPath(weather.condition),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),

            Text(
              '${weather.temperature.toStringAsFixed(1)} °C',
              style: textTheme.titleMedium,
            ),
            Text(weather.condition, style: textTheme.bodyLarge),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/humidity.json',
                      width: 40,
                      height: 40,
                    ),
                    Text(
                      'Humidity\n${weather.humidity}%',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/wind.json',
                      width: 40,
                      height: 40,
                    ),
                    Text(
                      'Wind\n${weather.windSpeed} m/s',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
