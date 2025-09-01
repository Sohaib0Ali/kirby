import 'section.dart';

class RepairClaim {
  final String repairNumber;
  final List<Section> sections;
  final DateTime createdAt;

  RepairClaim({
    required this.repairNumber,
    required this.sections,
    required this.createdAt,
  });

  // Get section by number
  Section? getSection(int sectionNumber) {
    try {
      return sections.firstWhere((s) => s.sectionNumber == sectionNumber);
    } catch (e) {
      return null;
    }
  }

  // Check if repair claim is complete (has all 5 sections)
  bool get isComplete => sections.length == 5;

  // Get completion percentage
  double get completionPercentage => (sections.length / 5.0) * 100;

  // Check if any section has missing data
  bool get hasMissingData => sections.any((section) => section.hasMissingData);

  // Get count of sections with missing data
  int get missingSectionsCount => sections.where((s) => s.hasMissingData).length;

  // Get list of missing section numbers
  List<int> get missingSectionNumbers => 
      sections.where((s) => s.hasMissingData).map((s) => s.sectionNumber).toList();

  // Get all missing sections
  List<Section> get missingSections => 
      sections.where((s) => s.hasMissingData).toList();

  // Get status based on completion and missing data
  String get status {
    if (!isComplete) return 'Incomplete';
    if (hasMissingData) return 'Missing Data';
    return 'Complete';
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case 'Complete':
        return 'success';
      case 'Missing Data':
        return 'warning';
      case 'Incomplete':
        return 'error';
      default:
        return 'info';
    }
  }

  // Get basic info from Section 1
  Map<String, dynamic>? get basicInfo {
    final section1 = getSection(1);
    return section1?.parsedData;
  }

  // Get vehicle info
  String get vehicleInfo {
    final info = basicInfo;
    if (info == null) return 'Unknown Vehicle';
    
    final make = info['Make']?.toString() ?? '';
    final model = info['Model']?.toString() ?? '';
    final vin = info['VIN']?.toString() ?? '';
    
    if (make.isNotEmpty && model.isNotEmpty) {
      return '$make $model${vin.isNotEmpty ? ' (VIN: $vin)' : ''}';
    } else if (model.isNotEmpty) {
      return model;
    } else if (vin.isNotEmpty) {
      return 'VIN: $vin';
    }
    return 'Unknown Vehicle';
  }

  // Get complaint
  String get complaint {
    final info = basicInfo;
    return info?['Complaint']?.toString() ?? 'No complaint specified';
  }

  // Get coverage
  String get coverage {
    final info = basicInfo;
    final coverageValue = info?['Coverage'];
    if (coverageValue == null) return 'Unknown';
    return coverageValue.toString();
  }

  // Get in-service date
  DateTime? get inServiceDate {
    final info = basicInfo;
    final dateStr = info?['In-Service Date']?.toString();
    if (dateStr == null || dateStr.isEmpty) return null;
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Get files from Section 2
  List<Map<String, dynamic>> get attachedFiles {
    final section2 = getSection(2);
    final files = section2?.parsedDataAsList;
    if (files == null) return [];
    
    return files.map((file) {
      if (file is Map<String, dynamic>) {
        return file;
      }
      return <String, dynamic>{};
    }).toList();
  }

  // Get file count
  int get fileCount => attachedFiles.length;

  // Factory method to create from sections list
  factory RepairClaim.fromSections(List<Section> sections) {
    if (sections.isEmpty) {
      throw ArgumentError('Sections list cannot be empty');
    }
    
    final repairNumber = sections.first.repairNumber;
    final createdAt = sections.map((s) => s.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    
    // Sort sections by section number
    sections.sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));
    
    return RepairClaim(
      repairNumber: repairNumber,
      sections: sections,
      createdAt: createdAt,
    );
  }
}
