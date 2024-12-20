import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../core/utils/logger.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/text_theme.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(

    scopes: [
      'email',
      'profile',
      'openid',
    ],
    signInOption: SignInOption.standard,
    serverClientId:
        '837006381197-ntpeojnppdcu0g5j01enk4gm8spaimfm.apps.googleusercontent.com',

  );

  Future<void> _handleSignIn() async {
    try {
      Logger.debug('\n=== Starting Google Sign In Process ===');

      Logger.debug('1. Initiating sign out to ensure fresh sign-in...');
      await _googleSignIn.signOut();

      Logger.debug('2. Attempting to sign in...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        Logger.debug('Sign in cancelled by user');
        return;

      }

      Logger.debug('\n3. Account Details:');
      Logger.debug('Email: ${account.email}');
      Logger.debug('Display Name: ${account.displayName}');
      Logger.debug('ID: ${account.id}');

      Logger.debug('\n4. Requesting authentication...');
      final GoogleSignInAuthentication auth = await account.authentication;

      Logger.debug('\n5. Authentication tokens:');
      Logger.debug('Access Token present: ${auth.accessToken != null}');
      Logger.debug('ID Token present: ${auth.idToken != null}');

      // Always use ID token for backend authentication
      final String? token = auth.idToken;
      if (token == null) {
        Logger.error('\nERROR: Failed to obtain ID token', 'Access Token: ${auth.accessToken}');
        throw Exception('Failed to obtain ID token');
      }

      Logger.debug('\n6. ID Token obtained successfully');
      Logger.debug('Token length: ${token.length}');
      Logger.debug('Token prefix: ${token.substring(0, 10)}...');

      if (!mounted) return;
      context.read<AuthBloc>().add(GoogleAuthEvent(accessToken: token));
    } catch (error) {
      Logger.error('\n=== Error Details ===', error, StackTrace.current);

      Logger.debug('Error type: ${error.runtimeType}');
      Logger.debug('Full error details: $error');

      if (!mounted) return;

      String message = 'Authentication failed';
      if (error is PlatformException) {
        Logger.debug('\nPlatform Exception Details:');
        Logger.debug('Error code: ${error.code}');
        Logger.debug('Error message: ${error.message}');
        Logger.debug('Error details: ${error.details}');

        if (error.code == 'sign_in_failed') {
          message =
              'Google Sign In configuration error. Please check your setup.';
        } else {
          message = error.message ?? 'Google Sign In failed';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),

          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {

        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, '/home');

        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,

              duration: const Duration(seconds: 3),

            ),
          );
        }
      },
      child: ElevatedButton.icon(
        onPressed: _handleSignIn,
        icon: Image.asset(
          'assets/images/google/logo.png',
          height: 27,
          width: 27,
        ),
        label: Text(
          'Continue with Google',
          style: AppTextStyles.primaryTextTheme(fontSize: 17).copyWith(
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppPalette.darkCard,
          minimumSize: const Size(340, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
