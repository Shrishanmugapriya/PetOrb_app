import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import 'assigned_pets_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final _manualTokenController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualTokenController.dispose();
    super.dispose();
  }

  Future<void> _verifyToken(String token) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final res = await ApiService.post('/qr/verify', {'token': token});
      
      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final pet = PetModel.fromJson(data['pet']);
        final ownerName = data['owner'] != null ? data['owner']['name'] : 'Owner';
        
        // Refresh sitter pets provider list
        await Provider.of<PetProvider>(context, listen: false).fetchPets();

        if (!mounted) return;

        // Show Success Alert Dialogue
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppStyles.cardsBorderRadius),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                SizedBox(width: 8),
                Text('Access Granted!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Security token verified successfully.\nYou now have care access sheets unlocked for ${pet.name}.\n\nPrimary Contact:\n$ownerName',
              style: const TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(c).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => AssignedPetDetailsScreen(pet: pet)),
                  );
                },
                child: const Text('View Pet Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBrand)),
              )
            ],
          ),
        );
      } else {
        final err = jsonDecode(res.body);
        _showFailureAlert(err['message'] ?? 'Invalid security token.');
      }
    } catch (e) {
      _showFailureAlert("Network connection failed. Ensure server is online.");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showFailureAlert(String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.cardsBorderRadius),
        title: const Row(
          children: [
            Icon(Icons.error, color: AppColors.danger, size: 28),
            SizedBox(width: 8),
            Text('Verification Failed', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(height: 1.3)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showManualEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(c).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Simulator Key Verification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText),
            ),
            const SizedBox(height: 4),
            const Text(
              'Paste the secure token hex from the owner\'s dashboard key to verify on simulator/desktop.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _manualTokenController,
              decoration: InputDecoration(
                hintText: 'Enter Hex Security Key',
                filled: true,
                fillColor: AppColors.bgLavenderWhite,
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final token = _manualTokenController.text.trim();
                Navigator.of(c).pop();
                if (token.isNotEmpty) _verifyToken(token);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Verify Access Key', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Access QR', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryText)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_outlined, color: AppColors.primaryBrand),
            tooltip: 'Enter Manually (Simulator Mode)',
            onPressed: _showManualEntry,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mobile Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _scannerController.stop();
                  _verifyToken(rawValue);
                  break;
                }
              }
            },
          ),

          // Custom Scanner Overlays
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBrand, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white, width: 3), left: BorderSide(color: Colors.white, width: 3)))),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white, width: 3), right: BorderSide(color: Colors.white, width: 3)))),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 3), left: BorderSide(color: Colors.white, width: 3)))),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 3), right: BorderSide(color: Colors.white, width: 3)))),
                  ),
                ],
              ),
            ),
          ),

          // Instructions Label
          const Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Text(
              'Align owner\'s security QR code inside the box to verify sitting access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))],
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryBrand),
                    SizedBox(height: 16),
                    Text('Verifying permissions...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
