import 'package:flutter/material.dart';
import 'homepage.dart';

class BerandaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          'Info Buah Jeruk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟠 Tambahan gambar jeruk di bagian atas
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/gambar_jeruk.png', // Pastikan file ini ada di folder assets/images
                  width: 300,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Macam-macam Jeruk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('- Jeruk Mandarin:Rasanya manis dan segar, sering dikonsumsi langsung.'),
            Text('- Jeruk Tahiti: jenis jeruk nipis, tidak berbiji,sebagai penyedap masakan atau minuman '),
            Text('- Jeruk Toronja: dikenal juga sebagai grapefruit, rasanya asam-manis, sering dikonsumsi sebagai jus '),
            Text('- Jeruk Valencia: cocok dibuat jus, mengandung banyak air dan rasanya manis.'),
            SizedBox(height: 16),
            Text(
              'Manfaat Jeruk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('- Sumber vitamin C yang tinggi.'),
            Text('- Meningkatkan imunitas tubuh.'),
            Text('- Menjaga kesehatan kulit.'),
            Text('- Menurunkan risiko penyakit jantung.'),
            Text('- Melancarkan pencernaan.'),
            SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('Mulai Deteksi', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
