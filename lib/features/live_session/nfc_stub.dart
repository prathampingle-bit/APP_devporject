// This is a stub for NFC scanning in a frontend-only environment.
// Replace with `nfc_manager` or `flutter_nfc_kit` when integrating with real devices.

import 'dart:math';

class NfcStub {
  Future<String> scan() async {
    await Future.delayed(const Duration(seconds: 1));
    // produce a pseudo UID
    final rnd = Random();
    return List.generate(8, (_) => rnd.nextInt(256)).map((b) => b.toRadixString(16).padLeft(2,'0')).join();
  }
}

final nfcStub = NfcStub();
