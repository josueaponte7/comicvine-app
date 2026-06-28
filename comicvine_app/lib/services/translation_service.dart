// Servicio de traducción on-device (inglés -> español), compartido por toda la app.
// Singleton: una sola instancia viva, reutilizada por lista y detalle.

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  // Instancia única compartida.
  static final TranslationService instance = TranslationService._interno();
  TranslationService._interno();

  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.spanish,
  );

  final _modelManager = OnDeviceTranslatorModelManager();

  bool _listo = false;

  // Prepara el modelo de español. Se llama una vez al arrancar la app.
  Future<void> preparar() async {
    if (_listo) return;
    final descargado = await _modelManager
        .isModelDownloaded(TranslateLanguage.spanish.bcpCode);
    if (!descargado) {
      await _modelManager.downloadModel(
        TranslateLanguage.spanish.bcpCode,
        isWifiRequired: false,
      );
    }
    _listo = true;
  }

  // Traduce un texto. Si el modelo aún no está listo, lo prepara primero.
  Future<String> traducir(String texto) async {
    if (texto.trim().isEmpty) return texto;
    if (!_listo) await preparar();
    return _translator.translateText(texto);
  }
}