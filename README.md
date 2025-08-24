# Flutter WebView JavaScript Channel Testing

A comprehensive testing application for bidirectional communication between Flutter and WebView using JavaScript channels. This project demonstrates how to establish real-time communication between Flutter apps and embedded web content.

## 🎯 Project Overview

This project serves as a testing ground for Flutter WebView integration, specifically focusing on JavaScript channel communication. It provides a simple yet powerful way to test message passing between Flutter and web content.

## ✨ Features

### 🔄 Bidirectional Communication

- **Flutter → WebView**: Send messages and commands from Flutter to web content
- **WebView → Flutter**: Receive button clicks, messages, and events from web content
- **Real-time Updates**: Instant UI updates based on web interactions

### 🎮 Interactive Testing

- **Button Click Tracking**: Monitor and count button clicks from web content
- **Message Passing**: Send and receive custom messages between Flutter and WebView
- **Counter Management**: Reset counters and manage state from Flutter
- **Debug Logging**: Comprehensive logging for troubleshooting

### 🛠️ Development Tools

- **Standalone HTML Testing**: Test web content independently in browser
- **Local Web Server**: HTTP server for testing without CORS issues
- **Console Logging**: Detailed logs for debugging communication issues

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Python 3 (for local web server)
- Modern web browser (Chrome, Firefox, Brave, etc.)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd webviewtest
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Start local web server** (for testing HTML files)

   ```bash
   python3 -m http.server 8000
   ```

4. **Run the Flutter app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
webviewtest/
├── lib/
│   └── main.dart                 # Main Flutter application
├── assets/
│   └── index.html               # Web content for WebView
├── test_3d_viewer.html          # Standalone 3D viewer test
├── pubspec.yaml                 # Flutter dependencies
└── README.md                    # This file
```

## 🔧 Configuration

### Dependencies

The project uses the following key dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.7.0 # WebView functionality
  cupertino_icons: ^1.0.8 # iOS-style icons
```

### Assets Configuration

```yaml
flutter:
  assets:
    - assets/ # Include all files in assets folder
```

## 🎮 Usage

### Running the Flutter App

1. **Start the app**

   ```bash
   flutter run
   ```

2. **Test WebView Communication**
   - Click buttons in the WebView to see Flutter updates
   - Use Flutter buttons to send messages to WebView
   - Monitor the debug console for communication logs

### Testing HTML Independently

1. **Start local server**

   ```bash
   python3 -m http.server 8000
   ```

2. **Access test files**

   - Main HTML: `http://localhost:8000/assets/index.html`
   - 3D Viewer: `http://localhost:8000/test_3d_viewer.html`

3. **Check browser console** (F12) for detailed logs

## 🔍 JavaScript Channel Implementation

### Flutter Side

```dart
// Set up JavaScript channel
webViewController.addJavaScriptChannel(
  'Flutter',
  onMessageReceived: (JavaScriptMessage message) {
    // Handle messages from WebView
    final data = _parseMessage(message.message);
    // Update UI based on received data
  },
);

// Send message to WebView
webViewController.runJavaScript('''
  if (window.receiveMessageFromFlutter) {
    window.receiveMessageFromFlutter(${message.toString()});
  }
''');
```

### WebView Side

```javascript
// Send message to Flutter
if (window.Flutter) {
  window.Flutter.postMessage(
    JSON.stringify({
      type: "buttonClick",
      count: clickCount,
      message: "Button clicked!",
    })
  );
}

// Receive message from Flutter
window.receiveMessageFromFlutter = function (message) {
  console.log("Received from Flutter:", message);
  // Handle Flutter message
};
```

## 📊 Message Format

### WebView → Flutter

```json
{
  "type": "buttonClick",
  "count": 5,
  "message": "Button clicked from WebView!"
}
```

```json
{
  "type": "message",
  "content": "Hello from WebView!",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

```json
{
  "type": "ready",
  "status": "WebView is ready!"
}
```

### Flutter → WebView

```json
{
  "type": "fromFlutter",
  "content": "Hello from Flutter!",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## 🐛 Debugging

### Flutter Console Logs

Look for these debug messages in the Flutter console:

```
=== FLUTTER RECEIVED MESSAGE ===
Raw message: {"type":"buttonClick","count":1,"message":"Button clicked!"}
Successfully processed message: {type: buttonClick, count: 1, message: Button clicked!}
=== END MESSAGE PROCESSING ===
```

### WebView Console Logs

Check browser console (F12) for these messages:

```
[timestamp] Sending message to Flutter: {type: "buttonClick", count: 1, message: "Button clicked!"}
[timestamp] Flutter channel found, sending message...
[timestamp] Received message from Flutter: {type: "fromFlutter", content: "Hello from Flutter!"}
```

### Common Issues

1. **CORS Errors**: Use local web server instead of file:// protocol
2. **Channel Not Found**: Ensure JavaScript channel is set up before WebView loads
3. **Message Not Received**: Check JSON format and channel name consistency

## 🧪 Testing Scenarios

### Basic Communication Test

1. Open the Flutter app
2. Click "Click Me!" button in WebView
3. Verify counter increases in Flutter UI
4. Click "Send Message to Flutter" button
5. Check message appears in Flutter UI

### Bidirectional Test

1. Click "Send to WebView" button in Flutter
2. Verify message appears in WebView
3. Click "Reset Counter" button in Flutter
4. Verify WebView counter resets

### Error Handling Test

1. Disconnect network and try loading
2. Check error messages in console
3. Verify graceful error handling

## 🔧 Customization

### Adding New Message Types

1. **Update Flutter handler**:

   ```dart
   if (data['type'] == 'newType') {
     // Handle new message type
   }
   ```

2. **Update WebView sender**:
   ```javascript
   window.Flutter.postMessage(
     JSON.stringify({
       type: "newType",
       data: "your data",
     })
   );
   ```

### Modifying UI

- **Flutter UI**: Edit `lib/main.dart`
- **WebView UI**: Edit `assets/index.html`
- **Styling**: Modify CSS in HTML file

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web (with limitations)
- ✅ Desktop (Windows, macOS, Linux)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

If you encounter issues:

1. Check the debug console for error messages
2. Verify all dependencies are installed
3. Ensure local web server is running for HTML testing
4. Check browser console for WebView errors

## 🔗 Related Resources

- [Flutter WebView Documentation](https://pub.dev/packages/webview_flutter)
- [JavaScript Channel Guide](https://docs.flutter.dev/development/platform-integration/web/webview)
- [Three.js Documentation](https://threejs.org/docs/) (for 3D viewer)

---

**Happy Testing! 🚀**

This project provides a solid foundation for testing and implementing WebView communication in Flutter applications. Use it as a reference for your own projects or extend it with additional features.
