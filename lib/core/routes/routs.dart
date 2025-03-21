import 'package:flare_up_host/features/events/presentation/screens/add_event.dart';
import 'package:flutter/material.dart';

import '../../features/authentication/presentation/screens/forgot_password.dart';
import '../../features/authentication/presentation/screens/logo.dart';
import '../../features/authentication/presentation/screens/onboard_screen.dart';
import '../../features/authentication/presentation/screens/otp.dart';
import '../../features/authentication/presentation/screens/reset_password.dart';
import '../../features/authentication/presentation/screens/sign_in.dart';
import '../../features/authentication/presentation/screens/sign_up.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/events/presentation/screens/event_home.dart';
import '../../features/home/presentation/screens/home.dart';
import '../../features/location/presentation/screens/location.dart';
import '../../features/profile/presentation/screens/edit.dart';
import '../../features/profile/presentation/screens/profile.dart';
import '../widgets/bottom_navbar.dart';

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
  static const chat = '/chat';
  static const location = '/location';
  static const appNav = '/app_nav';
  static const editEvent = '/editEvent';
  static const eventHome = '/eventHome';
  static final Map<String, Widget Function(BuildContext)> routs = {
    logo: (_) => const Logo(),
    onBoard: (_) => const OnBoardingScreen(),
    signIn: (_) => const SignIn(),
    signUp: (_) => SignUp(),
    hostHome: (_) => const HostHome(),
    hostProfile: (_) => const HostProfile(),
    otpScreen: (_) => const OtpScreen(),
    editProf: (_) => const EditProfile(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    resetPassword: (_) => const ResetPasswordScreen(),
    chat: (_) => const ChatScreen(),
    location: (_) => const LocationScreen(),
    appNav: (_) => const AppNav(),
    editEvent: (_) => AddEventScreen(),
    eventHome: (_) => EventHome(),
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
