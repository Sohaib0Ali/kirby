import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class FilterBar extends StatefulWidget {
  final Function(String) onStatusFilter;
  final Function(bool) onMissingDataFilter;
  final Function(String) onSearchFilter;
  final VoidCallback onClearFilters;

  const FilterBar({
    super.key,
    required this.onStatusFilter,
    required this.onMissingDataFilter,
    required this.onSearchFilter,
    required this.onClearFilters,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  bool _showMissingDataOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by repair number, vehicle, or complaint...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchFilter('');
                        },
                        icon: const Icon(Icons.clear, color: AppColors.grey),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: widget.onSearchFilter,
            ),
            
            const SizedBox(height: 16),
            
            // Filter Chips - Responsive Layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Filters Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('All'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Complete'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Missing Data'),
                      const SizedBox(width: 8),
                      _buildStatusChip('Incomplete'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Additional Filters Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Missing Data Toggle
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_outlined,
                              size: 16,
                              color: _showMissingDataOnly ? AppColors.white : AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            const Text('Missing Data Only'),
                          ],
                        ),
                        selected: _showMissingDataOnly,
                        onSelected: (selected) {
                          setState(() {
                            _showMissingDataOnly = selected;
                          });
                          widget.onMissingDataFilter(selected);
                        },
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        selectedColor: AppColors.error,
                        labelStyle: TextStyle(
                          color: _showMissingDataOnly ? AppColors.white : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    Color chipColor;
    
    switch (status) {
      case 'Complete':
        chipColor = AppColors.success;
        break;
      case 'Missing Data':
        chipColor = Colors.orange;
        break;
      case 'Incomplete':
        chipColor = AppColors.error;
        break;
      default:
        chipColor = AppColors.primary;
    }

    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : 'All';
        });
        widget.onStatusFilter(_selectedStatus);
      },
      backgroundColor: chipColor.withOpacity(0.1),
      selectedColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : chipColor,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: chipColor.withOpacity(0.3),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = 'All';
      _showMissingDataOnly = false;
      _searchController.clear();
    });
    widget.onStatusFilter('All');
    widget.onMissingDataFilter(false);
    widget.onSearchFilter('');
    widget.onClearFilters();
  }
}
