import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;

class ModelService {
  late final Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model_final_glcm.tflite');
    print("✅ Model loaded");
  }

  Future<List<double>> predictImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) throw Exception("❌ Gagal decode gambar.");

    final resized = img.copyResize(decodedImage, width: 150, height: 150);
    final input = await extractFeatures(resized);
    final output = List.filled(8, 0.0).reshape([1, 8]);

    _interpreter.run(input, output);
    return List<double>.from(output[0]);
  }

  Future<List<List<double>>> extractFeatures(img.Image image) async {
    final glcmFeatures = _extractGLCM(image);
    final hsvFeatures = _extractHSV(image);
    final statsFeatures = _extractGrayStatistics(image);
    return [
      [...glcmFeatures, ...hsvFeatures, ...statsFeatures]
    ];
  }

  List<double> _extractGLCM(img.Image image) {
    final gray = _toGrayscale(image);
    final angles = [
      0,
      math.pi / 6,
      math.pi / 4,
      math.pi / 3,
      math.pi / 2,
      2 * math.pi / 3,
      3 * math.pi / 4,
      5 * math.pi / 6
    ];
    final distances = [1, 2, 3, 4, 5];

    final List<double> features = [];
    for (final d in distances) {
      for (final angle in angles) {
        final glcm = _calculateGLCM(gray, d, angle.toDouble());
        features.addAll([
          _contrast(glcm),
          _dissimilarity(glcm),
          _homogeneity(glcm),
          _energy(glcm),
          _correlation(glcm),
        ]);
      }
    }
    return features;
  }

  List<List<double>> _calculateGLCM(List<List<int>> gray, int d, double angle) {
    final height = gray.length;
    final width = gray[0].length;
    final glcm = List.generate(256, (_) => List.filled(256, 0.0));

    final dx = (d * math.cos(angle)).round();
    final dy = -(d * math.sin(angle)).round();

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final nx = x + dx;
        final ny = y + dy;
        if (nx >= 0 && ny >= 0 && nx < width && ny < height) {
          final i = gray[y][x];
          final j = gray[ny][nx];
          glcm[i][j] += 1.0;
        }
      }
    }

    final total = glcm.fold(0.0, (sum, row) => sum + row.reduce((a, b) => a + b));
    return glcm
        .map((row) => row.map((v) => v / (total > 0 ? total : 1)).toList())
        .toList();
  }

  List<List<int>> _toGrayscale(img.Image image) => List.generate(
    image.height,
        (y) => List.generate(
      image.width,
          (x) {
        final pixel = image.getPixel(x, y);
        final r = (pixel >> 16) & 0xFF;
        final g = (pixel >> 8) & 0xFF;
        final b = (pixel) & 0xFF;
        return (0.299 * r + 0.587 * g + 0.114 * b).round();
      },
    ),
  );

  double _contrast(List<List<double>> glcm) =>
      _glcmStat(glcm, (i, j, p) => math.pow(i - j, 2) * p);
  double _dissimilarity(List<List<double>> glcm) =>
      _glcmStat(glcm, (i, j, p) => (i - j).abs() * p);
  double _homogeneity(List<List<double>> glcm) =>
      _glcmStat(glcm, (i, j, p) => p / (1.0 + math.pow(i - j, 2)));
  double _energy(List<List<double>> glcm) =>
      _glcmStat(glcm, (i, j, p) => math.pow(p, 2).toDouble());

  double _correlation(List<List<double>> glcm) {
    double meanI = 0, meanJ = 0;
    for (int i = 0; i < 256; i++) {
      for (int j = 0; j < 256; j++) {
        final p = glcm[i][j];
        meanI += i * p;
        meanJ += j * p;
      }
    }

    double stdI = 0, stdJ = 0;
    for (int i = 0; i < 256; i++) {
      for (int j = 0; j < 256; j++) {
        final p = glcm[i][j];
        stdI += math.pow(i - meanI, 2) * p;
        stdJ += math.pow(j - meanJ, 2) * p;
      }
    }

    stdI = math.sqrt(stdI);
    stdJ = math.sqrt(stdJ);

    if (stdI * stdJ == 0) return 0;

    double correlation = 0;
    for (int i = 0; i < 256; i++) {
      for (int j = 0; j < 256; j++) {
        final p = glcm[i][j];
        correlation += (i - meanI) * (j - meanJ) * p;
      }
    }
    return correlation / (stdI * stdJ);
  }

  double _glcmStat(
      List<List<double>> glcm, double Function(int, int, double) op) {
    double result = 0;
    for (int i = 0; i < 256; i++) {
      for (int j = 0; j < 256; j++) {
        result += op(i, j, glcm[i][j]);
      }
    }
    return result;
  }

  List<double> _extractHSV(img.Image image) {
    double hSum = 0, sSum = 0, vSum = 0;
    int count = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = (pixel >> 16) & 0xFF;
        final g = (pixel >> 8) & 0xFF;
        final b = (pixel) & 0xFF;
        final hsv = _rgbToHsv(r, g, b);
        hSum += hsv[0];
        sSum += hsv[1];
        vSum += hsv[2];
        count++;
      }
    }
    return [hSum / count, sSum / count, vSum / count];
  }

  List<double> _rgbToHsv(int r, int g, int b) {
    final rF = r / 255.0, gF = g / 255.0, bF = b / 255.0;
    final maxVal = [rF, gF, bF].reduce(math.max);
    final minVal = [rF, gF, bF].reduce(math.min);
    double h = 0, s = 0, v = maxVal;

    final d = maxVal - minVal;
    s = maxVal == 0 ? 0 : d / maxVal;

    if (maxVal != minVal) {
      if (maxVal == rF) {
        h = (gF - bF) / d + (gF < bF ? 6 : 0);
      } else if (maxVal == gF) {
        h = (bF - rF) / d + 2;
      } else {
        h = (rF - gF) / d + 4;
      }
      h /= 6;
    }
    return [h * 360, s * 100, v * 100];
  }

  List<double> _extractGrayStatistics(img.Image image) {
    final grayValues = <int>[];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = (pixel >> 16) & 0xFF;
        final g = (pixel >> 8) & 0xFF;
        final b = (pixel) & 0xFF;
        grayValues.add((0.299 * r + 0.587 * g + 0.114 * b).round());
      }
    }

    final mean = grayValues.reduce((a, b) => a + b) / grayValues.length;
    final std = math.sqrt(grayValues.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / grayValues.length);
    final variance = std * std;
    final minVal = grayValues.reduce(math.min);
    final maxVal = grayValues.reduce(math.max);
    grayValues.sort();
    final median = grayValues[grayValues.length ~/ 2].toDouble();

    return [mean, std, variance, minVal.toDouble(), maxVal.toDouble(), median];
  }
}

