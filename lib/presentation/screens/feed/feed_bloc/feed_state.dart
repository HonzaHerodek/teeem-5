import 'package:equatable/equatable.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/targeting_model.dart';
import '../../../../core/errors/app_exception.dart';

enum FeedStatus {
  initial,
  loading,
  success,
  failure,
  loadingMore,
}

class FeedState extends Equatable {
  final FeedStatus status;
  final List<PostModel> posts;
  final AppException? error;
  final bool hasReachedMax;
  final String? lastPostId;
  final String? currentUserId;
  final int page;
  final bool isRefreshing;
  final TargetingCriteria? targetingFilter;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.error,
    this.hasReachedMax = false,
    this.lastPostId,
    this.currentUserId,
    this.page = 1,
    this.isRefreshing = false,
    this.targetingFilter,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<PostModel>? posts,
    AppException? error,
    bool? hasReachedMax,
    String? lastPostId,
    String? currentUserId,
    int? page,
    bool? isRefreshing,
    TargetingCriteria? targetingFilter,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      lastPostId: lastPostId ?? this.lastPostId,
      currentUserId: currentUserId ?? this.currentUserId,
      page: page ?? this.page,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      targetingFilter: targetingFilter ?? this.targetingFilter,
    );
  }

  bool get isInitial => status == FeedStatus.initial;
  bool get isLoading => status == FeedStatus.loading;
  bool get isSuccess => status == FeedStatus.success;
  bool get isFailure => status == FeedStatus.failure;
  bool get isLoadingMore => status == FeedStatus.loadingMore;

  @override
  List<Object?> get props => [
        status,
        posts,
        error,
        hasReachedMax,
        lastPostId,
        currentUserId,
        page,
        isRefreshing,
        targetingFilter,
      ];
}
