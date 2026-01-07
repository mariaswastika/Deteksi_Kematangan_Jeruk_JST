import 'package:flutter/material.dart';
import 'dart:io';

class RiwayatDeteksiPage extends StatefulWidget {
  const RiwayatDeteksiPage({Key? key}) : super(key: key);

  @override
  RiwayatDeteksiPageState createState() => RiwayatDeteksiPageState();
}

class RiwayatDeteksiPageState extends State<RiwayatDeteksiPage> {
  static List<Map<String, dynamic>> riwayat = []; // 🔹 Tetap menggunakan static

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RIWAYAT DETEKSI'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: riwayat.isEmpty
                  ? Center(child: Text('Belum ada riwayat deteksi.'))
                  : ListView.builder(
                itemCount: riwayat.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: riwayat[index]['image'] != null
                              ? Image.file(riwayat[index]['image'], fit: BoxFit.cover)
                              : Center(
                            child: Text(
                              'Gambar\nTidak Ada',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      title: Text('Jenis: ${riwayat[index]['jenis']}'),
                      subtitle: Text('Kematangan: ${riwayat[index]['kematangan']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _hapusRiwayat(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Kembali', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Fungsi untuk menambah riwayat deteksi
  static void tambahRiwayat(File image, String jenis, String kematangan) {
    riwayat.add({
      'image': image,
      'jenis': jenis,
      'kematangan': kematangan,
    });
  }

  // 🔹 Fungsi untuk menghapus riwayat berdasarkan indeks
  void _hapusRiwayat(int index) {
    setState(() {
      riwayat.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Riwayat berhasil dihapus!')),
    );
  }
}
