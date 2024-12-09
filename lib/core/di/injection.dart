import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/connectivity_service.dart';
import '../services/logger_service.dart';
import '../services/test_data_service.dart';
import '../services/feed_filter_service.dart';
import '../services/rating_service.dart';
import '../navigation/navigation_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/step_type_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firebase_post_repository.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../data/repositories/firebase_step_type_repository.dart';
import '../../data/repositories/firebase_rating_service.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../../data/repositories/mock_post_repository.dart';
import '../../data/repositories/mock_step_type_repository.dart';
import '../../data/repositories/mock_rating_service.dart';

final getIt = GetIt.instance;

// Flag to determine if we're in debug mode
const bool isDebug = true;

void setupDependencies() {
  // Services
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<TestDataService>(() => TestDataService());
  getIt.registerLazySingleton<FeedFilterService>(() => FeedFilterService());
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  if (isDebug) {
    // Use mock repositories in debug mode
    getIt.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
    getIt.registerLazySingleton<UserRepository>(() => MockUserRepository());
    getIt.registerLazySingleton<PostRepository>(() => MockPostRepository());
    getIt.registerLazySingleton<StepTypeRepository>(
        () => MockStepTypeRepository());

    // Register MockRatingService in debug mode
    getIt.registerLazySingleton<RatingService>(() => MockRatingService(
          logger: getIt<LoggerService>(),
        ));
  } else {
    // Initialize Firebase services
    getIt.registerLazySingleton(() => FirebaseAuth.instance);
    getIt.registerLazySingleton(() => FirebaseFirestore.instance);
    getIt.registerLazySingleton(() => FirebaseStorage.instance);

    // Use Firebase repositories in production mode
    getIt.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository(
          firebaseAuth: getIt<FirebaseAuth>(),
          firestore: getIt<FirebaseFirestore>(),
        ));
    getIt.registerLazySingleton<UserRepository>(() => FirebaseUserRepository(
          auth: getIt<FirebaseAuth>(),
          firestore: getIt<FirebaseFirestore>(),
          storage: getIt<FirebaseStorage>(),
        ));
    getIt.registerLazySingleton<PostRepository>(() => FirebasePostRepository());
    getIt.registerLazySingleton<StepTypeRepository>(
        () => FirebaseStepTypeRepository());

    // Register FirebaseRatingService in production mode
    getIt.registerLazySingleton<RatingService>(() => FirebaseRatingService(
          firestore: getIt<FirebaseFirestore>(),
          logger: getIt<LoggerService>(),
        ));
  }
}
