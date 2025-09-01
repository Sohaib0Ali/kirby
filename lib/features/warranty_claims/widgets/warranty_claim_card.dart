import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../sections/models/repair_claim.dart';

class WarrantyClaimCard extends StatefulWidget {
  final RepairClaim claim;
  final int animationDelay;
  final VoidCallback? onTap;

  const WarrantyClaimCard({
    super.key,
    required this.claim,
    this.animationDelay = 0,
    this.onTap,
  });

  @override
  State<WarrantyClaimCard> createState() => _WarrantyClaimCardState();
}

class _WarrantyClaimCardState extends State<WarrantyClaimCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
              onTap: widget.onTap,
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Repair Number with enhanced styling
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.primary.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tag_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.claim.repairNumber,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Status Badge
                          _buildStatusBadge(),
                          const SizedBox(width: 12),
                          // Arrow Icon with container
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.grey,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Vehicle Info with icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.lightGrey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.directions_car_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VEHICLE INFORMATION',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.claim.vehicleInfo,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkGrey,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Missing Sections Display
                      if (widget.claim.hasMissingData) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.warning_outlined,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MISSING INFORMATION',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _buildMissingSectionChips(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Additional Info Row
                      if (widget.claim.coverage.isNotEmpty && widget.claim.coverage != 'Unknown' ||
                          widget.claim.inServiceDate != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (widget.claim.coverage.isNotEmpty && widget.claim.coverage != 'Unknown') ...[
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.claim.coverage,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (widget.claim.coverage.isNotEmpty && 
                                widget.claim.coverage != 'Unknown' && 
                                widget.claim.inServiceDate != null) ...[
                              const SizedBox(width: 16),
                              Container(
                                width: 1,
                                height: 12,
                                color: AppColors.lightGrey,
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (widget.claim.inServiceDate != null) ...[
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppColors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(widget.claim.inServiceDate!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
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
    String statusText;
    
    switch (widget.claim.status) {
      case 'Complete':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Completed';
        break;
      case 'Missing Data':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_rounded;
        statusText = 'Missing Data';
        break;
      case 'Incomplete':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        statusText = 'Incomplete';
        break;
      default:
        statusColor = AppColors.grey;
        statusIcon = Icons.info_rounded;
        statusText = widget.claim.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor,
            statusColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: AppColors.white,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMissingSectionChips() {
    final missingSections = widget.claim.missingSections;
    return missingSections.map((section) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          _getSectionDisplayName(section.sectionNumber),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      );
    }).toList();
  }

  String _getSectionDisplayName(int sectionNumber) {
    switch (sectionNumber) {
      case 1:
        return 'Section 1: Warranty Claim Summary';
      case 2:
        return 'Section 2: Attachments Overview';
      case 3:
        return 'Section 3: Technician Narrative';
      case 4:
        return 'Section 4: Service Report Narrative';
      case 5:
        return 'Section 5: Claim Submission Recommendation';
      default:
        return 'Section $sectionNumber';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
