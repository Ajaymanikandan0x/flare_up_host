import 'package:flutter/material.dart';

import '../../features/authentication/presentation/screens/forgot_password.dart';
import '../../features/authentication/presentation/screens/logo.dart';
import '../../features/authentication/presentation/screens/onboard_screen.dart';
import '../../features/authentication/presentation/screens/otp.dart';
import '../../features/authentication/presentation/screens/reset_password.dart';
import '../../features/authentication/presentation/screens/sign_in.dart';
import '../../features/authentication/presentation/screens/sign_up.dart';
import '../../features/home/presentation/screens/home.dart';
import '../../features/profile/presentation/screens/edit.dart';
import '../../features/profile/presentation/screens/profile.dart';

class AppRouts {
  static const logo = '/';
  static const onBoard = '/onBoard';
  static const hostHome = '/home';
  static const signIn = '/signIn';
  static const signUp = '/signUp';
  static const hostProfile = '/profile';
  static const otpScreen = '/otpScreen';
  static const editProf = '/editProfile';
  static const forgotPassword = '/forgotPassword';
  static const resetPassword = '/resetPassword';

  static final Map<String, Widget Function(BuildContext)> routs = {
    logo: (_) => const Logo(),
    onBoard: (_) => const OnBoardingScreen(),
    signIn: (_) => SignIn(),
    signUp: (_) => SignUp(),
    hostHome: (_) => const HostHome(),
    hostProfile: (_) => const HostProfile(),
    otpScreen: (_) => const OtpScreen(),
    editProf: (_) => const EditProfile(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    resetPassword: (_) => const ResetPasswordScreen(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final builder = routs[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: (context) => builder(context),
        settings: settings,
      );
    }
    throw Exception('Route not found: ${settings.name}');
  }
}
