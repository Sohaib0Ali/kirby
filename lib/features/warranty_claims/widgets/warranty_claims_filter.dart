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
  String _selectedSort = 'section_number';
  bool _showMissingDataOnly = false;

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
                              'FILTERS & SEARCH',
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
            SizedBox(height: isCompact ? 12 : 16),
            
            // Search Bar - Responsive
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.lightGrey.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearchFilter,
                decoration: InputDecoration(
                  hintText: isCompact ? 'Search sections...' : 'Search sections by name or number...',
                  hintStyle: TextStyle(
                    color: AppColors.grey,
                    fontSize: isCompact ? 13 : 14,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(isCompact ? 10 : 12),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: isCompact ? 18 : 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 16,
                    vertical: isCompact ? 12 : 16,
                  ),
                ),
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: isCompact ? 13 : 14,
                ),
              ),
            ),
            SizedBox(height: isCompact ? 12 : 16),
            
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        // Stack vertically for very small screens
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildStatusChip('All', Icons.list_alt, null, isCompact)),
                                const SizedBox(width: 6),
                                Expanded(child: _buildStatusChip('Complete', Icons.check_circle_outline, AppColors.success, isCompact)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(child: _buildStatusChip('Missing Data', Icons.warning_outlined, Colors.orange, isCompact)),
                                const SizedBox(width: 6),
                                Expanded(child: _buildStatusChip('Incomplete', Icons.cancel_outlined, AppColors.error, isCompact)),
                              ],
                            ),
                          ],
                        );
                      } else {
                        // Use wrap for larger screens
                        return Wrap(
                          spacing: isCompact ? 6 : 8,
                          runSpacing: isCompact ? 6 : 8,
                          children: [
                            _buildStatusChip('All', Icons.list_alt, null, isCompact),
                            _buildStatusChip('Complete', Icons.check_circle_outline, AppColors.success, isCompact),
                            _buildStatusChip('Missing Data', Icons.warning_outlined, Colors.orange, isCompact),
                            _buildStatusChip('Incomplete', Icons.cancel_outlined, AppColors.error, isCompact),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: isCompact ? 10 : 12),
            
            // Sort Section - Responsive
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
                        Icons.sort_rounded,
                        color: AppColors.primary,
                        size: isCompact ? 16 : 18,
                      ),
                      SizedBox(width: isCompact ? 6 : 8),
                      Text(
                        'SORT BY',
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.lightGrey.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 12,
                          vertical: isCompact ? 10 : 12,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: isCompact ? 13 : 14,
                        color: AppColors.darkGrey,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'section_number',
                          child: Row(
                            children: [
                              Icon(Icons.numbers_rounded, size: isCompact ? 14 : 16, color: AppColors.grey),
                              SizedBox(width: isCompact ? 6 : 8),
                              Text('Section Number', style: TextStyle(fontSize: isCompact ? 12 : 14)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'section_name',
                          child: Row(
                            children: [
                              Icon(Icons.abc_rounded, size: isCompact ? 14 : 16, color: AppColors.grey),
                              SizedBox(width: isCompact ? 6 : 8),
                              Text('Section Name', style: TextStyle(fontSize: isCompact ? 12 : 14)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'completion',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: isCompact ? 14 : 16, color: AppColors.grey),
                              SizedBox(width: isCompact ? 6 : 8),
                              Text('Completion', style: TextStyle(fontSize: isCompact ? 12 : 14)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSort = value;
                          });
                          widget.onSortChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isCompact ? 10 : 12),
            
            // Missing Data Filter - Responsive
            Container(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              decoration: BoxDecoration(
                color: _showMissingDataOnly 
                    ? Colors.orange.withOpacity(0.06)
                    : AppColors.lightGrey.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _showMissingDataOnly 
                      ? Colors.orange.withOpacity(0.25)
                      : AppColors.lightGrey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_alt_rounded,
                        color: _showMissingDataOnly ? Colors.orange : AppColors.primary,
                        size: isCompact ? 16 : 18,
                      ),
                      SizedBox(width: isCompact ? 6 : 8),
                      Text(
                        'ADVANCED FILTER',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _showMissingDataOnly ? Colors.orange : AppColors.primary,
                          letterSpacing: 0.5,
                          fontSize: isCompact ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 8 : 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showMissingDataOnly = !_showMissingDataOnly;
                        });
                        widget.onMissingDataFilter(_showMissingDataOnly);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 6 : 8, 
                          vertical: isCompact ? 4 : 6
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: isCompact ? 18 : 20,
                              height: isCompact ? 18 : 20,
                              decoration: BoxDecoration(
                                color: _showMissingDataOnly 
                                    ? Colors.orange 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _showMissingDataOnly 
                                      ? Colors.orange 
                                      : AppColors.grey,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _showMissingDataOnly
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: isCompact ? 12 : 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            SizedBox(width: isCompact ? 8 : 10),
                            Expanded(
                              child: Text(
                                'Show Missing Data Only',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _showMissingDataOnly 
                                      ? Colors.orange.shade700
                                      : AppColors.darkGrey,
                                  fontSize: isCompact ? 12 : 13,
                                ),
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
            SizedBox(height: isCompact ? 12 : 16),
            
            // Reset Button - Responsive
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.primary.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onClearFilters,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isCompact ? 12 : 14, 
                      horizontal: isCompact ? 16 : 20
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                          size: isCompact ? 18 : 20,
                        ),
                        SizedBox(width: isCompact ? 6 : 8),
                        Text(
                          isCompact ? 'RESET FILTERS' : 'RESET ALL FILTERS',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                            fontSize: isCompact ? 12 : 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                  color: isSelected 
                      ? chipColor
                      : AppColors.darkGrey,
                  fontSize: isCompact ? 11 : 12,
                ),
                overflow: TextOverflow.ellipsis,
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
      _selectedSort = 'section_number';
      _showMissingDataOnly = false;
      _searchController.clear();
    });
    widget.onStatusFilter('All');
    widget.onSortChanged('section_number');
    widget.onMissingDataFilter(false);
    widget.onSearchFilter('');
    widget.onClearFilters();
  }
}
