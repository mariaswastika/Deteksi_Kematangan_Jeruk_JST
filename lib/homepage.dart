import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'hasil_deteksi.dart';
import 'riwayat_deteksi.dart';
import 'berandapage.dart';
import 'api_service.dart'; // Ganti dari api_service.dart

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final picker = ImagePicker();
  final ModelService _modelService = ModelService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _modelService.loadModel(); // Memastikan model diload di awal
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengambilan gambar dibatalkan.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $error')),
      );
    }
  }

  void _resetImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _predictAndNavigate(File image) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prediction = await _modelService.predictImage(image);

      int maxIndex = prediction.indexWhere(
            (v) => v == prediction.reduce((a, b) => a > b ? a : b),
      );

      List<String> labels = [
        "Mandarino - Matang",
        "Mandarino - Mentah",
        "Tahiti - Matang",
        "Tahiti - Mentah",
        "Toronja - Matang",
        "Toronja - Mentah",
        "Valencia - Matang",
        "Valencia - Mentah",
      ];

      String label = labels[maxIndex];
      List<String> split = label.split(" - ");
      String jenisJeruk = split[0];
      String kematangan = split[1];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilDeteksiPage(
            image: image,
            jenisJeruk: jenisJeruk,
            kematangan: kematangan,
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal melakukan prediksi: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRiwayatDeteksi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RiwayatDeteksiPage()),
    );
  }

  void _navigateToBeranda() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BerandaPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          'Deteksi Kematangan Jeruk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Text('Pilih dari Galeri'),
                  ),
                  SizedBox(width: 30),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: Text('Gunakan Kamera'),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                width: 250,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image == null
                    ? Center(
                  child: Text(
                    'GAMBAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 30),
              if (_isLoading)
                CircularProgressIndicator()
              else if (_image != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _resetImage,
                      child: Text('Ulangi'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _predictAndNavigate(_image!),
                      child: Text('Lanjut'),
                    ),
                  ],
                ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _navigateToRiwayatDeteksi,
                child: Text('Riwayat Deteksi'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: _navigateToBeranda,
                child: Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
