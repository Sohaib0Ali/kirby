import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class WarrantyClaimsStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  final int animationDelay;

  const WarrantyClaimsStats({
    super.key,
    required this.stats,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: animationDelay),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Claims Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Stats Grid - Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 400;
                
                if (isCompact) {
                  // Stacked layout for smaller screens
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Total Claims',
                          stats['total_claims']?.toString() ?? '0',
                          Icons.description_outlined,
                          AppColors.primary,
                          isCompact: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Missing Data',
                          stats['missing_data_claims']?.toString() ?? '0',
                          Icons.warning_outlined,
                          Colors.orange,
                          isCompact: true,
                        ),
                      ),
                    ],
                  );
                } else {
                  // Single row layout for larger screens
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Total Claims',
                          stats['total_claims']?.toString() ?? '0',
                          Icons.description_outlined,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Missing Data',
                          stats['missing_data_claims']?.toString() ?? '0',
                          Icons.warning_outlined,
                          Colors.orange,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Completion Rate
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Completion Rate',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(stats['completion_rate'] ?? 0.0).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (stats['completion_rate'] ?? 0.0) / 100,
                    backgroundColor: AppColors.lightGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.12),
            color.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 6 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: isCompact ? 18 : 22,
            ),
          ),
          SizedBox(height: isCompact ? 6 : 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: isCompact ? 18 : 22,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 10 : 11,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: isCompact ? 2 : 1,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
