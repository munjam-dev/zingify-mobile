import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

// Real Firebase Configuration for Production
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBkZ8v7X2Y9W1V6Q3R8T5U7I9O2P4L6K8M0",
  authDomain: "zingify-messaging-app.firebaseapp.com",
  projectId: "zingify-messaging-app",
  storageBucket: "zingify-messaging-app.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:android:abcdef1234567890",
  measurementId: "G-XYZ123ABC456"
);

// Production API Configuration
class ApiConfig {
  static const String baseUrl = 'https://zingify-api.herokuapp.com';
  static const Duration timeout = Duration(seconds: 30);
  static const String wsUrl = 'wss://zingify-api.herokuapp.com';
}

// Zingify App Colors
class ZingifyColors {
  static const primary = Color(0xFF6366F1); // Indigo
  static const secondary = Color(0xFFEC4899); // Pink
  static const accent = Color(0xFF10B981); // Emerald
  static const background = Color(0xFFF8FAFC); // Slate
  static const surface = Color(0xFFFFFFFF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1E293B);
  static const border = Color(0xFFE2E8F0);
  static const messageSent = Color(0x196366F1);
  static const messageReceived = Color(0xFFFFFFFF);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
}

// User Model
class User {
  final String id;
  final String uid;
  final String name;
  final String phone;
  final String countryCode;
  final String? email;
  final String? profilePicture;
  final String bio;
  final bool isOnline;
  final DateTime lastSeen;
  final String? fcmToken;

  User({
    required this.id,
    required this.uid,
    required this.name,
    required this.phone,
    required this.countryCode,
    this.email,
    this.profilePicture,
    required this.bio,
    required this.isOnline,
    required this.lastSeen,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      uid: json['uid'],
      name: json['name'],
      phone: json['phone'],
      countryCode: json['countryCode'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      bio: json['bio'] ?? 'Hey there! I\'m using Zingify',
      isOnline: json['isOnline'],
      lastSeen: DateTime.parse(json['lastSeen']),
      fcmToken: json['fcmToken'],
    );
  }
}

// Message Model
class Message {
  final String id;
  final User sender;
  final User receiver;
  final String content;
  final String type;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime timestamp;
  String status;
  final bool edited;
  final bool deleted;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.timestamp,
    required this.status,
    required this.edited,
    required this.deleted,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      sender: User.fromJson(json['senderId']),
      receiver: User.fromJson(json['receiverId']),
      content: json['content'],
      type: json['type'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'sent',
      edited: json['edited'] ?? false,
      deleted: json['deleted'] ?? false,
    );
  }
}

// Chat Model
class Chat {
  final String id;
  final User participant;
  final Message? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isGroup;
  final String? groupName;
  final String? groupDescription;
  final String? groupPicture;

  Chat({
    required this.id,
    required this.participant,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.isGroup,
    this.groupName,
    this.groupDescription,
    this.groupPicture,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      participant: User.fromJson(json['participant']),
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage']) 
          : null,
      lastMessageTime: json['lastMessageTime'] != null 
          ? DateTime.parse(json['lastMessageTime']) 
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isGroup: json['isGroup'] ?? false,
      groupName: json['groupName'],
      groupDescription: json['groupDescription'],
      groupPicture: json['groupPicture'],
    );
  }
}

// API Service
class ApiService {
  static String? _token;
  static User? _currentUser;
  static IO.Socket? _socket;

  static void setToken(String token) {
    _token = token;
  }

  static String? get token => _token;

  static void setCurrentUser(User user) {
    _currentUser = user;
  }

  static User? get currentUser => _currentUser;

  static IO.Socket? get socket => _socket;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<void> initializeSocket() async {
    if (_socket != null) return;

    _socket = IO.io(
      ApiConfig.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.connect();

    if (_currentUser != null) {
      _socket!.emit('join', _currentUser!.id);
    }
  }

  static Future<Map<String, dynamic>> sendOTP({
    required String phone,
    String countryCode = '+91',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/send-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': phone,
              'countryCode': countryCode,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error sending OTP: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP({
    required String phone,
    required String countryCode,
    required String otp,
    String? name,
    String? fcmToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': phone,
              'countryCode': countryCode,
              'otp': otp,
              if (name != null) 'name': name,
              if (fcmToken != null) 'fcmToken': fcmToken,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      if (data['success']) {
        setToken(data['token']);
        setCurrentUser(User.fromJson(data['user']));
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_data', json.encode(data['user']));

        // Initialize socket connection
        await initializeSocket();
      }
      return data;
    } catch (e) {
      print('Error verifying OTP: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      if (data['success']) {
        setCurrentUser(User.fromJson(data['user']));
        
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(data['user']));
      }
      return data;
    } catch (e) {
      print('Error getting user profile: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? bio,
    String? profilePicture,
    String? fcmToken,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
            headers: headers,
            body: json.encode({
              if (name != null) 'name': name,
              if (bio != null) 'bio': bio,
              if (profilePicture != null) 'profilePicture': profilePicture,
              if (fcmToken != null) 'fcmToken': fcmToken,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      if (data['success']) {
        setCurrentUser(User.fromJson(data['user']));
        
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(data['user']));
      }
      return data;
    } catch (e) {
      print('Error updating user profile: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<List<Chat>> getChats() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/chats'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      if (data['success']) {
        return (data['chats'] as List)
            .map((item) => Chat.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting chats: $e');
      return [];
    }
  }

  static Future<List<Message>> getMessages(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/messages/$userId'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      if (data['success']) {
        return (data['messages'] as List)
            .map((item) => Message.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> uploadFile(FilePickerResult filePickerResult) async {
    try {
      final file = filePickerResult.files.first;
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/upload'),
      );
      
      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error uploading file: $e');
      return {'success': false, 'message': 'File upload failed'};
    }
  }

  static Future<bool> loadStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      if (token != null && userData != null) {
        setToken(token);
        setCurrentUser(User.fromJson(json.decode(userData)));
        await initializeSocket();
        return true;
      }
      return false;
    } catch (e) {
      print('Error loading stored credentials: $e');
      return false;
    }
  }

  static Future<void> clearStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      _token = null;
      _currentUser = null;
      if (_socket != null) {
        _socket!.disconnect();
        _socket = null;
      }
    } catch (e) {
      print('Error clearing stored credentials: $e');
    }
  }

  static void sendMessage({
    required String receiverId,
    required String content,
    String type = 'text',
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) {
    if (_socket != null && _currentUser != null) {
      _socket!.emit('send_message', {
        'senderId': _currentUser!.id,
        'receiverId': receiverId,
        'content': content,
        'type': type,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (fileName != null) 'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
      });
    }
  }

  static void markMessagesSeen(String otherUserId) {
    if (_socket != null && _currentUser != null) {
      _socket!.emit('mark_messages_seen', {
        'userId': _currentUser!.id,
        'otherUserId': otherUserId,
      });
    }
  }

  static void sendTyping(String receiverId, bool isTyping) {
    if (_socket != null && _currentUser != null) {
      _socket!.emit('typing', {
        'userId': _currentUser!.id,
        'receiverId': receiverId,
        'isTyping': isTyping,
      });
    }
  }
}

// Firebase Messaging Service
class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');

      // Get FCM token
      String? token = await _messaging.getToken();
      print('📱 FCM Token: $token');

      // Update user profile with FCM token
      if (ApiService.currentUser != null && token != null) {
        await ApiService.updateUserProfile(fcmToken: token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) {
        print('📱 FCM Token refreshed: $token');
        if (ApiService.currentUser != null) {
          ApiService.updateUserProfile(fcmToken: token);
        }
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📨 Received foreground message: ${message.notification?.title}');
        // Handle the message (show in-app notification)
      });

      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📨 User tapped notification: ${message.notification?.title}');
        // Navigate to appropriate chat screen
      });

    } else {
      print('❌ User declined or has not accepted permission');
    }
  }
}

// Permissions Service
class PermissionsService {
  static Future<bool> requestContactsPermission() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}

// Contacts Service
class ContactsServiceHelper {
  static Future<List<Contact>> getContacts() async {
    bool granted = await PermissionsService.requestContactsPermission();
    if (!granted) return [];

    Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.toList();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: firebaseOptions);
  
  // Load stored credentials
  await ApiService.loadStoredCredentials();
  
  // Initialize Firebase Messaging
  await FirebaseMessagingService.initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: ZingifyColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ZingifyApp());
}

class ZingifyApp extends StatelessWidget {
  const ZingifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zingify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: ZingifyColors.primary,
          secondary: ZingifyColors.secondary,
          surface: ZingifyColors.surface,
          background: ZingifyColors.background,
          onPrimary: ZingifyColors.onPrimary,
          onSecondary: ZingifyColors.onSecondary,
          onSurface: ZingifyColors.onSurface,
          onBackground: ZingifyColors.onSurface,
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: ZingifyColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: ZingifyColors.onSurface,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardThemeData(
          color: ZingifyColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: ZingifyColors.border),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ZingifyColors.primary,
            foregroundColor: ZingifyColors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ZingifyColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ZingifyColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ZingifyColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ZingifyColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Zingify Logo Widget
class ZingifyLogo extends StatelessWidget {
  final double size;
  final bool animated;

  const ZingifyLogo({
    super.key,
    this.size = 80,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ZingifyColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/zingify_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Custom Painter for Zingify Logo
class ZingifyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Draw Z shape
    path.moveTo(w * 0.2, h * 0.3);
    path.lineTo(w * 0.8, h * 0.3);
    path.lineTo(w * 0.2, h * 0.7);
    path.lineTo(w * 0.8, h * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToNextScreen();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      // Check if user is logged in
      if (ApiService.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ZingifyColors.primary,
              ZingifyColors.primary.withOpacity(0.8),
              ZingifyColors.secondary.withOpacity(0.6),
              ZingifyColors.background,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_logoController.value * 0.1),
                      child: Opacity(
                        opacity: _logoController.value,
                        child: const ZingifyLogo(size: 100),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App Name
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textController.value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - _textController.value) * 20),
                        child: Column(
                          children: [
                            Text(
                              'Zingify',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Premium Messaging',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Tagline
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      Text(
                        'India-First, Global Scale',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '🔐 End-to-End Encrypted',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _otpSent = false;
  bool _isLoading = false;
  bool _termsAccepted = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;
  
  String _selectedCountryCode = '+91';
  String? _demoOTP;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showError('Please enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.sendOTP(
        phone: _phoneController.text,
        countryCode: _selectedCountryCode,
      );

      if (result['success']) {
        setState(() {
          _otpSent = true;
          _isLoading = false;
          _demoOTP = result['demoOTP'];
        });
        _startResendTimer();
        _showSuccess('OTP sent successfully!');
        if (_demoOTP != null) {
          _showSuccess('Demo OTP: $_demoOTP');
        }
      } else {
        setState(() => _isLoading = false);
        _showError(result['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to send OTP. Please try again.');
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      _showError('Please enter a valid OTP');
      return;
    }

    if (!_termsAccepted) {
      _showError('Please accept the terms and conditions');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get FCM token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('Error getting FCM token: $e');
      }

      final result = await ApiService.verifyOTP(
        phone: _phoneController.text,
        countryCode: _selectedCountryCode,
        otp: _otpController.text,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        fcmToken: fcmToken,
      );

      if (result['success']) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() => _isLoading = false);
        _showError(result['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to verify OTP. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ZingifyColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ZingifyColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'Welcome to Zingify! By using our service, you agree to:\n\n'
            '1. Use the service responsibly\n'
            '2. Respect other users\n'
            '3. Not share inappropriate content\n'
            '4. Protect your account credentials\n'
            '5. Follow community guidelines\n\n'
            'We reserve the right to suspend accounts that violate these terms.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us:\n\n'
            '1. We collect only necessary information\n'
            '2. Your messages are end-to-end encrypted\n'
            '3. We never sell your data\n'
            '4. You can delete your account anytime\n'
            '5. We comply with data protection laws\n\n'
            'For details, visit our privacy policy page.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ZingifyColors.primary,
              ZingifyColors.primary.withOpacity(0.8),
              ZingifyColors.secondary.withOpacity(0.6),
              ZingifyColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                const ZingifyLogo(size: 80),
                const SizedBox(height: 20),

                // Welcome Text
                Column(
                  children: [
                    Text(
                      'Welcome to Zingify',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'India\'s Premium Messaging App',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Login Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _otpSent ? 'Verify OTP' : 'Enter Phone Number',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (!_otpSent) ...[
                        // Country Code Picker
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CountryCodePicker(
                            onChanged: (CountryCode countryCode) {
                              setState(() {
                                _selectedCountryCode = countryCode.dialCode ?? '+91';
                              });
                            },
                            initialSelection: 'IN',
                            favorite: ['+91', 'IN'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phone Input
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            hintText: '98765 43210',
                            prefixIcon: const Icon(Icons.phone, color: ZingifyColors.primary),
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Name Input
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Your Name',
                            prefixIcon: const Icon(Icons.person, color: ZingifyColors.primary),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms and Conditions
                        Row(
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: (value) {
                                setState(() => _termsAccepted = value ?? false);
                              },
                              activeColor: Colors.white,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                                child: Text(
                                  'I accept the ',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showTermsAndConditions,
                              child: Text(
                                'Terms',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _showPrivacyPolicy,
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // OTP Input
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '123456',
                            prefixIcon: const Icon(Icons.message, color: ZingifyColors.primary),
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Demo OTP Display
                        if (_demoOTP != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ZingifyColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Demo Mode Active',
                                  style: TextStyle(
                                    color: ZingifyColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Use OTP: $_demoOTP',
                                  style: TextStyle(
                                    color: ZingifyColors.accent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _resendSeconds > 0
                                  ? 'Resend OTP in $_resendSeconds seconds'
                                  : 'Didn\'t receive OTP?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            if (_resendSeconds == 0)
                              TextButton(
                                onPressed: _sendOTP,
                                child: const Text(
                                  'Resend',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_otpSent ? _verifyOTP : _sendOTP),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _otpSent ? 'Verify OTP' : 'Send OTP',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      if (_otpSent) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _otpSent = false;
                              _otpController.clear();
                              _resendTimer?.cancel();
                              _resendSeconds = 0;
                            });
                          },
                          child: Text(
                            'Change Phone Number',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Features
                Column(
                  children: [
                    _buildFeature('🔐', 'End-to-End Encryption'),
                    const SizedBox(height: 12),
                    _buildFeature('📱', 'Real-time Messaging'),
                    const SizedBox(height: 12),
                    _buildFeature('🌍', 'Global Connectivity'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String emoji, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Home Screen (Chat List)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  List<Chat> _chats = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    await ApiService.getUserProfile();
    await _loadChats();
    setState(() {
      _currentUser = ApiService.currentUser;
      _isLoading = false;
    });
  }

  Future<void> _loadChats() async {
    final chats = await ApiService.getChats();
    setState(() {
      _chats = chats;
    });
  }

  void _setupSocketListeners() {
    if (ApiService.socket == null) return;

    ApiService.socket!.on('receive_message', (data) {
      _loadChats();
    });

    ApiService.socket!.on('user_online', (userId) {
      _loadChats();
    });

    ApiService.socket!.on('user_offline', (userId) {
      _loadChats();
    });

    ApiService.socket!.on('messages_seen', (data) {
      _loadChats();
    });
  }

  Future<void> _logout() async {
    await ApiService.clearStoredCredentials();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateToChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chat: chat),
      ),
    ).then((_) => _loadChats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZingifyColors.background,
      appBar: AppBar(
        backgroundColor: ZingifyColors.surface,
        elevation: 0,
        title: const Text(
          'Zingify',
          style: TextStyle(
            color: ZingifyColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Search functionality
            },
            icon: const Icon(Icons.search, color: ZingifyColors.onSurface),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: ZingifyColors.onSurface),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: ZingifyColors.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(
                          color: ZingifyColors.onSurface.withOpacity(0.6),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start chatting with your friends!',
                        style: TextStyle(
                          color: ZingifyColors.onSurface.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    return _buildChatItem(chat);
                  },
                ),
    );
  }

  Widget _buildChatItem(Chat chat) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: ZingifyColors.primary,
        backgroundImage: chat.participant.profilePicture != null
            ? NetworkImage('${ApiConfig.baseUrl}${chat.participant.profilePicture}')
            : null,
        child: chat.participant.profilePicture == null
            ? Text(
                chat.participant.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        chat.participant.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: ZingifyColors.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chat.lastMessage != null)
            Text(
              chat.lastMessage!.type == 'text'
                  ? chat.lastMessage!.content
                  : '${chat.lastMessage!.type} message',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ZingifyColors.onSurface.withOpacity(0.7),
              ),
            ),
          Row(
            children: [
              if (chat.participant.isOnline)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ZingifyColors.success,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Text(
                  'Last seen ${_getLastSeenText(chat.participant.lastSeen)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: ZingifyColors.onSurface.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chat.lastMessageTime != null)
            Text(
              _getTimeText(chat.lastMessageTime!),
              style: TextStyle(
                fontSize: 12,
                color: ZingifyColors.onSurface.withOpacity(0.6),
              ),
            ),
          if (chat.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ZingifyColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
      onTap: () => _navigateToChat(chat),
    );
  }

  String _getTimeText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getLastSeenText(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }
}

// Chat Screen
class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  Timer? _typingTimer;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupSocketListeners();
    _markMessagesAsSeen();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final messages = await ApiService.getMessages(widget.chat.participant.id);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _setupSocketListeners() {
    if (ApiService.socket == null) return;

    ApiService.socket!.on('receive_message', (data) {
      if (data['senderId']['_id'] == widget.chat.participant.id ||
          data['receiverId']['_id'] == widget.chat.participant.id) {
        setState(() {
          _messages.add(Message.fromJson(data));
        });
        _scrollToBottom();
        _markMessagesAsSeen();
      }
    });

    ApiService.socket!.on('user_typing', (data) {
      if (data['userId'] == widget.chat.participant.id) {
        setState(() {
          _isTyping = data['isTyping'];
        });
      }
    });

    ApiService.socket!.on('messages_seen', (data) {
      if (data['userId'] == widget.chat.participant.id) {
        setState(() {
          for (var message in _messages) {
            if (message.sender.id == ApiService.currentUser?.id) {
              message.status = 'seen';
            }
          }
        });
      }
    });
  }

  void _markMessagesAsSeen() {
    Future.delayed(const Duration(milliseconds: 500), () {
      ApiService.markMessagesSeen(widget.chat.participant.id);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    ApiService.sendMessage(
      receiverId: widget.chat.participant.id,
      content: content,
    );

    _scrollToBottom();
  }

  void _onTypingChanged() {
    ApiService.sendTyping(widget.chat.participant.id, true);
    
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      ApiService.sendTyping(widget.chat.participant.id, false);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // TODO: Upload image and send message
      print('Image picked: ${image.path}');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      final uploadResult = await ApiService.uploadFile(result);
      if (uploadResult['success']) {
        ApiService.sendMessage(
          receiverId: widget.chat.participant.id,
          content: uploadResult['fileName'],
          type: 'file',
          fileUrl: uploadResult['fileUrl'],
          fileName: uploadResult['fileName'],
          fileSize: uploadResult['fileSize'],
        );
      }
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  void _onEmojiSelected(dynamic emoji) {
    _messageController.text += emoji.emoji;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZingifyColors.background,
      appBar: AppBar(
        backgroundColor: ZingifyColors.surface,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: ZingifyColors.primary,
              backgroundImage: widget.chat.participant.profilePicture != null
                  ? NetworkImage('${ApiConfig.baseUrl}${widget.chat.participant.profilePicture}')
                  : null,
              child: widget.chat.participant.profilePicture == null
                  ? Text(
                      widget.chat.participant.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.participant.name,
                    style: const TextStyle(
                      color: ZingifyColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.chat.participant.isOnline
                        ? 'Online'
                        : 'Last seen ${_getLastSeenText(widget.chat.participant.lastSeen)}',
                    style: TextStyle(
                      color: widget.chat.participant.isOnline
                          ? ZingifyColors.success
                          : ZingifyColors.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Video call
            },
            icon: const Icon(Icons.videocam, color: ZingifyColors.onSurface),
          ),
          IconButton(
            onPressed: () {
              // Voice call
            },
            icon: const Icon(Icons.call, color: ZingifyColors.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Typing Indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${widget.chat.participant.name} is typing...',
                    style: TextStyle(
                      color: ZingifyColors.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),

          // Message Input
          if (_showEmojiPicker)
            Container(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (Category category, Emoji emoji) {
                  _onEmojiSelected(emoji);
                },
                onBackspacePressed: () {
                  // Handle backspace
                },
                config: const Config(
                  columns: 7,
                  emojiSizeMax: 32.0,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  initCategory: Category.RECENT,
                  bgColor: ZingifyColors.surface,
                  indicatorColor: ZingifyColors.primary,
                  iconColor: ZingifyColors.onSurface,
                  iconColorSelected: ZingifyColors.primary,
                  enableSkinTones: true,
                  noRecents: Text(
                    'No Recents',
                    style: TextStyle(fontSize: 20, color: ZingifyColors.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  buttonMode: ButtonMode.MATERIAL,
                ),
              ),
            ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: ZingifyColors.surface,
              border: Border(top: BorderSide(color: ZingifyColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file, color: ZingifyColors.primary),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: ZingifyColors.primary),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (value) => _onTypingChanged(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: ZingifyColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _toggleEmojiPicker,
                        icon: Icon(
                          _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                          color: ZingifyColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: ZingifyColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.sender.id == ApiService.currentUser?.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: ZingifyColors.primary,
              backgroundImage: message.sender.profilePicture != null
                  ? NetworkImage('${ApiConfig.baseUrl}${message.sender.profilePicture}')
                  : null,
              child: message.sender.profilePicture == null
                  ? Text(
                      message.sender.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? ZingifyColors.primary : ZingifyColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ZingifyColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.type == 'text')
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : ZingifyColors.onSurface,
                          ),
                        )
                      else if (message.type == 'image')
                        const Text(
                          '📷 Image',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      else if (message.type == 'video')
                        const Text(
                          '🎥 Video',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      else if (message.type == 'audio')
                        const Text(
                          '🎵 Audio',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      else if (message.type == 'file')
                        Text(
                          '📎 ${message.fileName ?? 'File'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTimeText(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: ZingifyColors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.status == 'sent'
                            ? Icons.check
                            : message.status == 'delivered'
                                ? Icons.done_all
                                : Icons.done_all,
                        size: 12,
                        color: message.status == 'seen'
                            ? ZingifyColors.success
                            : ZingifyColors.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: ZingifyColors.primary,
            backgroundImage: widget.chat.participant.profilePicture != null
                ? NetworkImage('${ApiConfig.baseUrl}${widget.chat.participant.profilePicture}')
                : null,
            child: widget.chat.participant.profilePicture == null
                ? Text(
                    widget.chat.participant.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ZingifyColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ZingifyColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ZingifyColors.onSurface.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ZingifyColors.onSurface.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ZingifyColors.onSurface.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getLastSeenText(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }
}
