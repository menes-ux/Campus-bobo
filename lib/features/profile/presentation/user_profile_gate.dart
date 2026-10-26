import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_user.dart';
import '../../dashboard/presentation/main_navigation_screen.dart';
import '../../auth/presentation/auth_widgets.dart';
import '../domain/user_profile.dart';
import '../domain/user_profile_repository.dart';

class UserProfileGate extends StatefulWidget {
  const UserProfileGate({super.key, required this.user});

  final AuthUser user;

  @override
  State<UserProfileGate> createState() => _UserProfileGateState();
}

class _UserProfileGateState extends State<UserProfileGate> {
  late Future<void> _profileReady;
  late Stream<UserProfile?> _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final repository = context.read<UserProfileRepository>();
    _profileReady = repository.ensureProfile(widget.user);
    _profile = repository.watchProfile(widget.user.uid);
  }

  Widget _status({bool failed = false}) {
    final auth = context.watch<AuthController>();
    return AuthLayout(
      title: failed ? 'Let\'s reconnect.' : 'Opening your account.',
      description: failed
          ? 'We could not load your account profile. Check your connection and try again.'
          : 'Getting your profile ready.',
      children: [
        AuthFeedback(auth: auth),
        if (failed)
          FilledButton(
            onPressed: () => setState(_loadProfile),
            child: const Text('Try again'),
          )
        else
          const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 20),
        TextButton(
          onPressed: auth.isBusy ? null : auth.signOut,
          child: const Text('Sign out'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _profileReady,
      builder: (context, ready) {
        if (ready.hasError) return _status(failed: true);
        if (ready.connectionState != ConnectionState.done) return _status();
        return StreamBuilder<UserProfile?>(
          stream: _profile,
          builder: (context, snapshot) {
            if (snapshot.hasError) return _status(failed: true);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _status();
            }
            final profile = snapshot.data;
            if (profile == null || profile.uid != widget.user.uid) {
              return _status(failed: true);
            }
            return Provider<UserProfile>.value(
              value: profile,
              child: MainNavigationScreen(profile: profile),
            );
          },
        );
      },
    );
  }
}
