import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:al_quran_app/surah_detail_screen.dart';

class Surah {
  final int number;
  final String englishName;
  final String arabicName;
  final int numberOfAyahs;
  bool isFavorite;

  Surah({
    required this.number,
    required this.englishName,
    required this.arabicName,
    required this.numberOfAyahs,
    this.isFavorite = false,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      englishName: json['englishName'],
      arabicName: json['name'], // 'name' di API adalah nama Arab
      numberOfAyahs: json['numberOfAyahs'],
    );
  }
}

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  List<Surah> _allSurahs = [];
  List<Surah> _filteredSurahs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSurahs();
    _searchController.addListener(_filterSurahs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSurahs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse('http://api.alquran.cloud/v1/surah'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> surahsJson = data['data'];

        setState(() {
          _allSurahs = surahsJson.map((json) => Surah.fromJson(json)).toList();
          _filteredSurahs = _allSurahs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data surat. Status Code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan: $e';
        _isLoading = false;
      });
    }
  }

  void _filterSurahs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahs = _allSurahs.where((surah) {
        return surah.englishName.toLowerCase().contains(query) ||
            surah.arabicName.toLowerCase().contains(query) ||
            surah.number.toString().contains(query);
      }).toList();
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      _filteredSurahs[index].isFavorite = !_filteredSurahs[index].isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'Mari Kita Mulai Baca Al Qurannya',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari surah...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              ),
            ),
          ),
          _isLoading
              ? const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          )
              : _errorMessage != null
              ? Expanded(
            child: Center(
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
                      onPressed: _fetchSurahs,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: _filteredSurahs.length,
              itemBuilder: (context, index) {
                final surah = _filteredSurahs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(
                        surah.number.toString(),
                        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${surah.englishName} ${surah.arabicName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${surah.numberOfAyahs} Ayat',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        surah.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: surah.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleFavorite(index);
                      },
                    ),
                    onTap: () {
                      print('SurahListScreen: Mengirim ke SurahDetailScreen. Surah: ${surah.englishName} (${surah.number})'); // Debugging
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen( // Kembali ke SurahDetailScreen
                            surahNumber: surah.number,
                            surahName: surah.englishName,
                            numberOfAyahs: surah.numberOfAyahs,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}