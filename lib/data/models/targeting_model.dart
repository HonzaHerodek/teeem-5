import 'package:json_annotation/json_annotation.dart';

part 'targeting_model.g.dart';

@JsonSerializable()
class TargetingCriteria {
  final List<String>? interests;
  final int? minAge;
  final int? maxAge;
  final List<String>? locations;
  final List<String>? languages;
  final String? experienceLevel; // beginner, intermediate, advanced
  final List<String>? skills;
  final List<String>? industries;

  TargetingCriteria({
    this.interests,
    this.minAge,
    this.maxAge,
    this.locations,
    this.languages,
    this.experienceLevel,
    this.skills,
    this.industries,
  });

  factory TargetingCriteria.fromJson(Map<String, dynamic> json) =>
      _$TargetingCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$TargetingCriteriaToJson(this);

  bool matches(TargetingCriteria userCriteria) {
    // Check age range
    if (minAge != null &&
        userCriteria.minAge != null &&
        minAge! > userCriteria.minAge!) {
      return false;
    }
    if (maxAge != null &&
        userCriteria.maxAge != null &&
        maxAge! < userCriteria.maxAge!) {
      return false;
    }

    // Check experience level
    if (experienceLevel != null &&
        userCriteria.experienceLevel != null &&
        experienceLevel != userCriteria.experienceLevel) {
      return false;
    }

    // Check for any matching interests
    if (interests != null &&
        interests!.isNotEmpty &&
        userCriteria.interests != null) {
      if (!interests!
          .any((interest) => userCriteria.interests!.contains(interest))) {
        return false;
      }
    }

    // Check for any matching locations
    if (locations != null &&
        locations!.isNotEmpty &&
        userCriteria.locations != null) {
      if (!locations!
          .any((location) => userCriteria.locations!.contains(location))) {
        return false;
      }
    }

    // Check for any matching languages
    if (languages != null &&
        languages!.isNotEmpty &&
        userCriteria.languages != null) {
      if (!languages!
          .any((language) => userCriteria.languages!.contains(language))) {
        return false;
      }
    }

    // Check for any matching skills
    if (skills != null && skills!.isNotEmpty && userCriteria.skills != null) {
      if (!skills!.any((skill) => userCriteria.skills!.contains(skill))) {
        return false;
      }
    }

    // Check for any matching industries
    if (industries != null &&
        industries!.isNotEmpty &&
        userCriteria.industries != null) {
      if (!industries!
          .any((industry) => userCriteria.industries!.contains(industry))) {
        return false;
      }
    }

    return true;
  }

  TargetingCriteria copyWith({
    List<String>? interests,
    int? minAge,
    int? maxAge,
    List<String>? locations,
    List<String>? languages,
    String? experienceLevel,
    List<String>? skills,
    List<String>? industries,
  }) {
    return TargetingCriteria(
      interests: interests ?? this.interests,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      locations: locations ?? this.locations,
      languages: languages ?? this.languages,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      skills: skills ?? this.skills,
      industries: industries ?? this.industries,
    );
  }
}
