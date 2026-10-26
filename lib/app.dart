import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/profile/data/firestore_user_profile_repository.dart';
import 'features/profile/domain/user_profile_repository.dart';

class CampusBoboApp extends StatelessWidget {
  const CampusBoboApp({
    super.key,
    this.authRepository,
    this.userProfileRepository,
  });

  final AuthRepository? authRepository;
  final UserProfileRepository? userProfileRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            authRepository ?? FirebaseAuthRepository(FirebaseAuth.instance),
          ),
        ),
        Provider<UserProfileRepository>(
          create: (_) =>
              userProfileRepository ??
              FirestoreUserProfileRepository(FirebaseFirestore.instance),
        ),
      ],
      child: MaterialApp(
        title: 'Campus Bobo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
