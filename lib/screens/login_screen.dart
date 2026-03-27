import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showError('Please enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // For demo purposes, simulate OTP sending
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });

      _showSuccess('OTP sent successfully! Use 123456 for demo.');
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

    // Demo OTP verification
    if (_otpController.text == '123456') {
      setState(() => _isLoading = true);

      try {
        // Simulate authentication
        await Future.delayed(const Duration(seconds: 1));
        
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('phoneNumber', _phoneController.text);

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/chat-list');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Failed to verify OTP. Please try again.');
      }
    } else {
      _showError('Invalid OTP. Use 123456 for demo.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ZingifyColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const ZingifyLogo(size: 100)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 40),

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
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 60),

                  // Login Form
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          _otpSent ? 'Enter OTP' : 'Enter Phone Number',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ZingifyColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (!_otpSent) ...[
                          // Phone Input
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: '+91 98765 43210',
                              prefixIcon: const Icon(Icons.phone, color: ZingifyColors.primary),
                              counterText: '',
                            ),
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
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Demo OTP: 123456',
                            style: TextStyle(
                              fontSize: 12,
                              color: ZingifyColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
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
                              });
                            },
                            child: Text(
                              'Change Phone Number',
                              style: TextStyle(
                                color: ZingifyColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 40),

                  // Features
                  Column(
                    children: [
                      _buildFeature('🔐', 'End-to-End Encryption'),
                      const SizedBox(height: 12),
                      _buildFeature('🌙', 'Dark Mode Support'),
                      const SizedBox(height: 12),
                      _buildFeature('📱', 'Cross-Platform Sync'),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                ],
              ),
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
