import '../../../core/services/supabase_service.dart';
import '../models/section.dart';
import '../models/repair_claim.dart';

class SectionsService {
  static const String _sectionsTable = 'sections';
  
  /// Fetch all sections
  static Future<List<Section>> getAllSections() async {
    try {
      final response = await SupabaseService.client
          .from(_sectionsTable)
          .select()
          .order('repair_number', ascending: false)
          .order('section_name', ascending: true);
      
      final sectionsData = response as List<dynamic>;
      
      return sectionsData
          .map((data) => Section.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching sections: $e');
      return [];
    }
  }
  
  /// Fetch sections by repair number
  static Future<List<Section>> getSectionsByRepairNumber(String repairNumber) async {
    try {
      final response = await SupabaseService.client
          .from(_sectionsTable)
          .select()
          .eq('repair_number', repairNumber)
          .order('section_name', ascending: true);
      
      final sectionsData = response as List<dynamic>;
      
      return sectionsData
          .map((data) => Section.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching sections for repair $repairNumber: $e');
      return [];
    }
  }
  
  /// Fetch all repair claims (grouped sections)
  static Future<List<RepairClaim>> getAllRepairClaims() async {
    try {
      final sections = await getAllSections();
      
      // Group sections by repair number
      final Map<String, List<Section>> groupedSections = {};
      for (final section in sections) {
        if (!groupedSections.containsKey(section.repairNumber)) {
          groupedSections[section.repairNumber] = [];
        }
        groupedSections[section.repairNumber]!.add(section);
      }
      
      // Convert to RepairClaim objects
      final repairClaims = groupedSections.entries
          .map((entry) => RepairClaim.fromSections(entry.value))
          .toList();
      
      // Sort by creation date (newest first)
      repairClaims.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return repairClaims;
    } catch (e) {
      print('Error fetching repair claims: $e');
      return [];
    }
  }
  
  /// Fetch repair claims with missing data
  static Future<List<RepairClaim>> getRepairClaimsWithMissingData() async {
    try {
      final allClaims = await getAllRepairClaims();
      return allClaims.where((claim) => claim.hasMissingData).toList();
    } catch (e) {
      print('Error fetching claims with missing data: $e');
      return [];
    }
  }
  
  /// Fetch incomplete repair claims (less than 5 sections)
  static Future<List<RepairClaim>> getIncompleteRepairClaims() async {
    try {
      final allClaims = await getAllRepairClaims();
      return allClaims.where((claim) => !claim.isComplete).toList();
    } catch (e) {
      print('Error fetching incomplete claims: $e');
      return [];
    }
  }
  
  /// Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final allClaims = await getAllRepairClaims();
      
      final totalClaims = allClaims.length;
      final completeClaims = allClaims.where((c) => c.status == 'Complete').length;
      final missingDataClaims = allClaims.where((c) => c.status == 'Missing Data').length;
      final incompleteClaims = allClaims.where((c) => c.status == 'Incomplete').length;
      
      final completionRate = totalClaims > 0 ? (completeClaims / totalClaims) * 100 : 0.0;
      
      return {
        'total_claims': totalClaims,
        'complete_claims': completeClaims,
        'missing_data_claims': missingDataClaims,
        'incomplete_claims': incompleteClaims,
        'completion_rate': completionRate,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'total_claims': 0,
        'complete_claims': 0,
        'missing_data_claims': 0,
        'incomplete_claims': 0,
        'completion_rate': 0.0,
      };
    }
  }
  
  /// Search repair claims by various criteria
  static Future<List<RepairClaim>> searchRepairClaims({
    String? repairNumber,
    String? vehicleInfo,
    String? complaint,
    String? status,
  }) async {
    try {
      final allClaims = await getAllRepairClaims();
      
      return allClaims.where((claim) {
        bool matches = true;
        
        if (repairNumber != null && repairNumber.isNotEmpty) {
          matches = matches && claim.repairNumber.toLowerCase().contains(repairNumber.toLowerCase());
        }
        
        if (vehicleInfo != null && vehicleInfo.isNotEmpty) {
          matches = matches && claim.vehicleInfo.toLowerCase().contains(vehicleInfo.toLowerCase());
        }
        
        if (complaint != null && complaint.isNotEmpty) {
          matches = matches && claim.complaint.toLowerCase().contains(complaint.toLowerCase());
        }
        
        if (status != null && status.isNotEmpty) {
          matches = matches && claim.status.toLowerCase() == status.toLowerCase();
        }
        
        return matches;
      }).toList();
    } catch (e) {
      print('Error searching repair claims: $e');
      return [];
    }
  }
  
  /// Get unique repair numbers
  static Future<List<String>> getUniqueRepairNumbers() async {
    try {
      final response = await SupabaseService.client
          .from(_sectionsTable)
          .select('repair_number')
          .order('repair_number', ascending: false);
      
      final data = response as List<dynamic>;
      final repairNumbers = data
          .map((item) => item['repair_number'] as String)
          .toSet()
          .toList();
      
      return repairNumbers;
    } catch (e) {
      print('Error fetching unique repair numbers: $e');
      return [];
    }
  }
}
