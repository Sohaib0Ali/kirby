import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
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
  String _sortBy = 'section_number';
  bool _showMissingDataOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredSections = widget.claim.sections;
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredSections = widget.claim.sections.where((section) {
        // Status filter
        bool statusMatch = _statusFilter == 'All' || 
            (_statusFilter == 'Complete' && !section.hasMissingData) ||
            (_statusFilter == 'Missing Data' && section.hasMissingData) ||
            (_statusFilter == 'Incomplete' && section.hasMissingData);
        
        // Missing data filter
        bool missingDataMatch = !_showMissingDataOnly || section.hasMissingData;
        
        // Search filter
        bool searchMatch = _searchQuery.isEmpty ||
            section.sectionName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            section.sectionNumber.toString().contains(_searchQuery);
        
        return statusMatch && missingDataMatch && searchMatch;
      }).toList();
      
      // Apply sorting
      _sortSections();
    });
  }

  void _sortSections() {
    switch (_sortBy) {
      case 'section_number':
        _filteredSections.sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));
        break;
      case 'section_name':
        _filteredSections.sort((a, b) => a.sectionName.compareTo(b.sectionName));
        break;
      case 'completion':
        _filteredSections.sort((a, b) => (a.hasMissingData ? 0 : 1).compareTo(b.hasMissingData ? 0 : 1));
        break;
    }
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
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Claim Overview Card
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildClaimOverviewCard(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Vehicle Information Card
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildVehicleInfoCard(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Complaint Card
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildComplaintCard(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Filters Section
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: WarrantyClaimsFilter(
                          onStatusFilter: (status) {
                            _statusFilter = status;
                            _applyFilters();
                          },
                          onSortChanged: (sortBy) {
                            _sortBy = sortBy;
                            _applyFilters();
                          },
                          onMissingDataFilter: (showMissingOnly) {
                            _showMissingDataOnly = showMissingOnly;
                            _applyFilters();
                          },
                          onSearchFilter: (query) {
                            _searchQuery = query;
                            _applyFilters();
                          },
                          onClearFilters: () {
                            _statusFilter = 'All';
                            _sortBy = 'section_number';
                            _showMissingDataOnly = false;
                            _searchQuery = '';
                            _applyFilters();
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Sections Header
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Sections Data (${_filteredSections.length}/${widget.claim.sections.length})',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Sections List
                      ..._filteredSections.asMap().entries.map((entry) {
                        final index = entry.key;
                        final section = entry.value;
                        return FadeInUp(
                          delay: Duration(milliseconds: 600 + (index * 100)),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: _buildSectionCard(section),
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
          
          // Progress Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getProgressColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getProgressColor().withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.claim.completionPercentage.toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.claim.completionPercentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getProgressColor(),
                          _getProgressColor().withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: _getProgressColor().withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.directions_car, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VEHICLE INFORMATION',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vehicle Details & Specifications',
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightGrey.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              widget.claim.vehicleInfo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.report_problem_outlined, color: Colors.orange.shade700, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPLAINT DESCRIPTION',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer Reported Issues',
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              widget.claim.complaint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(Section section) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: section.hasMissingData 
              ? Colors.orange.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: section.hasMissingData 
                      ? Colors.orange.withOpacity(0.2)
                      : AppColors.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${section.sectionNumber}',
                    style: TextStyle(
                      color: section.hasMissingData 
                          ? Colors.orange
                          : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.sectionName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: section.hasMissingData 
                            ? Colors.orange.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        section.hasMissingData ? 'Missing Data' : 'Complete',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: section.hasMissingData 
                              ? Colors.orange
                              : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                section.hasMissingData ? Icons.warning : Icons.check_circle,
                color: section.hasMissingData ? Colors.orange : AppColors.success,
                size: 24,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Section Data
          _buildSectionData(section),
          
          // Missing Fields Summary (only for sections other than 1)
          if (section.sectionNumber != 1 && section.hasMissingData && section.missingFields.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildMissingFieldsCard(section.missingFields),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionData(Section section) {
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

  // Section 1: Vehicle and diagnostic data
  Widget _buildSection1Data(Section section) {
    final data = section.parsedData;
    if (data == null || data.isEmpty) {
      return _buildNoDataWidget();
    }

    final completedFields = data.entries.where((entry) => 
        entry.value != null && entry.value.toString().trim().isNotEmpty).length;
    final totalFields = data.entries.length;
    final missingCount = section.missingFields.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with completion summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                section.hasMissingData 
                    ? Colors.orange.withOpacity(0.08)
                    : AppColors.success.withOpacity(0.08),
                section.hasMissingData 
                    ? Colors.orange.withOpacity(0.04)
                    : AppColors.success.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: section.hasMissingData 
                  ? Colors.orange.withOpacity(0.2)
                  : AppColors.success.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: section.hasMissingData 
                      ? Colors.orange.withOpacity(0.15)
                      : AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.build_outlined, 
                  color: section.hasMissingData 
                      ? Colors.orange.shade600
                      : AppColors.success, 
                  size: 22
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VEHICLE & DIAGNOSTIC DATA',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: section.hasMissingData 
                            ? Colors.orange.shade700
                            : AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$completedFields/$totalFields fields completed',
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
        ),
        const SizedBox(height: 16),
        
        // Data fields
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.25),
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
          child: Column(
            children: data.entries.map((entry) {
              final isHighlighted = section.missingFields.contains(entry.key);
              return _buildDataField(entry.key, entry.value, isHighlighted);
            }).toList(),
          ),
        ),
      ],
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
                    'FILES & ATTACHMENTS',
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

  // Section 5: Summary and conclusions
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
                    'Final assessment and recommendations',
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
              return _buildDataField(entry.key, entry.value, isHighlighted);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingFieldsCard(List<String> missingFields) {
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
                'Missing Fields (${missingFields.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: missingFields.map((field) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                field,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
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

  Color _getProgressColor() {
    if (widget.claim.completionPercentage == 100) {
      return widget.claim.hasMissingData ? Colors.orange : AppColors.success;
    } else if (widget.claim.completionPercentage >= 60) {
      return Colors.orange;
    } else {
      return AppColors.error;
    }
  }

  // Helper method to build individual data fields
  Widget _buildDataField(String key, dynamic value, bool isHighlighted) {
    final hasValue = value != null && value.toString().trim().isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? Colors.orange.withOpacity(0.06)
            : hasValue 
                ? AppColors.success.withOpacity(0.05)
                : AppColors.lightGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted 
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
              color: isHighlighted 
                  ? Colors.orange.withOpacity(0.15)
                  : hasValue 
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.lightGrey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isHighlighted 
                  ? Icons.warning_rounded
                  : hasValue 
                      ? Icons.check_rounded
                      : Icons.remove_rounded,
              color: isHighlighted 
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
                          color: isHighlighted 
                              ? Colors.orange.shade700 
                              : AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (isHighlighted)
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
                      color: isHighlighted 
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
                          : isHighlighted 
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
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: 14,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View File',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
    String fileString = file.toString();
    
    // Try to extract URL if it looks like a URL
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
