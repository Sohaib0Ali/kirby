import '../../../core/services/supabase_service.dart';
import '../models/warranty_claim.dart';
import '../models/dashboard_stats.dart';

class DashboardService {
  static const String _claimsTable = 'warranty_claims';
  
  /// Fetch dashboard statistics
  static Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await SupabaseService.client
          .from(_claimsTable)
          .select('claim_status');
      
      final claims = response as List<dynamic>;
      
      int totalClaims = claims.length;
      int pendingClaims = claims.where((c) => c['claim_status'] == 'pending').length;
      int approvedClaims = claims.where((c) => c['claim_status'] == 'approved').length;
      int rejectedClaims = claims.where((c) => c['claim_status'] == 'rejected').length;
      
      double approvalRate = totalClaims > 0 ? (approvedClaims / totalClaims) * 100 : 0.0;
      
      return DashboardStats(
        totalClaims: totalClaims,
        pendingClaims: pendingClaims,
        approvedClaims: approvedClaims,
        rejectedClaims: rejectedClaims,
        approvalRate: approvalRate,
      );
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return DashboardStats.empty();
    }
  }
  
  /// Fetch recent warranty claims
  static Future<List<WarrantyClaim>> getRecentClaims({int limit = 10}) async {
    try {
      final response = await SupabaseService.client
          .from(_claimsTable)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      
      final claimsData = response as List<dynamic>;
      
      return claimsData
          .map((data) => WarrantyClaim.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching recent claims: $e');
      return [];
    }
  }
  
  /// Fetch claims by status
  static Future<List<WarrantyClaim>> getClaimsByStatus(String status) async {
    try {
      final response = await SupabaseService.client
          .from(_claimsTable)
          .select()
          .eq('claim_status', status)
          .order('created_at', ascending: false);
      
      final claimsData = response as List<dynamic>;
      
      return claimsData
          .map((data) => WarrantyClaim.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching claims by status: $e');
      return [];
    }
  }
  
  /// Create a new warranty claim
  static Future<bool> createClaim(WarrantyClaim claim) async {
    try {
      await SupabaseService.client
          .from(_claimsTable)
          .insert(claim.toJson());
      
      return true;
    } catch (e) {
      print('Error creating claim: $e');
      return false;
    }
  }
  
  /// Update claim status
  static Future<bool> updateClaimStatus(String claimId, String newStatus) async {
    try {
      await SupabaseService.client
          .from(_claimsTable)
          .update({
            'claim_status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', claimId);
      
      return true;
    } catch (e) {
      print('Error updating claim status: $e');
      return false;
    }
  }
}
