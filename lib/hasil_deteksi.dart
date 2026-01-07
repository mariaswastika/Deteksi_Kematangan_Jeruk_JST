import 'dart:io';
import 'package:flutter/material.dart';
import 'riwayat_deteksi.dart';

class HasilDeteksiPage extends StatelessWidget {
  final File image;
  final String jenisJeruk;
  final String kematangan;

  HasilDeteksiPage({
    required this.image,
    required this.jenisJeruk,
    required this.kematangan,
  });

  void _simpanKeRiwayat(BuildContext context) {
    RiwayatDeteksiPageState.tambahRiwayat(image, jenisJeruk, kematangan);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hasil berhasil disimpan ke Riwayat!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HASIL DETEKSI'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Jenis Jeruk: $jenisJeruk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kematangan: $kematangan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => _simpanKeRiwayat(context),
                  child: Text('Simpan', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Kembali', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
