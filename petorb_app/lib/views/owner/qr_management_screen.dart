import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';

class QrManagementScreen extends StatefulWidget {
  const QrManagementScreen({super.key});

  @override
  State<QrManagementScreen> createState() => _QrManagementScreenState();
}

class _QrManagementScreenState extends State<QrManagementScreen> {
  List<dynamic> _qrCodes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQrCodes();
  }

  Future<void> _fetchQrCodes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ApiService.get('/qr');
      if (res.statusCode == 200) {
        setState(() {
          _qrCodes = jsonDecode(res.body);
        });
      }
    } catch (e) {
      print("Fetch QR codes error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _revokeAccess(String qrId, String sitterName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Revoke Access?'),
        content: Text('Are you sure you want to revoke pet access for $sitterName? They will not be able to scan or view your pet\'s care schedule anymore.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Revoke', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final res = await ApiService.post('/qr/$qrId/revoke', {});
        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access revoked successfully.'), backgroundColor: AppColors.success),
          );
          _fetchQrCodes();
        } else {
          final err = jsonDecode(res.body);
          throw Exception(err['message'] ?? 'Failed to revoke QR key.');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _showExpandedQR(String token, String petName, String sitterName) {
    showDialog(
      context: context,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.cardsBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Access Key: $petName',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryText),
              ),
              const SizedBox(height: 6),
              Text(
                'For Sitter: $sitterName',
                style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgLavenderWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightLavender),
                ),
                child: QrImageView(
                  data: token,
                  version: QrVersions.auto,
                  size: 240.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primaryBrand,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: AppColors.secondaryBrand,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(c).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _fetchQrCodes,
          color: AppColors.primaryBrand,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBrand))
              : _qrCodes.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              const Text('🔑', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              const Text('No Active Sitter Keys', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              const Text('Hired sitter access keys will appear here.', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _qrCodes.length,
                      itemBuilder: (context, index) {
                        final qr = _qrCodes[index];
                        final petName = qr['petId'] != null ? qr['petId']['name'] : 'Pet';
                        final sitterName = qr['sitter'] != null ? qr['sitter']['name'] : 'Sitter';
                        final token = qr['token'] ?? '';
                        final expiry = qr['expiryDate'] != null 
                            ? DateTime.parse(qr['expiryDate']).toString().split(' ')[0] 
                            : 'Never';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppStyles.cardsBorderRadius,
                            side: BorderSide(color: AppColors.lightLavender.withOpacity(0.5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Thumbnail QR code
                                GestureDetector(
                                  onTap: () => _showExpandedQR(token, petName, sitterName),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgLavenderWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.lightLavender),
                                    ),
                                    child: QrImageView(
                                      data: token,
                                      version: QrVersions.auto,
                                      size: 60.0,
                                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primaryBrand),
                                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: AppColors.secondaryBrand),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Text details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Key for $petName',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryText),
                                      ),
                                      const SizedBox(height: 2),
                                      Text('Granted: $sitterName', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                                      Text('Expires: $expiry', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                
                                // Revoke button
                                IconButton(
                                  icon: const Icon(Icons.no_accounts_outlined, color: AppColors.danger),
                                  tooltip: 'Revoke Key',
                                  onPressed: () => _revokeAccess(qr['_id'], sitterName),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
