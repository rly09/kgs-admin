import '../../core/supabase_config.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService {
  final _supabase = SupabaseConfig.client;
  
  /// Get discount percentage
  Future<double> getDiscount() async {
    try {
      final response = await _supabase
          .from('settings')
          .select('value')
          .eq('key', 'discount_percentage')
          .maybeSingle();
      
      if (response == null) {
        return 0.0;
      }
      
      return double.tryParse(response['value'] as String) ?? 0.0;
    } catch (e) {
      throw Exception('Failed to fetch discount: ${e.toString()}');
    }
  }
  
  /// Update discount percentage
  Future<double> updateDiscount(double percentage) async {
    try {
      // Check if setting exists
      final existing = await _supabase
          .from('settings')
          .select()
          .eq('key', 'discount_percentage')
          .maybeSingle();
      
      if (existing == null) {
        // Insert new
        await _supabase
            .from('settings')
            .insert({
              'key': 'discount_percentage',
              'value': percentage.toString(),
            });
      } else {
        // Update existing
        await _supabase
            .from('settings')
            .update({'value': percentage.toString()})
            .eq('key', 'discount_percentage');
      }
      
      return percentage;
    } catch (e) {
      throw Exception('Failed to update discount: ${e.toString()}');
    }
  }

  /// Get payment QR URL
  Future<String?> getPaymentQrUrl() async {
    try {
      final response = await _supabase
          .from('settings')
          .select('value')
          .eq('key', 'payment_qr_url')
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return response['value'] as String?;
    } catch (e) {
      throw Exception('Failed to fetch payment QR URL: ${e.toString()}');
    }
  }

  /// Update payment QR URL
  Future<void> updatePaymentQrUrl(String url) async {
    try {
      // Check if setting exists
      final existing = await _supabase
          .from('settings')
          .select()
          .eq('key', 'payment_qr_url')
          .maybeSingle();
      
      if (existing == null) {
        // Insert new
        await _supabase
            .from('settings')
            .insert({
              'key': 'payment_qr_url',
              'value': url,
            });
      } else {
        // Update existing
        await _supabase
            .from('settings')
            .update({'value': url})
            .eq('key', 'payment_qr_url');
      }
    } catch (e) {
      throw Exception('Failed to update payment QR URL: ${e.toString()}');
    }
  }

  /// Upload payment QR image to Supabase Storage and return URL
  Future<String> uploadPaymentQr(File imageFile) async {
    try {
      final fileName = 'payment_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage
      await _supabase.storage
          .from('payment-qr')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );

      // Get public URL
      final url = _supabase.storage
          .from('payment-qr')
          .getPublicUrl(fileName);

      // Save URL to settings
      await updatePaymentQrUrl(url);

      return url;
    } catch (e) {
      throw Exception('Failed to upload payment QR: ${e.toString()}');
    }
  }
}

