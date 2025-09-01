import 'dart:convert';

class Section {
  final String repairNumber;
  final String sectionName;
  final dynamic sectionData;
  final DateTime createdAt;

  Section({
    required this.repairNumber,
    required this.sectionName,
    required this.sectionData,
    required this.createdAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      repairNumber: json['repair_number'] as String,
      sectionName: json['section_name'] as String,
      sectionData: json['section_data'],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repair_number': repairNumber,
      'section_name': sectionName,
      'section_data': sectionData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Get section number from section name (e.g., "Section 1" -> 1)
  int get sectionNumber {
    final match = RegExp(r'Section (\d+)').firstMatch(sectionName);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  // Parse section data based on section type
  Map<String, dynamic>? get parsedData {
    if (sectionData == null) return null;
    
    try {
      Map<String, dynamic>? result;
      if (sectionData is String) {
        // Clean the JSON string before parsing
        String cleanedData = _cleanJsonString(sectionData as String);
        result = jsonDecode(cleanedData) as Map<String, dynamic>?;
      } else if (sectionData is Map<String, dynamic>) {
        result = Map<String, dynamic>.from(sectionData as Map<String, dynamic>);
      }
      
      // Clean NaN values from the result
      return result != null ? _cleanNaNValues(result) : null;
    } catch (e) {
      print('Error parsing section data: $e');
      // Try to return a basic structure if parsing fails
      return _createFallbackData();
    }
  }
  
  // Clean JSON string by replacing NaN values
  String _cleanJsonString(String jsonString) {
    return jsonString
        .replaceAll(RegExp(r':\s*NaN'), ': null')
        .replaceAll(RegExp(r'"NaN"'), 'null')
        .replaceAll(RegExp(r'\bNaN\b'), 'null');
  }
  
  // Clean NaN values from parsed data
  Map<String, dynamic> _cleanNaNValues(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value == null) {
        cleaned[key] = null;
      } else if (value is double && value.isNaN) {
        cleaned[key] = null;
      } else if (value is String) {
        if (value.toLowerCase().trim() == 'nan' || value.trim().isEmpty) {
          cleaned[key] = null;
        } else {
          cleaned[key] = value;
        }
      } else if (value is Map<String, dynamic>) {
        cleaned[key] = _cleanNaNValues(value);
      } else if (value is List) {
        cleaned[key] = _cleanNaNValuesList(value);
      } else {
        cleaned[key] = value;
      }
    }
    
    return cleaned;
  }
  
  // Clean NaN values from lists
  List<dynamic> _cleanNaNValuesList(List<dynamic> list) {
    return list.map((item) {
      if (item == null) {
        return null;
      } else if (item is double && item.isNaN) {
        return null;
      } else if (item is String && item.toLowerCase().trim() == 'nan') {
        return null;
      } else if (item is Map<String, dynamic>) {
        return _cleanNaNValues(item);
      } else if (item is List) {
        return _cleanNaNValuesList(item);
      }
      return item;
    }).toList();
  }
  
  // Create fallback data structure when parsing fails
  Map<String, dynamic> _createFallbackData() {
    return {
      'error': 'Failed to parse section data',
      'raw_data': sectionData?.toString() ?? 'null',
    };
  }

  // Get section data as list (for Section 2 - files)
  List<dynamic>? get parsedDataAsList {
    if (sectionData == null) return null;
    
    try {
      List<dynamic>? result;
      if (sectionData is String) {
        String cleanedData = _cleanJsonString(sectionData as String);
        final decoded = jsonDecode(cleanedData);
        result = decoded is List ? decoded : null;
      } else if (sectionData is List) {
        result = List<dynamic>.from(sectionData as List<dynamic>);
      }
      
      // Clean NaN values from the list
      return result != null ? _cleanNaNValuesList(result) : null;
    } catch (e) {
      print('Error parsing section data as list: $e');
      return [];
    }
  }

  // Get section data as plain text (for Sections 3, 4, 5)
  String? get parsedDataAsText {
    if (sectionData == null) return null;
    
    if (sectionData is String) {
      // Try to parse as JSON first, if it fails, return as plain text
      try {
        final decoded = jsonDecode(sectionData as String);
        return decoded.toString();
      } catch (e) {
        return sectionData as String;
      }
    }
    return sectionData.toString();
  }

  // Check if section has missing critical data
  bool get hasMissingData {
    switch (sectionNumber) {
      case 1:
        return _checkSection1Missing();
      case 2:
        return _checkSection2Missing();
      case 3:
      case 4:
        return _checkSection3And4Missing();
      case 5:
        return _checkSection5Missing();
      default:
        return false;
    }
  }

  bool _checkSection1Missing() {
    final data = parsedData;
    if (data == null) return true;
    
    final criticalFields = [
      'Miles at Failure',
      'Failure Codes',
      'Troubleshooting Forms',
      'TCM Serial Numbers',
    ];
    
    return criticalFields.any((field) => _isFieldMissing(data[field]));
  }
  
  // Helper method to check if a field is missing or invalid
  bool _isFieldMissing(dynamic value) {
    if (value == null) return true;
    if (value is double && value.isNaN) return true;
    if (value is String) {
      final trimmed = value.trim().toLowerCase();
      return trimmed.isEmpty || trimmed == 'nan' || trimmed == 'null';
    }
    return false;
  }

  bool _checkSection2Missing() {
    final files = parsedDataAsList;
    return files == null || files.isEmpty;
  }

  bool _checkSection3And4Missing() {
    final text = parsedDataAsText;
    return text == null || text.trim().isEmpty;
  }

  bool _checkSection5Missing() {
    final text = parsedDataAsText;
    // Section 5 is complete if it has any content (it's a database summary)
    return text == null || text.trim().isEmpty;
  }

  // Get missing fields for Section 1
  List<String> get missingFields {
    if (sectionNumber != 1) return [];
    
    final data = parsedData;
    if (data == null) return ['All fields missing'];
    
    // Only check fields that actually exist in the data structure
    // Don't add fields that aren't part of the response
    final missingFieldsList = <String>[];
    
    // Check all fields in the actual data for missing values
    for (final entry in data.entries) {
      if (_isFieldMissing(entry.value)) {
        missingFieldsList.add(entry.key);
      }
    }
    
    return missingFieldsList;
  }
}
