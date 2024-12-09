import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'targeting_model.dart';
import 'user_model.dart';
import 'rating_model.dart';
import 'trait_model.dart';

part 'post_model.g.dart';

@JsonEnum(alwaysCreate: true)
enum StepType {
  text,
  image,
  video,
  audio,
  quiz,
  code,
  ar,
  vr,
}

@JsonEnum(alwaysCreate: true)
enum PostStatus {
  draft,
  pending,
  active,
  archived,
  deleted,
}

@JsonSerializable(explicitToJson: true)
class PostStep {
  final String id;
  final String title;
  final String description;
  @JsonKey(defaultValue: StepType.text)
  final StepType type;
  final Map<String, dynamic> content;

  const PostStep({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
  });

  factory PostStep.fromJson(Map<String, dynamic> json) =>
      _$PostStepFromJson(json);

  Map<String, dynamic> toJson() => _$PostStepToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostModel {
  final String id;
  final String userId;
  final String username;
  final String? userProfileImage;
  final String? title;
  final String description;
  @JsonKey(defaultValue: <PostStep>[])
  final List<PostStep> steps;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(defaultValue: <String>[])
  final List<String> likes;
  @JsonKey(defaultValue: <String>[])
  final List<String> comments;
  @JsonKey(defaultValue: PostStatus.active)
  final PostStatus status;
  final Map<String, dynamic>? aiMetadata;
  final TargetingCriteria? targetingCriteria;
  @JsonKey(defaultValue: <RatingModel>[])
  final List<RatingModel> ratings;
  @JsonKey(defaultValue: <TraitModel>[])
  final List<TraitModel> userTraits;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userProfileImage,
    this.title,
    required this.description,
    List<PostStep>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? likes,
    List<String>? comments,
    PostStatus? status,
    this.aiMetadata,
    this.targetingCriteria,
    List<RatingModel>? ratings,
    List<TraitModel>? userTraits,
  })  : steps = steps ?? const [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        likes = likes ?? const [],
        comments = comments ?? const [],
        ratings = ratings ?? const [],
        userTraits = userTraits ?? const [],
        status = status ?? PostStatus.active;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  RatingStats get ratingStats => RatingStats.fromRatings(ratings);

  double? getUserRating(String userId) {
    final userRating = ratings.where((r) => r.userId == userId).firstOrNull;
    return userRating?.value;
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userProfileImage,
    String? title,
    String? description,
    List<PostStep>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? likes,
    List<String>? comments,
    PostStatus? status,
    Map<String, dynamic>? aiMetadata,
    TargetingCriteria? targetingCriteria,
    List<RatingModel>? ratings,
    List<TraitModel>? userTraits,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      title: title ?? this.title,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      aiMetadata: aiMetadata ?? this.aiMetadata,
      targetingCriteria: targetingCriteria ?? this.targetingCriteria,
      ratings: ratings ?? this.ratings,
      userTraits: userTraits ?? this.userTraits,
    );
  }

  bool isTargetedTo(UserModel user) {
    if (targetingCriteria == null || user.targetingCriteria == null) {
      return true; // If no targeting criteria set, post is visible to everyone
    }
    return targetingCriteria!.matches(user.targetingCriteria!);
  }
}

@JsonSerializable()
class RatingStats {
  final double averageRating;
  final int totalRatings;

  const RatingStats({
    required this.averageRating,
    required this.totalRatings,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) =>
      _$RatingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$RatingStatsToJson(this);

  factory RatingStats.fromRatings(List<RatingModel> ratings) {
    if (ratings.isEmpty) {
      return const RatingStats(averageRating: 0, totalRatings: 0);
    }

    final total = ratings.fold<double>(0, (sum, r) => sum + r.value);
    return RatingStats(
      averageRating: total / ratings.length,
      totalRatings: ratings.length,
    );
  }
}
