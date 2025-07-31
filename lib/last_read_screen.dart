import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:al_quran_app/surah_detail_screen.dart';

class LastReadScreen extends StatefulWidget {
  const LastReadScreen({super.key});

  @override
  State<LastReadScreen> createState() => _LastReadScreenState();
}

class _LastReadScreenState extends State<LastReadScreen> {
  Map<String, dynamic>? _lastReadData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLastRead();
  }

  Future<void> _fetchLastRead() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? lastReadJson = prefs.getString('lastRead');

      if (lastReadJson != null && lastReadJson.isNotEmpty) {
        setState(() {
          _lastReadData = Map<String, dynamic>.from(json.decode(lastReadJson));
          _isLoading = false;
        });
        print('Data bacaan terakhir berhasil dimuat dari SharedPreferences: $_lastReadData');
      } else {
        setState(() {
          _errorMessage = 'Belum ada bacaan terakhir yang tersimpan.';
          _isLoading = false;
        });
        print('Belum ada data bacaan terakhir yang tersimpan di SharedPreferences.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat bacaan terakhir dari SharedPreferences: $e';
        _isLoading = false;
      });
      print('Error memuat bacaan terakhir dari SharedPreferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'Surat Terakhir Dibaca',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.green)
            : _errorMessage != null
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.blueGrey, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchLastRead,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        )
            : _lastReadData == null
            ? const Text(
          'Belum ada bacaan terakhir yang tersimpan.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        )
            : Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Terakhir Dibaca:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 15),
                Text(
                  'Surat: ${_lastReadData!['surahName']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Ayat: ${_lastReadData!['ayahNumber']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigasi ke halaman detail surat dan ayat terakhir
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SurahDetailScreen(
                          surahNumber: _lastReadData!['surahNumber'],
                          surahName: _lastReadData!['surahName'],
                          numberOfAyahs: _lastReadData!['numberOfAyahs'],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text('Lanjutkan Bacaan', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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