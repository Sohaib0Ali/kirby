import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class WarrantyClaimsFilter extends StatefulWidget {
  final Function(String) onStatusFilter;
  final Function(String) onSortChanged;
  final Function(bool) onMissingDataFilter;
  final Function(String) onSearchFilter;
  final VoidCallback onClearFilters;

  const WarrantyClaimsFilter({
    super.key,
    required this.onStatusFilter,
    required this.onSortChanged,
    required this.onMissingDataFilter,
    required this.onSearchFilter,
    required this.onClearFilters,
  });

  @override
  State<WarrantyClaimsFilter> createState() => _WarrantyClaimsFilterState();
}

class _WarrantyClaimsFilterState extends State<WarrantyClaimsFilter> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
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
            // Header Section - Responsive
            Container(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.primary.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isCompact ? 6 : 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.tune_rounded, 
                          color: AppColors.primary, 
                          size: isCompact ? 18 : 20
                        ),
                      ),
                      SizedBox(width: isCompact ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FILTERS',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                                fontSize: isCompact ? 12 : 13,
                              ),
                            ),
                            if (!isCompact) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Refine your data view',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _clearAllFilters,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 8 : 12, 
                                vertical: isCompact ? 6 : 8
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded, 
                                    size: isCompact ? 14 : 16,
                                    color: AppColors.grey,
                                  ),
                                  if (!isCompact) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status Filter Section - Responsive
            Container(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.lightGrey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.primary,
                        size: isCompact ? 16 : 18,
                      ),
                      SizedBox(width: isCompact ? 6 : 8),
                      Text(
                        'STATUS',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                          fontSize: isCompact ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 8 : 12),
                  // Simple row layout for three filter options
                  Row(
                    children: [
                      Expanded(child: _buildStatusChip('All', Icons.list_alt, null, isCompact)),
                      const SizedBox(width: 4),
                      Expanded(child: _buildStatusChip('Missing Data', Icons.warning_outlined, Colors.orange, isCompact)),
                      const SizedBox(width: 4),
                      Expanded(child: _buildStatusChip('Completed', Icons.check_circle_outline, AppColors.success, isCompact)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build status chips
  Widget _buildStatusChip(String status, IconData icon, Color? color, bool isCompact) {
    final isSelected = _selectedStatus == status;
    final chipColor = color ?? AppColors.primary;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        widget.onStatusFilter(status);
      },
      borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 14, 
          vertical: isCompact ? 6 : 8
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? chipColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
          border: Border.all(
            color: isSelected 
                ? chipColor
                : AppColors.lightGrey.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isCompact ? 14 : 16,
              color: isSelected 
                  ? chipColor
                  : AppColors.grey,
            ),
            SizedBox(width: isCompact ? 4 : 6),
            Flexible(
              child: Text(
                status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: isCompact ? 10 : 11,
                  color: isSelected 
                      ? chipColor
                      : AppColors.darkGrey,
                ),
                overflow: TextOverflow.visible,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = 'All';
      _searchController.clear();
    });
    widget.onStatusFilter('All');
    widget.onSortChanged('section_number');
    widget.onMissingDataFilter(false);
    widget.onSearchFilter('');
    widget.onClearFilters();
  }
}
