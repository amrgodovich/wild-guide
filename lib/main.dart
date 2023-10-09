import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'location_provider.dart'; // Import the LocationProvider class
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlng/latlng.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Initialize settings
  final AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings(
          'lol'); // Replace 'app_icon' with your app's icon name
  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adventure App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AdventurePage(),
    );
  }
}

class AdventurePage extends StatefulWidget {
  @override
  _AdventurePageState createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage> {
  bool _isDownloading = false;
  double _progressValue = 0.0;
  Position? _currentPosition;
  

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle location retrieval errors
      print('Error getting location: $e');
    }
  }
  

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Color.fromARGB(255, 1, 114, 88), // Set the background color
      child: _currentPosition != null
          ? Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_pin, color: Colors.white),
                  SizedBox(width: 2),
                  Text(
                    'Latitude: ${_currentPosition!.latitude.toStringAsFixed(3)}, Longitude: ${_currentPosition!.longitude.toStringAsFixed(3)}',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 16.0, // Font size
                    ),
                  ),
                ],
              ),
            )
          : Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    color: Colors.white,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Getting GPS location...',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 16.0, // Font size
                      // You can add more text style properties as needed
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _downloadOfflineMap() async {
    setState(() {
      _isDownloading = true;
      _progressValue = 0.0;
    });

    // final downloadUrl = 'YOUR_OFFLINE_MAP_DOWNLOAD_LINK';
    // final directory = await getApplicationDocumentsDirectory();
    // final filePath = '${directory.path}/offline_map.zip';

    // final response = await http.get(Uri.parse(downloadUrl));
    // final file = File(filePath);
    // await file.writeAsBytes(response.bodyBytes);

    setState(() {
      _isDownloading = false;
      _progressValue = 0.0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdventureFeaturesPage(),
      ),
    );
  }

  Future<void> _showNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Replace with your own channel ID
      'Your Channel Name', // Replace with your own channel nam , // Replace with your own channel description
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Notification Title',
      'Notification Body',
      platformChannelSpecifics,
    );

    // Navigate to the NotificationListScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => notificationlist()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          onVerticalDragUpdate: (details) {
            // Get the screen height
            final screenHeight = MediaQuery.of(context).size.height;
            // Define a threshold for the bottom swipe (e.g., 20% of the screen height)
            final swipeThreshold = screenHeight * 0.4;

            // Get the global position of the touch
            final globalPosition = details.globalPosition;

            // Detect swipe-up gesture from the bottom of the screen
            if (details.primaryDelta! < -10 &&
                globalPosition.dy > screenHeight - swipeThreshold) {
              // You can replace this with your desired action
              // For example, you can navigate to a new screen.
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return OfflineMapPage();
                  },
                  transitionDuration: Duration(milliseconds: 600),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            }
          },
          onHorizontalDragUpdate: (details) {
            // Get the screen Width
            final screenWidth = MediaQuery.of(context).size.width;
            // Define a threshold for the bottom swipe (e.g., 20% of the screen Width)
            final swipeThreshold = screenWidth * 0.4;

            // Get the global position of the touch
            final globalPosition = details.globalPosition;

            // Detect swipe-up gesture from the bottom of the screen
            if (details.primaryDelta! < -10 &&
                globalPosition.dy > screenWidth - swipeThreshold) {
              // You can replace this with your desired action
              // For example, you can navigate to a new screen.
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return FireAlertPage();
                  },
                  transitionDuration: Duration(milliseconds: 600),
transitionsBuilder: (context, animation, secondaryAnimation, child) {
  const begin = Offset(1.0, 0.0); // Slide from left (off the screen)
  const end = Offset.zero;
  const curve = Curves.easeInOut;
  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(
    position: offsetAnimation,
    child: child,
  );
},

                ),
              );
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/1.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 10.0,
                right: 10.0,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 1, 114, 88), // Shadow color
                        spreadRadius: 5.0, // Spread radius
                        blurRadius: 30.0, // Blur radius
                        offset: Offset(0, 0), // Offset
                      ),
                    ],
                  ),
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.notifications), // Use a notification icon
                    onPressed: () => _showNotification(), // Pass the context
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: _isDownloading ? null : _downloadOfflineMap,
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 1, 114, 88),
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          textStyle: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.forest,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text('Start Adventure'),
                          ],
                        ),
                      ),
                    ),
                    if (_isDownloading)
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          value: _progressValue,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Define the points to create a horizontal line
    final startPoint = Offset(size.width, size.height);
    final endPoint = Offset(0, size.height);

    // Move to the starting point
    path.moveTo(startPoint.dx, startPoint.dy);

    // Draw a line to the ending point
    path.lineTo(endPoint.dx, endPoint.dy);

    // Draw lines to complete the path
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, 0);

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // Returning false means the clip path should not change
    return false;
  }
}

class AdventureFeaturesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          // Define the primary color for your app
          primaryColor: Color.fromARGB(
              255, 133, 3, 3), // Change this to your desired primary color
        ),
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 167, 220, 199),
          appBar: AppBar(
            title: Text('Adventure App'),
            backgroundColor: Color.fromARGB(255, 1, 114, 88),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FireAlertPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          Color.fromARGB(255, 1, 114, 88), // Background color
                      onPrimary: Colors.white, // Text color
                      padding: EdgeInsets.zero, // No padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Button border radius
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          // alignment: Alignment.center,
                          child: Row(
                            children: [
                              SizedBox(width: 90),
                              Icon(
                                Icons.fire_truck_rounded,
                                size: 40.0,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Fire Report',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipPath(
                            clipper:
                                DiagonalClipper(), // Use the custom clipper here
                            child: Image.asset(
                              'images/5.jpg', // Replace with your image asset path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _IssuereportpagState(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          Color.fromARGB(255, 1, 114, 88), // Background color
                      onPrimary: Colors.white, // Text color
                      padding: EdgeInsets.zero, // No padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Button border radius
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          // alignment: Alignment.center,
                          child: Row(
                            children: [
                              SizedBox(width: 90),
                              Icon(
                                Icons.report_problem_rounded,
                                size: 40.0,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Issue Report',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipPath(
                            clipper:
                                DiagonalClipper(), // Use the custom clipper here
                            child: Image.asset(
                              'images/forest_cu1.jpg', // Replace with your image asset path
                              fit: BoxFit.cover,
                            ),
                          ),
                          
                        ),
                        
                      ],
                    ),
                  ),
                  
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KnowledgePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          Color.fromARGB(255, 1, 114, 88), // Background color
                      onPrimary: Colors.white, // Text color
                      padding: EdgeInsets.zero, // No padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Button border radius
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          // alignment: Alignment.center,
                          child: Row(
                            children: [
                              SizedBox(width: 90),
                              Icon(
                                Icons.nordic_walking_rounded,
                                size: 40.0,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Tour Guide',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipPath(
                            clipper:
                                DiagonalClipper(), // Use the custom clipper here
                            child: Image.asset(
                              'images/4.jpg', // Replace with your image asset path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                    child: Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OfflineMapPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          Color.fromARGB(255, 1, 114, 88), // Background color
                      onPrimary: Colors.white, // Text color
                      padding: EdgeInsets.zero, // No padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Button border radius
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: Row(
                            children: [
                              SizedBox(width: 90),
                              Icon(
                                Icons.map_rounded,
                                size: 40.0,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Map',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipPath(
                            clipper:
                                DiagonalClipper(), // Use the custom clipper here
                            child: Image.asset(
                              'images/7.jpg', // Replace with your image asset path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }
}

class FireAlertPage extends StatefulWidget {
  @override
  _FireAlertPageState createState() => _FireAlertPageState();
}

class _FireAlertPageState extends State<FireAlertPage> {
  File? _imageFile;
  Position? _currentPosition;

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle location retrieval errors
      print('Error getting location: $e');
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      _imageFile = File(image!.path);
    });

    // Call the function to upload the image
    // await _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      // Handle the case where no image is selected
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // If there is no internet, save the data locally for later upload
      await _saveDataLocally();
      return;
    }

    // Replace 'your_upload_url' with the actual URL of your server
    var url = Uri.parse('https://your_upload_url.com');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Add the image to the request
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // Field name for the file
        _imageFile!.path,
      ),
    );

    // Add other information as headers or parameters
    request.headers.addAll({
      'Date': DateTime.now().toIso8601String(),
      'GPSLatitude': _currentPosition!.latitude.toStringAsFixed(3), // Use the received latitude
      'GPSLongitude': _currentPosition!.longitude.toStringAsFixed(3), // Use the received longitude
    });

    // Send the request
    var response = await request.send();

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Handle a successful upload
      print('Image uploaded successfully');

      // Clear the locally saved data
      await _clearLocalData();
    } else {
      // Handle an error
      print('Error uploading image: ${response.statusCode}');
    }
  }

  Future<void> _saveDataLocally() async {
    // Create a SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Save the image file path and other data locally
    await prefs.setString('imageFilePath', _imageFile!.path);
    await prefs.setString('date', DateTime.now().toIso8601String());
    await prefs.setString(
        'latitude', _currentPosition!.latitude.toStringAsFixed(3));
    await prefs.setString(
        'longitude', _currentPosition!.longitude.toStringAsFixed(3));
  }

  Future<void> _clearLocalData() async {
    // Clear locally saved data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('imageFilePath');
    await prefs.remove('date');
    await prefs.remove('latitude');
    await prefs.remove('longitude');
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fire Report'),
        backgroundColor: Color.fromARGB(255, 1, 114, 88),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: 300,
                width: 300,
              ),
            ElevatedButton(
              onPressed: _captureImage,
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 1, 114, 88), // Background color
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Button border radius
                ),
                textStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold, // Text style
                ),
              ),
              child: Text('Capture Image'),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 1, 114, 88), // Background color
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Button border radius
                ),
                textStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold, // Text style
                ),
              ),
              child: Text('Submit'),
            ),
            SizedBox(
              height: 25,
            ),
            Text(DateTime.now().toIso8601String()),
            Text(
                'Latitude: ${_currentPosition!.latitude.toStringAsFixed(3)},Longitude: ${_currentPosition!.longitude.toStringAsFixed(3)}')
          ],
        ),
      ),
    );
  }
}


class _IssuereportpagState extends StatefulWidget {
  @override
  __IssuereportpagStateState createState() => __IssuereportpagStateState();
}

class __IssuereportpagStateState extends State<_IssuereportpagState> {
  File? _imageFile;
  Position? _currentPosition;

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle location retrieval errors
      print('Error getting location: $e');
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      _imageFile = File(image!.path);
    });

    // Call the function to upload the image
    // await _uploadImage();
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      // Handle the case where no image is selected
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // If there is no internet, save the data locally for later upload
      await _saveDataLocally();
      return;
    }

    // Replace 'your_upload_url' with the actual URL of your server
    var url = Uri.parse('https://your_upload_url.com');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);

    // Add the image to the request
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // Field name for the file
        _imageFile!.path,
      ),
    );

    // Add other information as headers or parameters
    request.headers.addAll({
      'Date': DateTime.now().toIso8601String(),
      'GPSLatitude': _currentPosition!.latitude.toStringAsFixed(3), // Use the received latitude
      'GPSLongitude': _currentPosition!.longitude.toStringAsFixed(3), // Use the received longitude
    });

    // Send the request
    var response = await request.send();

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Handle a successful upload
      print('Image uploaded successfully');

      // Clear the locally saved data
      await _clearLocalData();
    } else {
      // Handle an error
      print('Error uploading image: ${response.statusCode}');
    }
  }

  Future<void> _saveDataLocally() async {
    // Create a SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Save the image file path and other data locally
    await prefs.setString('imageFilePath', _imageFile!.path);
    await prefs.setString('date', DateTime.now().toIso8601String());
    await prefs.setString(
        'latitude', _currentPosition!.latitude.toStringAsFixed(3));
    await prefs.setString(
        'longitude', _currentPosition!.longitude.toStringAsFixed(3));
  }

  Future<void> _clearLocalData() async {
    // Clear locally saved data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('imageFilePath');
    await prefs.remove('date');
    await prefs.remove('latitude');
    await prefs.remove('longitude');
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Report'),
        backgroundColor: Color.fromARGB(255, 1, 114, 88),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: 300,
                width: 300,
              ),
            ElevatedButton(
              onPressed: _captureImage,
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 1, 114, 88), // Background color
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Button border radius
                ),
                textStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold, // Text style
                ),
              ),
              child: Text('Capture Image'),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 1, 114, 88), // Background color
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Button border radius
                ),
                textStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold, // Text style
                ),
              ),
              child: Text('Submit to the authorities'),
            ),
            SizedBox(
              height: 25,
            ),
            Text(DateTime.now().toIso8601String()),
            Text(
                'Latitude: ${_currentPosition!.latitude.toStringAsFixed(3)},Longitude: ${_currentPosition!.longitude.toStringAsFixed(3)}')
          ],
        ),
      ),
    );
  }
}


class KnowledgePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Tour Guide'),
        backgroundColor: Color.fromARGB(255, 1, 114, 88),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: Colors.black.withOpacity(0.5), // You can adjust the opacity as needed
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    'Amazon Rainforest Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
              _buildStatItem(
              'statistics and information :',
              '\n'
              '•	The Amazon rainforest covers about 2.1 million square miles in South America\n'
              '\n'
              '•	It represents over half of the planets remaining rainforests.\n'
              '\n'
              '• This includes 16,000 tree species.\n'
              '\n'
              '• 2.5 million insect species\n'
              '\n'
              '• Over 2,000 birds and mammals species.\n'
              '\n'
              '• The Amazon River, which runs through the middle of the rainforest, is the 2nd longest river in the world at 4,000 miles and it accounts for 20% of the world\'s freshwater that enters the oceans.\n'
              '\n'
              '• Around 390 billion trees are estimated to be in the Amazon, and this is equivalent to over 50,000 trees for every person on earth.\n'
              '\n'
              '• The total biomass of plants and trees in the Amazon is estimated at 269 gigatonnes of carbon.\n'
              '\n'
              '• Since 1970, over 600,000 square miles (20%) of the Amazon rainforest has been cleared, mostly for cattle ranching.\n'
              '\n'
              '• Deforestation rates peaked in 1995 at 29,059 square miles per year.\n'
              '\n'
              '• Today there are around 1 million indigenous people from 350 ethnic groups in the Amazon Basin.',
    
              ),
    
              _buildStatItem('Importance of the forest :',
              '\n'
              '•	The Amazon rainforest plays a vital role as a carbon sink, absorbing 2 billion tons of carbon dioxide per year\n'
              '\n'
              '•	helping regulate the Earth\'s climate'
    
              ),
              _buildStatItem('Common animals', 
        '•	Jaguar - The largest cat species in the Americas. Jaguars are excellent swimmers and climbers, and prey on over 85 species including caiman, capybaras, and turtles. Their population is declining due to habitat loss. '
        '\n'
        '\n'
        '•	Amazon River Dolphin - These intelligent freshwater dolphins have a long beak and unfused neck vertebrae allowing them to move their heads independently. They use echolocation to navigate murky river waters and locate prey.'
        '\n'
        '\n'
        '•	Parrots - Over 140 parrot species are found in the Amazon, the most biodiverse region for parrots. Common species include macaws, parakeets, and Amazon parrots. They live in flocks and eat fruits, seeds and nuts.'
        '\n'
        '\n'
        '•  Anacondas - These largest snakes in the world can grow over 30 feet long. They are non-venomous constrictors and live in swamps and rivers, preying on fish, birds and mammals.'
              ),
              _buildStatItem('Common Plants', 
              '•	Brazil nut tree - A dominant canopy tree that can live for 500-700 years. Its nutrient-rich seeds are harvested as Brazil nuts, an important export crop.'
              '\n'
              '\n'
        '•	Balsa tree - Known for its lightweight, fast-growing timber used for rafts, model airplanes, and other products. It has water-filled soft tissue that makes the wood buoyant.'
      '\n'
      '\n'
    '•	Mahogany tree - Highly-valued for its durable, beautiful hardwood used for fine furniture. Mahogany logging was a key driver of deforestation.'
            )],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent
          ),
        ),
        SizedBox(height: 7.0),
        Text(
          description,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 25.0),
      ],
    );
  }
}

class OfflineMapPage extends StatefulWidget {
  @override
  _OfflineMapPageState createState() => _OfflineMapPageState();
}

class _OfflineMapPageState extends State<OfflineMapPage> {
  bool isLoading = false;

  void simulateLoading() {
    // Simulate loading for 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false; // Set loading to false after simulating loading
      });
    });

    setState(() {
      isLoading = true; // Set loading to true when the button is pressed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Map'),
        backgroundColor: Color.fromARGB(255, 1, 114, 88),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/map.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 1, 114, 88), // Shadow color
                    spreadRadius: 5.0, // Spread radius
                    blurRadius: 30.0, // Blur radius
                    offset: Offset(0, 0), // Offset
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: isLoading ? null : simulateLoading,
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 1, 114, 88),
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          textStyle: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLoading ? Icons.refresh_rounded : Icons.refresh,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(isLoading ? 'Loading...' : 'Reload'),
                          ],
                        ),
                      ),
                      SizedBox(height: 15,)
                    ],
                  ),
                  SizedBox(width: 15),
                ],
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}


class notificationlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 1, 114, 88),
          title: Text('Notification List'),
        ),
        body: ListView(
          padding: EdgeInsets.all(16.0), // Add padding for spacing
          children: [
            Card(
              elevation: 15.0, // Add elevation for a shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(
                    'URGENT!',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.red
                    ),
                  ),
                  subtitle: Text(
                    'It has come to our attention that a fire has broken out in the southeast of the Amazon forest, so we urge you to quickly exit the forest area for your safety. \nThanks!',
                  style: TextStyle(fontSize: 15,
                      color: Colors.black

                  ),),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      // Handle notification dismissal
                    },
                  ),
                ),
              ),
            ),
            Card(
              elevation: 15.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                                            color: Colors.indigo

                    ),
                  ),
                  subtitle: Text(
                      'Nasa Space Apps Cairo welcomes you in its new project!',
                      style: TextStyle(fontSize: 15,
                      color: Colors.black),),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      // Handle notification dismissal
                    },
                  ),
                ),
              ),
            ),
            // Add more Card widgets for each notification
          ],
        ));
  }
}
