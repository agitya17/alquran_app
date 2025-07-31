import 'package:flutter/material.dart';
import 'package:al_quran_app/surah_list_screen.dart';
import 'package:flutter/services.dart';
import 'package:al_quran_app/last_read_screen.dart';
// import 'dart:convert';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logika inisialisasi tadinya pake Firebase dihapus karena beralih ke shared_preferences
  /*
  final firebaseConfigMap = Map<String, dynamic>.from(
    (await Future.value(
      _firebase_config.isNotEmpty ? Map<String, dynamic>.from(json.decode(_firebase_config)) : {},
    )),
  );

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfigMap['apiKey'] ?? 'YOUR_API_KEY',
      appId: firebaseConfigMap['appId'] ?? 'YOUR_APP_ID',
      messagingSenderId: firebaseConfigMap['messagingSenderId'] ?? 'YOUR_MESSAGING_SENDER_ID',
      projectId: firebaseConfigMap['projectId'] ?? 'YOUR_PROJECT_ID',
      storageBucket: firebaseConfigMap['storageBucket'] ?? 'YOUR_STORAGE_BUCKET',
    ),
  );

  final auth = FirebaseAuth.instance;
  if (__initial_auth_token.isNotEmpty) {
    await auth.signInWithCustomToken(__initial_auth_token);
    print('Signed in with custom token.');
  } else {
    await auth.signInAnonymously();
    print('Signed in anonymously.');
  }
  */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Quran Ar-Risalah',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/alquran_icon.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.menu_book,
                  size: 150,
                  color: Colors.black54,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Al-Quran Ar-Risalah',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Masuk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/masjid_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Text(
                    'Background Image Placeholder',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },
          ),
          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Selamat Datang Di Aplikasi    Al-Quran',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Ar-Risalah',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.yellow,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    print('Tombol "Baca Alquran" diklik!');
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SurahListScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Baca Alquran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print('Tombol "Surat Terakhir Dibaca" diklik!');
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LastReadScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Surat Terakhir Dibaca',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}