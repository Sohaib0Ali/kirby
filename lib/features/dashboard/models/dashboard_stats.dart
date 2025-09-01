class DashboardStats {
  final int totalClaims;
  final int pendingClaims;
  final int approvedClaims;
  final int rejectedClaims;
  final double approvalRate;

  DashboardStats({
    required this.totalClaims,
    required this.pendingClaims,
    required this.approvedClaims,
    required this.rejectedClaims,
    required this.approvalRate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalClaims: json['total_claims'] as int? ?? 0,
      pendingClaims: json['pending_claims'] as int? ?? 0,
      approvedClaims: json['approved_claims'] as int? ?? 0,
      rejectedClaims: json['rejected_claims'] as int? ?? 0,
      approvalRate: (json['approval_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      totalClaims: 0,
      pendingClaims: 0,
      approvedClaims: 0,
      rejectedClaims: 0,
      approvalRate: 0.0,
    );
  }
}
