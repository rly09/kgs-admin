import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../providers.dart';

class PaymentQrScreen extends ConsumerStatefulWidget {
  const PaymentQrScreen({super.key});

  @override
  ConsumerState<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends ConsumerState<PaymentQrScreen> {
  bool _isUploading = false;
  String? _currentQrUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentQr();
  }

  Future<void> _loadCurrentQr() async {
    try {
      final settingsService = ref.read(settingsServiceProvider);
      final url = await settingsService.getPaymentQrUrl();
      if (mounted) {
        setState(() {
          _currentQrUrl = url;
        });
      }
    } catch (e) {
      // QR not set yet, that's okay
    }
  }

  Future<void> _pickAndUploadQr() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final settingsService = ref.read(settingsServiceProvider);
      final file = File(image.path);
      final url = await settingsService.uploadPaymentQr(file);

      setState(() {
        _currentQrUrl = url;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment QR code updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading QR code: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Online Payment QR'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: ResponsiveHelper.constrainedContent(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.padding),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upload your payment QR code. Customers will see this when they select online payment.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // Current QR Display
              Text('Current QR Code', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.space),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: _currentQrUrl != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            child: Image.network(
                              _currentQrUrl!,
                              height: 300,
                              width: 300,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 300,
                                  width: 300,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 300,
                                  width: 300,
                                  color: AppColors.surfaceLight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load QR code',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'QR code is active',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(Icons.qr_code_2_outlined, size: 80, color: AppColors.textTertiary),
                          const SizedBox(height: AppDimensions.space),
                          Text(
                            'No QR code uploaded yet',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload a QR code to enable online payments',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickAndUploadQr,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(_currentQrUrl != null ? Icons.edit : Icons.upload_file),
                  label: Text(_isUploading
                      ? 'Uploading...'
                      : _currentQrUrl != null
                          ? 'Change QR Code'
                          : 'Upload QR Code'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space),

              // Instructions
              Container(
                padding: const EdgeInsets.all(AppDimensions.padding),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Use a clear, high-quality QR code image'),
                    _buildTip('Ensure the QR code is scannable'),
                    _buildTip('Include payment details (UPI ID, account info) in the QR'),
                    _buildTip('Test the QR code before uploading'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
