import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../models/repair_claim.dart';
import '../services/sections_service.dart';
import '../widgets/filter_bar.dart';
import '../widgets/repair_claim_card.dart';
import '../widgets/sections_dashboard_stats.dart';

class SectionsDashboardScreen extends StatefulWidget {
  const SectionsDashboardScreen({super.key});

  @override
  State<SectionsDashboardScreen> createState() => _SectionsDashboardScreenState();
}

class _SectionsDashboardScreenState extends State<SectionsDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  
  List<RepairClaim> _allClaims = [];
  List<RepairClaim> _filteredClaims = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isRefreshing = false;
  
  // Filter states
  String _statusFilter = 'All';
  bool _showMissingDataOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
    
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final claims = await SectionsService.getAllRepairClaims();
      final stats = await SectionsService.getDashboardStats();
      
      if (mounted) {
        setState(() {
          _allClaims = claims;
          _filteredClaims = claims;
          _stats = stats;
          _isLoading = false;
          _isRefreshing = false;
        });
        _applyFilters();
      }
    } catch (e) {
      print('Error loading sections data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        _showErrorSnackBar('Failed to load data. Please try again.');
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    _refreshController.forward();
    await _loadData();
    _refreshController.reverse();
  }

  void _applyFilters() {
    setState(() {
      _filteredClaims = _allClaims.where((claim) {
        // Status filter
        bool statusMatch = _statusFilter == 'All' || claim.status == _statusFilter;
        
        // Missing data filter
        bool missingDataMatch = !_showMissingDataOnly || claim.hasMissingData;
        
        // Search filter
        bool searchMatch = _searchQuery.isEmpty ||
            claim.repairNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            claim.vehicleInfo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            claim.complaint.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return statusMatch && missingDataMatch && searchMatch;
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRouter.home),
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
                              'Warranty Claims',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Manage and track repair sections',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Refresh Button
                      AnimatedBuilder(
                        animation: _refreshAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _refreshAnimation.value * 2 * 3.14159,
                            child: IconButton(
                              onPressed: _isRefreshing ? null : _refreshData,
                              icon: Icon(
                                Icons.refresh,
                                color: _isRefreshing ? AppColors.grey : AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Dashboard Stats
                            SectionsDashboardStats(
                              stats: _stats,
                              animationDelay: 100,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Filter Bar
                            FilterBar(
                              onStatusFilter: (status) {
                                _statusFilter = status;
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
                                _showMissingDataOnly = false;
                                _searchQuery = '';
                                _applyFilters();
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Results Header
                            FadeInUp(
                              delay: const Duration(milliseconds: 300),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Claims (${_filteredClaims.length})',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  if (_filteredClaims.isNotEmpty) ...[
                                    Flexible(
                                      child: Text(
                                        'Tap to expand details',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Claims List
                            Expanded(
                              child: _filteredClaims.isEmpty
                                  ? _buildEmptyState()
                                  : RefreshIndicator(
                                      onRefresh: _refreshData,
                                      color: AppColors.primary,
                                      child: ListView.builder(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemCount: _filteredClaims.length,
                                        padding: const EdgeInsets.only(bottom: 20),
                                        itemBuilder: (context, index) {
                                          final claim = _filteredClaims[index];
                                          return RepairClaimCard(
                                            claim: claim,
                                            animationDelay: 400 + (index * 100),
                                            onTap: () {
                                              _showClaimDetails(claim);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                            ),
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

  Widget _buildEmptyState() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isNotEmpty || _statusFilter != 'All' || _showMissingDataOnly
                    ? Icons.search_off
                    : Icons.inbox_outlined,
                size: 48,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _statusFilter != 'All' || _showMissingDataOnly
                  ? 'No claims match your filters'
                  : 'No warranty claims found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _statusFilter != 'All' || _showMissingDataOnly
                  ? 'Try adjusting your search or filters'
                  : 'Claims will appear here once data is available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _statusFilter != 'All' || _showMissingDataOnly) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _statusFilter = 'All';
                    _showMissingDataOnly = false;
                    _searchQuery = '';
                  });
                  _applyFilters();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showClaimDetails(RepairClaim claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Repair #${claim.repairNumber}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection(
                          'Vehicle Information',
                          claim.vehicleInfo,
                          context,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailSection(
                          'Complaint',
                          claim.complaint,
                          context,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Additional Information
                        if (claim.coverage.isNotEmpty && claim.coverage != 'Unknown') ...[
                          _buildDetailSection(
                            'Coverage',
                            claim.coverage,
                            context,
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        if (claim.inServiceDate != null) ...[
                          _buildDetailSection(
                            'In-Service Date',
                            '${claim.inServiceDate!.day}/${claim.inServiceDate!.month}/${claim.inServiceDate!.year}',
                            context,
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Sections Status
                        Text(
                          'Sections Status (${claim.sections.length}/5)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Sections list with better layout
                        ...claim.sections.map((section) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: section.hasMissingData 
                                  ? Colors.orange.withOpacity(0.3)
                                  : AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
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
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            section.sectionName,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            section.hasMissingData 
                                                ? 'Has missing data'
                                                : 'Complete',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: section.hasMissingData 
                                                  ? Colors.orange
                                                  : AppColors.success,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      section.hasMissingData ? Icons.warning : Icons.check_circle,
                                      color: section.hasMissingData ? Colors.orange : AppColors.success,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                
                                // Show missing fields if any
                                if (section.hasMissingData && section.missingFields.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Missing Fields:',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          section.missingFields.take(5).join(', ') + 
                                              (section.missingFields.length > 5 ? '...' : ''),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDetailSection(String title, String content, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
