import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../models/repair_claim.dart';

class RepairClaimCard extends StatefulWidget {
  final RepairClaim claim;
  final int animationDelay;
  final VoidCallback? onTap;

  const RepairClaimCard({
    super.key,
    required this.claim,
    this.animationDelay = 0,
    this.onTap,
  });

  @override
  State<RepairClaimCard> createState() => _RepairClaimCardState();
}

class _RepairClaimCardState extends State<RepairClaimCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: widget.animationDelay),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTapCancel: () => _controller.reverse(),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                widget.onTap?.call();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                  border: widget.claim.hasMissingData
                      ? Border.all(color: AppColors.error.withOpacity(0.3), width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    // Main Card Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            children: [
                              // Repair Number
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.claim.repairNumber,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Status Badge
                              _buildStatusBadge(),
                              const SizedBox(width: 8),
                              // Expand Icon
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Vehicle Info
                          Text(
                            widget.claim.vehicleInfo,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Complaint
                          Text(
                            widget.claim.complaint,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                            maxLines: _isExpanded ? null : 2,
                            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Progress and Stats Row
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Completion Progress
                              Row(
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Sections: ${widget.claim.sections.length}/5 (${widget.claim.completionPercentage.toInt()}%)',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // File Count
                                  if (widget.claim.fileCount > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attach_file,
                                            size: 14,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${widget.claim.fileCount}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.secondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: widget.claim.completionPercentage / 100,
                                backgroundColor: AppColors.lightGrey,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getProgressColor(),
                                ),
                              ),
                            ],
                          ),
                          
                          // Missing Data Warning
                          if (widget.claim.hasMissingData) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_outlined,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Missing data in ${widget.claim.missingSectionsCount} section${widget.claim.missingSectionsCount > 1 ? 's' : ''}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Expandable Content
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isExpanded ? null : 0,
                      child: _isExpanded ? _buildExpandedContent() : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    IconData statusIcon;
    
    switch (widget.claim.status) {
      case 'Complete':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Missing Data':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_outlined;
        break;
      case 'Incomplete':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = AppColors.grey;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: AppColors.white,
          ),
          const SizedBox(width: 4),
          Text(
            widget.claim.status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sections Status
            Text(
              'Sections Overview',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            
            // Section Grid - Responsive
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 300 ? 5 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final sectionNumber = index + 1;
                    final section = widget.claim.getSection(sectionNumber);
                    final hasSection = section != null;
                    final hasMissingData = section?.hasMissingData ?? false;
                    
                    Color sectionColor;
                    IconData sectionIcon;
                    String tooltip;
                    
                    if (!hasSection) {
                      sectionColor = AppColors.error;
                      sectionIcon = Icons.close;
                      tooltip = 'Section $sectionNumber: Missing';
                    } else if (hasMissingData) {
                      sectionColor = Colors.orange;
                      sectionIcon = Icons.warning;
                      tooltip = 'Section $sectionNumber: Has missing data';
                    } else {
                      sectionColor = AppColors.success;
                      sectionIcon = Icons.check;
                      tooltip = 'Section $sectionNumber: Complete';
                    }
                    
                    return Tooltip(
                      message: tooltip,
                      child: Container(
                        decoration: BoxDecoration(
                          color: sectionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sectionColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              sectionIcon,
                              color: sectionColor,
                              size: 16,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'S$sectionNumber',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: sectionColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Detailed Section Information
            _buildDetailedSectionInfo(),
            
            // Additional Details
            if (widget.claim.coverage.isNotEmpty && widget.claim.coverage != 'Unknown') ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.shield_outlined,
                'Coverage',
                widget.claim.coverage,
                AppColors.secondary,
              ),
            ],
            
            if (widget.claim.inServiceDate != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'In-Service Date',
                _formatDate(widget.claim.inServiceDate!),
                AppColors.grey,
              ),
            ],
            
            // Files Information
            if (widget.claim.fileCount > 0) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.attach_file,
                'Attached Files',
                '${widget.claim.fileCount} file${widget.claim.fileCount > 1 ? 's' : ''}',
                AppColors.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailedSectionInfo() {
    if (widget.claim.sections.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Section Details',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.claim.sections.map((section) => _buildSectionDetailCard(section)),
      ],
    );
  }
  
  Widget _buildSectionDetailCard(dynamic section) {
    final sectionNumber = section.sectionNumber;
    final hasMissingData = section.hasMissingData;
    final missingFields = section.missingFields;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasMissingData ? Colors.orange.withOpacity(0.3) : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasMissingData ? Icons.warning : Icons.check_circle,
                size: 16,
                color: hasMissingData ? Colors.orange : AppColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Section $sectionNumber',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: hasMissingData ? Colors.orange : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          if (hasMissingData && missingFields.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Missing: ${missingFields.take(3).join(', ')}${missingFields.length > 3 ? '...' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
