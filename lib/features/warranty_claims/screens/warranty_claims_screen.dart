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
  AnimationController? _headerController;
  Animation<double>? _headerAnimation;
  ScrollController? _scrollController;
  
  List<RepairClaim> _claims = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isHeaderVisible = true;
  double _lastScrollOffset = 0.0;

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
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController!,
      curve: Curves.easeInOut,
    ));
    
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
    
    // Start with header visible (animation value = 0)
    _headerController!.reset();
    
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _headerController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController == null || _headerController == null) return;
    
    final currentOffset = _scrollController!.offset;
    // Adjust threshold based on number of claims - higher threshold for fewer claims
    final threshold = _claims.length <= 2 ? 150.0 : 80.0;
    
    // Determine scroll direction
    final isScrollingDown = currentOffset > _lastScrollOffset;
    final isScrollingUp = currentOffset < _lastScrollOffset;
    
    // Hide header when scrolling down past threshold
    if (isScrollingDown && currentOffset > threshold && _isHeaderVisible) {
      setState(() {
        _isHeaderVisible = false;
      });
      _headerController!.forward();
    }
    // Show header when scrolling up or near top
    else if ((isScrollingUp || currentOffset <= threshold) && !_isHeaderVisible) {
      setState(() {
        _isHeaderVisible = true;
      });
      _headerController!.reverse();
    }
    
    _lastScrollOffset = currentOffset;
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
                              'Comprehensive claims management',
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
              
              // Content with collapsible header
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Column(
                        children: [
                          // Animated Stats Overview
                          if (_headerAnimation != null)
                            AnimatedBuilder(
                              animation: _headerAnimation!,
                              builder: (context, child) {
                                final animValue = _headerAnimation!.value;
                                return Transform.translate(
                                  offset: Offset(0, -200 * animValue),
                                  child: Opacity(
                                    opacity: 1 - animValue,
                                    child: Container(
                                      height: animValue == 1.0 ? 0 : null,
                                      child: animValue == 1.0 
                                          ? const SizedBox.shrink()
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 24),
                                              child: Column(
                                                children: [
                                                  WarrantyClaimsStats(
                                                    stats: _stats,
                                                    animationDelay: 100,
                                                  ),
                                                  const SizedBox(height: 20),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            // Fallback when animation is not ready
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  WarrantyClaimsStats(
                                    stats: _stats,
                                    animationDelay: 100,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          
                          // Claims Section
                          Expanded(
                            child: Padding(
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
                                              'All Warranty Claims (${_claims.length})',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          if (_claims.isNotEmpty) ...[
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
                                  Expanded(
                                    child: _claims.isEmpty
                                        ? _buildEmptyState()
                                        : RefreshIndicator(
                                            onRefresh: _refreshData,
                                            color: AppColors.primary,
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: _claims.length,
                                              padding: EdgeInsets.only(
                                                bottom: 20,
                                                // Add extra top padding for single claims to ensure scrollability
                                                top: _claims.length <= 2 ? 100 : 0,
                                              ),
                                              itemBuilder: (context, index) {
                                                final claim = _claims[index];
                                                return WarrantyClaimCard(
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
}
