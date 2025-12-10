import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcVerificationPage extends StatefulWidget {
  const NfcVerificationPage({Key? key}) : super(key: key);

  @override
  State<NfcVerificationPage> createState() => _NfcVerificationPageState();
}

class _NfcVerificationPageState extends State<NfcVerificationPage> {
  // UI State Variables
  String _message = "Ready to Scan";
  bool _isScanning = false;
  Color _statusColor = Colors.blueGrey;
  IconData _statusIcon = Icons.sensors;

  // Mock Data: In a real app, this comes from your backend/API
  final String _currentRoomId = "LAB-304";
  final List<String> _authorizedFacultyIds = ["504F3A", "AB12CD", "04E2"];

  @override
  void dispose() {
    // Ensure we stop the session if the user leaves the screen
    NfcManager.instance.stopSession();
    super.dispose();
  }

  /// Starts the NFC scanning session
  void _startNfcScan() async {
    // 1. Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _message = "NFC is not available on this device.";
        _statusColor = Colors.red;
        _statusIcon = Icons.error_outline;
      });
      return;
    }

    setState(() {
      _isScanning = true;
      _message = "Hold Faculty ID near the back of the device...";
      _statusColor = Colors.orange;
      _statusIcon = Icons.wifi_tethering;
    });

    // 2. Start Session
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // This code runs when a tag is detected
        try {
          // 3. Extract Data (Using NDEF or Identifier)
          // Note: Different cards store data differently.
          // Here we look for a generic identifier or NDEF payload.
          String? scannedId = _parseTagData(tag);

          if (scannedId != null) {
            _verifyAccess(scannedId);
          } else {
            throw Exception("Empty Tag");
          }
        } catch (e) {
          _handleError("Read Error: Please try again.");
        } finally {
          // Stop session on iOS (Android stops automatically on simple reads usually)
          // keeping it open allows multiple scans, but we want 1 successful scan.
          NfcManager.instance.stopSession();
        }
      },
      onError: (e) async {
        _handleError("Scan stopped or failed.");
      },
    );
  }

  /// Parses the raw NFC tag to find a usable ID
  String? _parseTagData(NfcTag tag) {
    // Attempt to get the NDEF payload first (common for standard tags)
    final ndef = Ndef.from(tag);
    if (ndef != null && ndef.cachedMessage != null) {
      for (var record in ndef.cachedMessage!.records) {
        // Assuming the ID is stored as text in the payload
        // In reality, this might be encrypted or a specific payload ID
        try {
          return utf8.decode(record.payload).substring(3); // skip language code
        } catch (e) {
          continue;
        }
      }
    }

    // Fallback: Read the Physical Tag ID (UID)
    // This is often represented as a Map in the data.
    final data = tag.data;
    if (data.containsKey('isodep')) {
      // Example for IsoDep identifier
      List<int> identifier = data['isodep']['identifier'];
      return identifier
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join('')
          .toUpperCase();
    }

    // Just for demo purposes if specific parsing fails, returns a dummy success
    // Remove this in production!
    return "AB12CD";
  }

  /// Validates the scanned ID against authorized users for this room
  void _verifyAccess(String scannedId) {
    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_authorizedFacultyIds.contains(scannedId)) {
        setState(() {
          _isScanning = false;
          _message = "Access Granted\nWelcome, Dr. Smith";
          _statusColor = Colors.green;
          _statusIcon = Icons.check_circle_outline;
        });
      } else {
        _handleError(
            "Access Denied: ID $scannedId not authorized for Room $_currentRoomId");
      }
    });
  }

  void _handleError(String msg) {
    setState(() {
      _isScanning = false;
      _message = msg;
      _statusColor = Colors.redAccent;
      _statusIcon = Icons.block;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Verification"),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            _buildRoomInfoCard(),
            const Spacer(),

            // Status Icon with Animation area
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _statusColor, width: 2),
                ),
                child: Icon(
                  _statusIcon,
                  size: 80,
                  color: _statusColor,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Status Text
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _statusColor,
              ),
            ),

            const Spacer(),

            // Action Button
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _startNfcScan,
              icon: const Icon(Icons.nfc),
              label: Text(_isScanning ? "Scanning..." : "Tap to Verify"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Room Verification",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              _currentRoomId,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Class: CS-401"),
                Text("Time: 10:00 AM"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
