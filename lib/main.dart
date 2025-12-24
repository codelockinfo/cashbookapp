import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'services/token_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookify',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

// 🟦 Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WebViewPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ Custom logo from assets
              const Image(
                image: AssetImage('assets/logo.png'),
                width: 120, // adjust size as you like
                height: 120,
              ),
              const SizedBox(height: 20),

              // 🌈 Gradient text (like CSS linear-gradient)
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF667eea), // primary color
                    Color(0xFF764ba2), // secondary color
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'Bookify',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // must be white for gradient to show
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- WebView With File Upload --------------------

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? webController;
  bool isLoading = true;
  String? webViewUrl;
  bool tokenReceived = false;

  @override
  void initState() {
    super.initState();
    _loadWebViewWithToken();
  }

  Future<void> _loadWebViewWithToken() async {
    // Get token from SharedPreferences
    final token = await TokenManager.getToken();
    
    // Also verify using hasToken() method
    final hasToken = await TokenManager.hasToken();
    
    print("📱 ========== Token Check on App Launch ==========");
    print("📱 Checking for saved token in SharedPreferences...");
    print("📱 Token value: ${token ?? 'null'}");
    print("📱 Has token (hasToken()): $hasToken");
    
    if (token != null && token.isNotEmpty) {
      print("✅ Token found in SharedPreferences!");
      print("✅ Token length: ${token.length} characters");
      print("✅ Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...");
    } else {
      print("⚠️ No token found in SharedPreferences");
      print("⚠️ User needs to login");
    }
    print("📱 ===============================================");
    
    // Base URL
    String baseUrl = "https://bookify.happyeventsurat.com";
    
    // If token exists, use app-login.php endpoint for auto-login
    if (token != null && token.isNotEmpty) {
      // Use app-login.php endpoint with token for auto-login
      webViewUrl = "$baseUrl/app-login.php?token=$token";
      print("🔑 Loading WebView WITH token (auto-login): $webViewUrl");
      print("🔑 User will be automatically logged in!");
    } else {
      // No token, load login page
      webViewUrl = "$baseUrl/";
      print("🔐 Loading WebView WITHOUT token (login page): $webViewUrl");
      print("🔐 User needs to login manually");
    }
    
    setState(() {});
  }

  // Handle token received from PHP via URL
  Future<void> _handleTokenReceived(String token) async {
    if (tokenReceived) {
      print("ℹ️ Token already received and saved, skipping...");
      return; // Prevent multiple saves
    }
    
    print("🎉 ========== Token Received from Login ==========");
    print("🎉 Token received from URL: $token");
    print("🎉 Token length: ${token.length} characters");
    tokenReceived = true;
    
    // Save token to SharedPreferences
    print("💾 Saving token to SharedPreferences...");
    final saved = await TokenManager.saveToken(token);
    
    if (saved) {
      print("✅ Token saved successfully to SharedPreferences!");
      
      // Verify it was saved by reading it back
      final verifyToken = await TokenManager.getToken();
      if (verifyToken == token) {
        print("✅ Token verification: SUCCESS - Token matches!");
        print("✅ Token will be used for auto-login on next app launch");
      } else {
        print("⚠️ Token verification: FAILED - Token mismatch!");
      }
    } else {
      print("❌ Failed to save token to SharedPreferences");
    }
    print("🎉 ===============================================");
  }

  // Extract token from URL if present
  void _checkUrlForToken(String? url) {
    if (url == null) {
      print("⚠️ URL is null, cannot check for token");
      return;
    }
    
    if (tokenReceived) {
      print("ℹ️ Token already received, skipping check");
      return;
    }
    
    print("🔍 Checking URL for token: $url");
    
    final uri = Uri.tryParse(url);
    if (uri != null) {
      print("📋 URL query parameters: ${uri.queryParameters}");
      
      // Check for 'token' parameter
      if (uri.queryParameters.containsKey('token')) {
        final token = uri.queryParameters['token'];
        print("🎯 Found 'token' parameter: $token");
        if (token != null && token.isNotEmpty) {
          _handleTokenReceived(token);
        } else {
          print("⚠️ Token parameter is empty");
        }
      }
      // Also check for 'app-login' parameter (if your backend uses that)
      else if (uri.queryParameters.containsKey('app-login')) {
        final token = uri.queryParameters['app-login'];
        print("🎯 Found 'app-login' parameter: $token");
        if (token != null && token.isNotEmpty) {
          _handleTokenReceived(token);
        } else {
          print("⚠️ app-login parameter is empty");
        }
      } else {
        print("ℹ️ No token parameter found in URL");
      }
    } else {
      print("❌ Failed to parse URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wait for URL to be loaded
    if (webViewUrl == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(webViewUrl!),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
              ),
              onWebViewCreated: (controller) {
                webController = controller;
              },
              onLoadStart: (controller, url) {
                print("🌐 Loading: $url");
                // Check URL for token parameter
                _checkUrlForToken(url.toString());
              },
              onLoadStop: (controller, url) {
                setState(() => isLoading = false);
                print("✅ Loaded: $url");
                // Check URL for token parameter
                _checkUrlForToken(url.toString());
              },
              // Handle JavaScript messages from WebView (optional)
              // This allows your website to send token back to app if needed
              onConsoleMessage: (controller, consoleMessage) {
                print("WebView Console: ${consoleMessage.message}");
              },
            ),

            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
