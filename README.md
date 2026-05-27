# greenhouse_app

## Features
- Live temperature readings from DHT11 sensor
- Live humidity readings from DHT11 sensor
- Live soil moisture readings from hygrometer sensor
- Toggle LED on/off with a button
- Connects to private self-hosted MQTT broker via WebSocket
- Real-time updates without page refresh
- Automatic reconnection if connection is lost

## Prerequisites
- Flutter SDK installed
- Android Studio with an emulator set up, or a physical Android device

## Setup
1. Clone the repository
2. Navigate to the `greenhouse_app` folder
3. Change `lib/secrets.example.dart` to `lib/secrets.dart`
4. Fill in your MQTT broker credentials in `secrets.dart`

## Run on emulator
This project was developed and tested using a **Google Pixel 6** 
emulator (API 33) in Android Studio.

1. Open Android Studio and start the Pixel 6 emulator from Device Manager
2. In VS Code, press `Ctrl+Shift+P` and select `Flutter: Launch Emulator`
3. Select the Pixel 6 emulator
4. Run the app:
```bash
flutter pub get
flutter run
```

## Notes
- The app connects to the MQTT broker via WebSocket on port 9001
- Make sure port 9001 is open on your server firewall
- The app subscribes to `lnu/iot/jp223yp/sensor` for  data