import 'package:equatable/equatable.dart';
import 'package:ty_cafe/features/admin/domain/entities/analytics_data.dart';

class AnalyticsState extends Equatable {
  final AnalyticsData? analyticsData;
  final bool loading;
  final String? error;

  const AnalyticsState({
    this.analyticsData,
    this.loading = false,
    this.error,
  });

  AnalyticsState copyWith({
    AnalyticsData? analyticsData,
    bool? loading,
    String? error,
  }) {
    return AnalyticsState(
      analyticsData: analyticsData ?? this.analyticsData,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [analyticsData, loading, error];
}




