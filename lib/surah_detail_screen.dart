import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

// Model data untuk Ayah (ayat) dari API equran.id
class Ayah {
  final int numberInSurah;
  final String arabicText;
  final String transliteration;
  final String indonesianTranslation;

  Ayah({
    required this.numberInSurah,
    required this.arabicText,
    required this.transliteration,
    required this.indonesianTranslation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      numberInSurah: json['nomor'],
      arabicText: json['ar'],
      transliteration: json['tr'],
      indonesianTranslation: json['idn'],
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int numberOfAyahs;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.numberOfAyahs,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<Ayah> _ayahs = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _fetchedSurahName = '';
  int _fetchedNumberOfAyahs = 0;

  final Dio _dio = Dio();
  final ScrollController _scrollController = ScrollController();

  _SurahDetailScreenState() {
    print('SurahDetailScreen: Constructor State dipanggil.');
  }

  @override
  void initState() {
    super.initState();
    print('SurahDetailScreen: initState dipanggil.');
    _fetchSurahsDetail();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveLastRead(int surahNumber, String surahName, int ayahNumber, int numberOfAyahs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastReadData = {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'ayahNumber': ayahNumber,
        'numberOfAyahs': numberOfAyahs,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString('lastRead', json.encode(lastReadData));
      print('Bacaan terakhir disimpan: $lastReadData');
    } catch (e) {
      print('Error menyimpan bacaan terakhir: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 50 && _ayahs.isNotEmpty) {
        final lastAyah = _ayahs.last;
        _saveLastRead(widget.surahNumber, _fetchedSurahName, lastAyah.numberInSurah, _fetchedNumberOfAyahs);
      }
    }
  }

  Future<void> _fetchSurahsDetail() async {
    print('SurahDetailScreen: Memulai _fetchSurahsDetail.');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final apiUrl = 'https://equran.id/api/surat/${widget.surahNumber}';
    print('URL API equran.id: $apiUrl');

    try {
      final response = await _dio.get(apiUrl);
      print('Status Code API equran.id: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        print('Data API equran.id berhasil diterima.');

        if (data != null && data['ayat'] is List) {
          final List<dynamic> ayatsJson = data['ayat'];

          List<Ayah> loadedAyahs = [];
          for (var jsonAyat in ayatsJson) {
            loadedAyahs.add(Ayah.fromJson(jsonAyat));
          }
          print('Jumlah ayat yang dimuat dari equran.id: ${loadedAyahs.length}');

          setState(() {
            _ayahs = loadedAyahs;
            _fetchedSurahName = data['namaLatin'] ?? widget.surahName;
            _fetchedNumberOfAyahs = data['jumlahAyat'] ?? widget.numberOfAyahs;
            _isLoading = false;
          });
          if (loadedAyahs.isNotEmpty) {
            _saveLastRead(widget.surahNumber, _fetchedSurahName, 1, _fetchedNumberOfAyahs);
          }
        } else {
          setState(() {
            _errorMessage = 'Struktur data ayat dari equran.id tidak lengkap atau tidak sesuai.';
            _isLoading = false;
          });
          print('Error: Struktur data ayat equran.id tidak lengkap.');
        }
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat ayat dari equran.id. Status Code: ${response.statusCode}. Coba periksa koneksi internet Anda.';
          _isLoading = false;
        });
        print('Error: Gagal memuat ayat dari equran.id. Status Code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan Dio: ${e.message}. Pastikan koneksi internet Anda aktif.';
        _isLoading = false;
      });
      print('Error Dio Catch: $e');
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan tidak terduga: $e. Pastikan koneksi internet Anda aktif.';
        _isLoading = false;
      });
      print('Error Catch Umum: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SurahDetailScreen: build dipanggil.');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fetchedSurahName.isNotEmpty ? _fetchedSurahName : widget.surahName,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_fetchedNumberOfAyahs > 0 ? _fetchedNumberOfAyahs : widget.numberOfAyahs} Ayat',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.location_on, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.green),
      )
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchSurahsDetail,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: _ayahs.length,
        itemBuilder: (context, index) {
          final ayah = _ayahs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${ayah.numberInSurah}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ayah.arabicText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ayah.transliteration,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ayah.indonesianTranslation,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}