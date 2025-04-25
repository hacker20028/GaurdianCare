import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (assumes you already have the configuration set up)
  await Firebase.initializeApp();

  runApp(const GuardianCareApp());
}

class GuardianCareApp extends StatelessWidget {
  const GuardianCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GuardianCare',
      theme: ThemeData(
        primaryColor: const Color(0xFF5D3FD3), // Purple primary color
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D3FD3),
          primary: const Color(0xFF5D3FD3),
          secondary: const Color(0xFFE5446D), // Red-pink for emergency
          tertiary: const Color(0xFF4D88FF), // Blue for health stats
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D3FD3),
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 18.0),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F8), // Light background
      ),
      // Directly show the DirectAccessScreen which will navigate to Home Screen
      home: const DirectAccessScreen(),
    );
  }
}

// This class bypasses authentication and directly goes to the home screen
class DirectAccessScreen extends StatefulWidget {
  const DirectAccessScreen({Key? key}) : super(key: key);

  @override
  State<DirectAccessScreen> createState() => _DirectAccessScreenState();
}

class _DirectAccessScreenState extends State<DirectAccessScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for a moment to show splash screen then navigate to home
    Future.delayed(const Duration(seconds: 2), () {
      // Create a mock user for testing
      final mockUser = MockUser(
        displayName: 'Rudra',
        email: 'rudra@example.com',
        photoURL: null,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(user: mockUser)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while "authenticating"
    return Scaffold(
      backgroundColor: const Color(0xFF5D3FD3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Color(0xFF5D3FD3),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              'GuardianCare',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            const Text(
              'Your Health Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// This is a simple mock implementation of User for testing
class MockUser implements User {
  @override
  final String? displayName;

  @override
  final String? email;

  @override
  final String? photoURL;

  MockUser({
    this.displayName,
    this.email,
    this.photoURL,
  });

  // Required overrides with minimal implementation for testing
  @override
  Future<void> delete() async {}

  @override
  String get uid => 'mock-user-id';

  @override
  bool get emailVerified => true;

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock-token';

  @override
  bool get isAnonymous => false;

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    throw UnimplementedError();
  }

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}

  @override
  Future<User> unlink(String providerId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateEmail(String newEmail) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {}

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {}

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get tenantId => null;

  @override
  String get providerId => 'mock-provider';

  @override
  String? get refreshToken => 'mock-refresh-token';

  @override
  String? get phoneNumber => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Original Auth Gate class is kept but commented out
/*
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // If the user is authenticated, go to home screen
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(user: snapshot.data!);
        }

        // Show login screen if user is not authenticated
        return const SignInScreen();
      },
    );
  }
}
*/

// Original SplashScreen class is kept but commented out since we use the one in DirectAccessScreen
/*
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D3FD3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Color(0xFF5D3FD3),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              'GuardianCare',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            const Text(
              'Your Health Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// Original SignInScreen class is kept but commented out
/*
class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  String? _errorMessage;

  // Sign in with Google
  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Begin Google sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancelled the sign-in, we don't want to continue
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain auth details from the Google Sign-In
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a Firebase credential with the Google auth details
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);

      // The auth state listener will handle navigation

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sign in failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // App Name
                Text(
                  'GuardianCare',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                // Tagline
                const Text(
                  'Your Health Companion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                // Welcome message
                const Text(
                  'Welcome to GuardianCare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'An easy way to manage your health, medications, and connect with caregivers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                // Error message if any
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Google Sign In Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: _isLoading
                      ? Container(width: 24)
                      : const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue),
                  label: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                      : const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Terms & Privacy policy text
                const Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
*/