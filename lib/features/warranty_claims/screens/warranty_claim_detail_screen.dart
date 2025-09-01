import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../sections/models/repair_claim.dart';
import '../../sections/models/section.dart';
import '../widgets/warranty_claims_filter.dart';

class WarrantyClaimDetailScreen extends StatefulWidget {
  final RepairClaim claim;

  const WarrantyClaimDetailScreen({
    super.key,
    required this.claim,
  });

  @override
  State<WarrantyClaimDetailScreen> createState() => _WarrantyClaimDetailScreenState();
}

class _WarrantyClaimDetailScreenState extends State<WarrantyClaimDetailScreen> {
  List<Section> _filteredSections = [];
  String _statusFilter = 'All';
  Map<int, bool> _expandedSections = {};
  bool _sectionsVisible = true;

  @override
  void initState() {
    super.initState();
    _filteredSections = widget.claim.sections;
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredSections = widget.claim.sections.where((section) {
        // Status filter - updated for new filter options
        return _statusFilter == 'All' || 
            (_statusFilter == 'Completed' && !section.hasMissingData) ||
            (_statusFilter == 'Missing Data' && section.hasMissingData);
      }).toList();
      
      // Sort by section number
      _filteredSections.sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));
    });
  }
  
  void _toggleSectionsVisibility() {
    setState(() {
      _sectionsVisible = !_sectionsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Repair #${widget.claim.repairNumber}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Warranty Claim Details',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Filters Section - Moved to top
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: WarrantyClaimsFilter(
                    onStatusFilter: (status) {
                      _statusFilter = status;
                      _applyFilters();
                    },
                    onSortChanged: (sortBy) {
                      // Not used in simplified filter
                    },
                    onMissingDataFilter: (showMissingOnly) {
                      // Not used in details screen
                    },
                    onSearchFilter: (query) {
                      // Not used in simplified filter
                    },
                    onClearFilters: () {
                      _statusFilter = 'All';
                      _applyFilters();
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Claim Overview Card
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildClaimOverviewCard(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Sections Header with Global Expand/Collapse
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.assignment_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SECTIONS DATA',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grey,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_filteredSections.length}/${widget.claim.sections.length} sections',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Show/Hide Sections Toggle
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _toggleSectionsVisibility,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _sectionsVisible 
                                          ? AppColors.primary.withOpacity(0.1)
                                          : AppColors.lightGrey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _sectionsVisible 
                                            ? AppColors.primary.withOpacity(0.2)
                                            : AppColors.lightGrey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _sectionsVisible 
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: _sectionsVisible 
                                              ? AppColors.primary
                                              : AppColors.grey,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _sectionsVisible ? 'Hide' : 'Show',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: _sectionsVisible 
                                                ? AppColors.primary
                                                : AppColors.grey,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Sections List - Show/Hide based on toggle
                      if (_sectionsVisible) ..._filteredSections.asMap().entries.map((entry) {
                        final index = entry.key;
                        final section = entry.value;
                        return FadeInUp(
                          delay: Duration(milliseconds: 400 + (index * 100)),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: _buildExpandableSectionCard(section),
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClaimOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CLAIM STATUS',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.claim.status,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightGrey.withOpacity(0.3),
                  AppColors.lightGrey,
                  AppColors.lightGrey.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sections Summary
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'SECTIONS OVERVIEW',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.claim.sections.length} sections',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildExpandableSectionCard(Section section) {
    final isExpanded = _expandedSections[section.sectionNumber] ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: section.hasMissingData 
              ? Colors.orange.withOpacity(0.3)
              : AppColors.success.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact Header - Always Visible
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedSections[section.sectionNumber] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Section Number Circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: section.hasMissingData 
                            ? Colors.orange.withOpacity(0.15)
                            : AppColors.success.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${section.sectionNumber}',
                          style: TextStyle(
                            color: section.hasMissingData 
                                ? Colors.orange.shade700
                                : AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Section Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSectionDisplayName(section.sectionNumber),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: section.hasMissingData 
                                      ? Colors.orange.withOpacity(0.1)
                                      : AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  section.hasMissingData ? 'Missing Data' : 'Complete',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: section.hasMissingData 
                                        ? Colors.orange.shade700
                                        : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Expand/Collapse Icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Expandable Content
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.lightGrey.withOpacity(0.2),
                          AppColors.lightGrey,
                          AppColors.lightGrey.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                  _buildSectionData(section),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSectionDisplayName(int sectionNumber) {
    switch (sectionNumber) {
      case 1:
        return 'Warranty Claim Summary';
      case 2:
        return 'Attachments Overview';
      case 3:
        return 'Technician Narrative';
      case 4:
        return 'Service Report Narrative';
      case 5:
        return 'Claim Submission Recommendation';
      default:
        return 'Section $sectionNumber';
    }
  }


  Widget _buildSectionData(Section section) {
    // When Missing Data filter is selected, show only missing fields
    if (_statusFilter == 'Missing Data' && section.hasMissingData) {
      return _buildMissingFieldsOnlyData(section);
    }
    
    // Handle different section types with appropriate formatting
    switch (section.sectionNumber) {
      case 1:
        return _buildSection1Data(section);
      case 2:
        return _buildSection2Data(section);
      case 3:
        return _buildSection3Data(section);
      case 4:
        return _buildSection4Data(section);
      case 5:
        return _buildSection5Data(section);
      default:
        return _buildGenericSectionData(section);
    }
  }

  // Section 1: Vehicle and diagnostic data - Reorganized into categorized portions
  Widget _buildSection1Data(Section section) {
    final data = section.parsedData;
    if (data == null || data.isEmpty) {
      return _buildNoDataWidget();
    }

    // Categorize data into related portions
    final vehicleData = <String, dynamic>{};
    final diagnosticData = <String, dynamic>{};
    final warrantyData = <String, dynamic>{};
    final customerData = <String, dynamic>{};
    
    // Categorize each field
    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('make') || key.contains('model') || key.contains('vin') || 
          key.contains('year') || key.contains('engine') || key.contains('trim')) {
        vehicleData[entry.key] = entry.value;
      } else if (key.contains('dtc') || key.contains('diagnostic') || key.contains('code') ||
                 key.contains('mileage') || key.contains('odometer')) {
        diagnosticData[entry.key] = entry.value;
      } else if (key.contains('coverage') || key.contains('warranty') || key.contains('service') ||
                 key.contains('date') || key.contains('vocation')) {
        warrantyData[entry.key] = entry.value;
      } else if (key.contains('complaint') || key.contains('customer') || key.contains('concern')) {
        customerData[entry.key] = entry.value;
      } else {
        // Default to vehicle data for uncategorized fields
        vehicleData[entry.key] = entry.value;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vehicle Information Portion
        if (vehicleData.isNotEmpty) ...[
          _buildDataPortion(
            'Vehicle Information',
            vehicleData,
            section.missingFields,
            Icons.directions_car,
            AppColors.primary,
          ),
          const SizedBox(height: 16),
        ],
        
        // Diagnostic Data Portion
        if (diagnosticData.isNotEmpty) ...[
          _buildDataPortion(
            'Diagnostic Data',
            diagnosticData,
            section.missingFields,
            Icons.build_outlined,
            Colors.blue,
          ),
          const SizedBox(height: 16),
        ],
        
        // Warranty Information Portion
        if (warrantyData.isNotEmpty) ...[
          _buildDataPortion(
            'Warranty Information',
            warrantyData,
            section.missingFields,
            Icons.verified_outlined,
            Colors.green,
          ),
          const SizedBox(height: 16),
        ],
        
        // Customer Data Portion
        if (customerData.isNotEmpty) ...[
          _buildDataPortion(
            'Customer Information',
            customerData,
            section.missingFields,
            Icons.person_outlined,
            Colors.orange,
          ),
        ],
      ],
    );
  }
  
  // Helper method to build categorized data portions
  Widget _buildDataPortion(
    String title,
    Map<String, dynamic> data,
    List<String> missingFields,
    IconData icon,
    Color color,
  ) {
    final availableCount = data.entries.where((entry) => 
        entry.value != null && entry.value.toString().trim().isNotEmpty).length;
    final totalCount = data.entries.length;
    final missingCount = data.entries.where((entry) => 
        missingFields.contains(entry.key)).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: missingCount > 0 
              ? Colors.orange.withOpacity(0.3)
              : color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portion Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$availableCount/$totalCount available',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (missingCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$missingCount missing',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Data fields for this portion
          Column(
            children: data.entries.map((entry) {
              final isHighlighted = missingFields.contains(entry.key);
              return _buildDataField(entry.key, entry.value, isHighlighted);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Section 2: Files and attachments
  Widget _buildSection2Data(Section section) {
    final files = section.parsedDataAsList;
    if (files == null || files.isEmpty) {
      return _buildNoDataWidget('No files or attachments available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.attach_file, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATTACHMENTS OVERVIEW',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${files.length} files attached to this claim',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: files.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return _buildFileCard(file, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Section 3: Technical analysis
  Widget _buildSection3Data(Section section) {
    final text = section.parsedDataAsText;
    if (text == null || text.trim().isEmpty) {
      return _buildNoDataWidget('No technical analysis available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.analytics, color: Colors.blue.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TECHNICAL ANALYSIS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detailed technical evaluation and diagnostics',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics_outlined, color: Colors.blue.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'ANALYSIS REPORT',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFormattedText(text),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section 4: Markdown formatted data
  Widget _buildSection4Data(Section section) {
    final text = section.parsedDataAsText;
    if (text == null || text.trim().isEmpty) {
      return _buildNoDataWidget('No documentation available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description_outlined, color: Colors.purple.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOCUMENTATION & REPORTS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Formatted documentation with markdown support',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.article_outlined, color: Colors.purple.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'DETAILED REPORT',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMarkdownContent(text),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section 5: Summary and conclusions - No missing data highlighting
  Widget _buildSection5Data(Section section) {
    final text = section.parsedDataAsText;
    if (text == null || text.trim().isEmpty) {
      return _buildNoDataWidget('No summary available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.summarize_outlined, color: Colors.teal.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUMMARY & CONCLUSIONS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Final assessment and recommendations - Database Summary',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fact_check_outlined, color: Colors.teal.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'FINAL SUMMARY',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryContent(text),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Generic section data display
  Widget _buildGenericSectionData(Section section) {
    final data = section.parsedData;
    if (data == null || data.isEmpty) {
      return _buildNoDataWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPLETION PROGRESS',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.claim.sections.length} sections total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
          ),
        ),
        Text(
          'Section Data',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: data.entries.map((entry) {
              final isHighlighted = section.missingFields.contains(entry.key);
              return _buildDataField(entry.key, entry.value, isHighlighted, section.sectionNumber);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // New method to show only missing fields when Missing Data filter is active
  Widget _buildMissingFieldsOnlyData(Section section) {
    if (section.missingFields.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              'All fields are complete',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Missing Fields (${section.missingFields.length})',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...section.missingFields.map((field) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    field,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }


  Color _getStatusColor() {
    switch (widget.claim.status) {
      case 'Complete':
        return AppColors.success;
      case 'Missing Data':
        return Colors.orange;
      case 'Incomplete':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.claim.status) {
      case 'Complete':
        return Icons.check_circle_outline;
      case 'Missing Data':
        return Icons.warning_outlined;
      case 'Incomplete':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }


  // Helper method to build individual data fields with section-aware highlighting
  Widget _buildDataField(String key, dynamic value, bool isHighlighted, [int? sectionNumber]) {
    final hasValue = value != null && value.toString().trim().isNotEmpty;
    // Don't highlight missing data in Section 5 (summary)
    final shouldHighlight = isHighlighted && (sectionNumber == null || sectionNumber != 5);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: shouldHighlight 
            ? Colors.orange.withOpacity(0.06)
            : hasValue 
                ? AppColors.success.withOpacity(0.05)
                : AppColors.lightGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: shouldHighlight 
              ? Colors.orange.withOpacity(0.25)
              : hasValue 
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.lightGrey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: shouldHighlight 
                  ? Colors.orange.withOpacity(0.15)
                  : hasValue 
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.lightGrey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              shouldHighlight 
                  ? Icons.warning_rounded
                  : hasValue 
                      ? Icons.check_rounded
                      : Icons.remove_rounded,
              color: shouldHighlight 
                  ? Colors.orange.shade600
                  : hasValue 
                      ? AppColors.success
                      : AppColors.grey,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatFieldName(key),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: shouldHighlight 
                              ? Colors.orange.shade700 
                              : AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (shouldHighlight)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'REQUIRED',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: shouldHighlight 
                          ? Colors.orange.withOpacity(0.2)
                          : AppColors.lightGrey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hasValue 
                        ? value.toString()
                        : 'Data not provided',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: hasValue 
                          ? AppColors.darkGrey
                          : shouldHighlight 
                              ? Colors.orange.shade600
                              : AppColors.grey,
                      fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format field names for better readability
  String _formatFieldName(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }

  // Helper method to build no data widget
  Widget _buildNoDataWidget([String? message]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? 'No data available for this section',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get file icon based on file type
  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.attach_file;
    }
  }

  // Helper method to build markdown content with basic formatting
  Widget _buildMarkdownContent(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      
      // Handle headers
      if (line.startsWith('# ')) {
        widgets.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.2)),
          ),
          child: Text(
            line.substring(2),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
              letterSpacing: -0.3,
            ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            line.substring(3),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade600,
            ),
          ),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        // Handle bullet points
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkGrey,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ));
      } else {
        // Regular text
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            line,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.darkGrey,
              height: 1.5,
            ),
          ),
        ));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // Helper method to build summary content with structured formatting
  Widget _buildSummaryContent(String text) {
    // Try to extract key information from the summary
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    if (lines.isEmpty) {
      return Text(
        'No summary content available',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Check if line contains key indicators
        if (line.toLowerCase().contains('sections completed') ||
            line.toLowerCase().contains('approval probability') ||
            line.toLowerCase().contains('critical') ||
            line.toLowerCase().contains('missing sections')) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: line.toLowerCase().contains('critical') || line.toLowerCase().contains('missing')
                  ? Colors.red.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: line.toLowerCase().contains('critical') || line.toLowerCase().contains('missing')
                    ? Colors.red.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  line.toLowerCase().contains('critical') || line.toLowerCase().contains('missing')
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: line.toLowerCase().contains('critical') || line.toLowerCase().contains('missing')
                      ? Colors.red
                      : AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: line.toLowerCase().contains('critical') || line.toLowerCase().contains('missing')
                          ? Colors.red.shade700
                          : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkGrey,
                height: 1.5,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  // Helper method to build formatted text with bold headings
  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      
      // Check if line looks like a heading (starts with capital letters, ends with colon, etc.)
      if (_isHeading(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            line,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
              letterSpacing: -0.2,
            ),
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            line,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.darkGrey,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // Helper method to determine if a line is a heading
  bool _isHeading(String line) {
    // Check various heading patterns
    return line.endsWith(':') ||
           line.contains('Analysis') ||
           line.contains('Summary') ||
           line.contains('Conclusion') ||
           line.contains('Results') ||
           line.contains('Findings') ||
           line.contains('Recommendation') ||
           line.contains('Issue') ||
           line.contains('Problem') ||
           line.contains('Solution') ||
           (line.length < 50 && line.split(' ').length <= 5 && line == line.toUpperCase()) ||
           RegExp(r'^[A-Z][a-zA-Z\s]+:?$').hasMatch(line);
  }

  // Helper method to build file card with proper file type detection
  Widget _buildFileCard(dynamic file, int index) {
    final fileInfo = _parseFileInfo(file);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getFileTypeColor(fileInfo['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getFileTypeColor(fileInfo['type']).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              _getFileIcon(fileInfo['name']),
              color: _getFileTypeColor(fileInfo['type']),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getFileTypeColor(fileInfo['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        fileInfo['type'].toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getFileTypeColor(fileInfo['type']),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ATTACHMENT ${index + 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  fileInfo['name'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileInfo['url'] != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openPdfFile(fileInfo['url']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Open PDF',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse file information
  Map<String, dynamic> _parseFileInfo(dynamic file) {
    // Handle JSON object with filename and url
    if (file is Map<String, dynamic>) {
      final fileName = file['filename'] ?? file['name'] ?? 'Unknown File';
      final url = file['url'];
      
      // Determine file type from filename
      String fileType = 'FILE';
      if (fileName.toLowerCase().contains('.pdf')) {
        fileType = 'PDF';
      } else if (fileName.toLowerCase().contains('.doc') || fileName.toLowerCase().contains('.docx')) {
        fileType = 'DOC';
      } else if (fileName.toLowerCase().contains('.xls') || fileName.toLowerCase().contains('.xlsx')) {
        fileType = 'XLS';
      } else if (fileName.toLowerCase().contains('.jpg') || fileName.toLowerCase().contains('.jpeg') || fileName.toLowerCase().contains('.png')) {
        fileType = 'IMG';
      } else if (fileName.toLowerCase().contains('.mp4') || fileName.toLowerCase().contains('.avi')) {
        fileType = 'VID';
      }
      
      return {
        'name': fileName,
        'type': fileType,
        'url': url,
      };
    }
    
    // Fallback for string format
    String fileString = file.toString();
    String? url;
    String fileName = fileString;
    
    if (fileString.startsWith('http') || fileString.contains('://')) {
      url = fileString;
      // Extract filename from URL
      try {
        final uri = Uri.parse(fileString);
        fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'Unknown File';
      } catch (e) {
        fileName = 'Link';
      }
    }
    
    // Determine file type
    String fileType = 'FILE';
    if (fileName.toLowerCase().contains('.pdf')) {
      fileType = 'PDF';
    } else if (fileName.toLowerCase().contains('.doc') || fileName.toLowerCase().contains('.docx')) {
      fileType = 'DOC';
    } else if (fileName.toLowerCase().contains('.xls') || fileName.toLowerCase().contains('.xlsx')) {
      fileType = 'XLS';
    } else if (fileName.toLowerCase().contains('.jpg') || fileName.toLowerCase().contains('.jpeg') || fileName.toLowerCase().contains('.png')) {
      fileType = 'IMG';
    } else if (fileName.toLowerCase().contains('.mp4') || fileName.toLowerCase().contains('.avi')) {
      fileType = 'VID';
    } else if (url != null) {
      fileType = 'LINK';
    }
    
    return {
      'name': fileName,
      'type': fileType,
      'url': url,
    };
  }

  // Helper method to open PDF file
  Future<void> _openPdfFile(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Try different launch modes for better compatibility
      bool launched = false;
      
      // First try with platformDefault mode
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        print('Platform default launch failed: $e');
      }
      
      // If that fails, try with external browser
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          print('External application launch failed: $e');
        }
      }
      
      // If still fails, try with in-app web view
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        } catch (e) {
          print('In-app web view launch failed: $e');
        }
      }
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No app available to open PDF files. Please install a PDF viewer.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Error parsing URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid PDF URL format'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Helper method to get file type color
  Color _getFileTypeColor(String fileType) {
    switch (fileType) {
      case 'PDF':
        return Colors.red;
      case 'DOC':
        return Colors.blue;
      case 'XLS':
        return Colors.green;
      case 'IMG':
        return Colors.purple;
      case 'VID':
        return Colors.orange;
      case 'LINK':
        return Colors.cyan;
      default:
        return AppColors.success;
    }
  }
}
