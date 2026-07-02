# Flutter Weather App (Assignment)

A simple mobile weather app built with Flutter that:
- Searches weather by city name.
- Shows current weather: temperature, description, humidity, wind speed, and condition icon.
- Shows at least a 3-day forecast (date, min/max temp, short description).
- Handles loading and API errors (city not found, no internet).
- Stores last searched city locally so it is shown on next app open.

Important: This project uses the OpenWeatherMap API. You must register and use your own API key.

How to set up & run

1. Prerequisites
   - Flutter SDK installed (version compatible with Dart >=2.18)
   - An Android/iOS emulator or a physical device
   - An OpenWeatherMap API key (https://openweathermap.org/)

2. Clone the repository (or create a new Flutter project and add these files)

3. Place your API key
   - Open `lib/utils/constants.dart`
   - Replace `YOUR_API_KEY_HERE` with your own OpenWeatherMap API key.

4. Install dependencies
   Run:
   ```
   flutter pub get
   ```

5. Run the app
   ```
   flutter run
   ```

Notes on API endpoints used
- Current weather: `https://api.openweathermap.org/data/2.5/weather?q={city}&appid={APIKEY}&units=metric`
- Forecast (3-hour increments): `https://api.openweathermap.org/data/2.5/forecast?q={city}&appid={APIKEY}&units=metric`
  - The app computes daily min/max and picks a representative description/icon for each day.

Screenshots
- Put screenshots in `assets/screenshots/` (create the folder). The README requires screenshots for:
  - Main screen with current weather
  - Forecast (combined screen)
  - Error/no-network screen
- When you capture screenshots on your device/emulator, copy them into the `assets/screenshots/` folder.

Files
- `lib/main.dart` — app entry point and home screen wiring
- `lib/utils/constants.dart` — API key and constants
- `lib/services/weather_service.dart` — API calls and parsing
- `lib/models/weather.dart` — current weather model
- `lib/models/forecast_day.dart` — daily forecast model
- `lib/screens/weather_screen.dart` — UI screen (search + current + 3-day forecast)
- `lib/widgets/current_weather.dart` — widget for current weather area
- `lib/widgets/forecast_tile.dart` — widget for a forecast day tile

