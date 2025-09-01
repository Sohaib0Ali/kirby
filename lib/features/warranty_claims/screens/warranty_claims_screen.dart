import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../sections/models/repair_claim.dart';
import '../../sections/services/sections_service.dart';
import '../widgets/warranty_claim_card.dart';
import '../widgets/warranty_claims_stats.dart';
import 'warranty_claim_detail_screen.dart';

class WarrantyClaimsScreen extends StatefulWidget {
  const WarrantyClaimsScreen({super.key});

  @override
  State<WarrantyClaimsScreen> createState() => _WarrantyClaimsScreenState();
}

class _WarrantyClaimsScreenState extends State<WarrantyClaimsScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  ScrollController? _scrollController;
  
  List<RepairClaim> _claims = [];
  List<RepairClaim> _filteredClaims = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showDropdown = false;
  List<String> _filteredRoNumbers = [];
  OverlayEntry? _overlayEntry;

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
    
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
    
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onScroll() {
    // Overview section is now always visible, no scroll hiding
  }

  Future<void> _loadData() async {
    try {
      final claims = await SectionsService.getAllRepairClaims();
      final stats = await SectionsService.getDashboardStats();
      
      if (mounted) {
        setState(() {
          _claims = claims;
          _stats = stats;
          _isLoading = false;
          _isRefreshing = false;
        });
        _applyFilters();
      }
    } catch (e) {
      print('Error loading warranty claims: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        _showErrorSnackBar('Failed to load data. Please try again.');
      }
    }
  }

  void _applyFilters() {
    List<RepairClaim> filtered = List.from(_claims);
    
    // Apply status filter
    switch (_selectedFilter) {
      case 'missing_data':
        filtered = filtered.where((claim) => claim.hasMissingData).toList();
        break;
      case 'completed':
        filtered = filtered.where((claim) => 
          claim.status.toLowerCase() == 'complete'
        ).toList();
        break;
      case 'incomplete':
        filtered = filtered.where((claim) => 
          !claim.isComplete
        ).toList();
        break;
      case 'all':
      default:
        // No filtering needed
        break;
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((claim) => 
        claim.repairNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        claim.vehicleInfo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        claim.complaint.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    setState(() {
      _filteredClaims = filtered;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (query.isNotEmpty) {
      _updateFilteredRoNumbers(query);
      _showSearchDropdown();
    } else {
      _hideSearchDropdown();
    }
    
    _applyFilters();
  }

  void _updateFilteredRoNumbers(String query) {
    final allRoNumbers = _claims.map((claim) => claim.repairNumber).toSet().toList();
    _filteredRoNumbers = allRoNumbers
        .where((ro) => ro.toLowerCase().contains(query.toLowerCase()))
        .take(10)
        .toList();
  }

  void _showSearchDropdown() {
    if (_overlayEntry != null || _filteredRoNumbers.isEmpty) return;
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _showDropdown = true;
    });
  }

  void _hideSearchDropdown() {
    _removeOverlay();
    setState(() {
      _showDropdown = false;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 24,
        top: offset.dy + 280, // Adjust based on search field position
        width: size.width - 48,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredRoNumbers.length,
              itemBuilder: (context, index) {
                final roNumber = _filteredRoNumbers[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  title: Text(
                    roNumber,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    _searchController.text = roNumber;
                    _onSearchChanged(roNumber);
                    _hideSearchDropdown();
                    _searchFocusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    _refreshController.forward();
    await _loadData();
    _refreshController.reverse();
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
              // Header with Logo and Logout
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 300;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    'Kirby',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      fontSize: isCompact ? 18 : 22,
                                      letterSpacing: 0.5,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.secondary,
                                              AppColors.primary.withOpacity(0.7),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Claims Management',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.grey.withOpacity(0.9),
                                            fontWeight: FontWeight.w500,
                                            fontSize: isCompact ? 12 : 14,
                                            letterSpacing: 0.3,
                                            height: 1.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
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
                      // Logout Button
                      IconButton(
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content - Fully Scrollable
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              // Always Visible Stats Overview
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    WarrantyClaimsStats(
                                      stats: _stats,
                                      animationDelay: 100,
                                    ),
                                    const SizedBox(height: 20),
                                    // Advanced Filter Section
                                    _buildFilterSection(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                              
                              // Claims Section
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    // Claims Header
                                    FadeInUp(
                                      delay: const Duration(milliseconds: 300),
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${_getFilterTitle()} (${_filteredClaims.length})',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            if (_filteredClaims.isNotEmpty) ...[
                                              Flexible(
                                                child: Text(
                                                  'Tap for details',
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
                                    ),
                                    
                                    // Claims List
                                    _filteredClaims.isEmpty
                                        ? _buildEmptyState()
                                        : Column(
                                            children: _filteredClaims.asMap().entries.map((entry) {
                                              final index = entry.key;
                                              final claim = entry.value;
                                              return WarrantyClaimCard(
                                                claim: claim,
                                                animationDelay: 400 + (index * 100),
                                                onTap: () {
                                                  _showClaimDetails(claim);
                                                },
                                              );
                                            }).toList(),
                                          ),
                                    
                                    // Bottom padding for better scrolling
                                    const SizedBox(height: 100),
                                  ],
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
                Icons.description_outlined,
                size: 48,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No warranty claims found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Claims will appear here once data is available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClaimDetails(RepairClaim claim) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WarrantyClaimDetailScreen(claim: claim),
      ),
    );
  }

  Widget _buildFilterSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Advanced Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search Bar with RO Number Dropdown
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              onTap: () {
                if (_searchQuery.isNotEmpty) {
                  _updateFilteredRoNumbers(_searchQuery);
                  _showSearchDropdown();
                }
              },
              decoration: InputDecoration(
                hintText: 'Search RO numbers...',
                hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showDropdown)
                      Icon(Icons.keyboard_arrow_up, color: AppColors.primary)
                    else
                      Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: AppColors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          _hideSearchDropdown();
                        },
                      ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey.withOpacity(0.5)),
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('all', 'All Claims', Icons.list),
                _buildFilterChip('missing_data', 'Missing Data', Icons.warning),
              ],
            ),
            
            if (_searchQuery.isNotEmpty || _selectedFilter != 'all') ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active filters:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_selectedFilter != 'all')
                        Chip(
                          label: Text(_getFilterTitle()),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () => _onFilterChanged('all'),
                        ),
                      if (_searchQuery.isNotEmpty)
                        Chip(
                          label: Text('"$_searchQuery"'),
                          backgroundColor: AppColors.secondary.withOpacity(0.1),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.white : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onSelected: (selected) {
        _onFilterChanged(value);
      },
      backgroundColor: AppColors.lightGrey.withOpacity(0.3),
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.white,
    );
  }

  String _getFilterTitle() {
    switch (_selectedFilter) {
      case 'missing_data':
        return 'Claims with Missing Data';
      case 'all':
      default:
        return 'All Warranty Claims';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRouter.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
