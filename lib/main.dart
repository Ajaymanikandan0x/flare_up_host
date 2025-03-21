import 'package:flare_up_host/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/routes/routs.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'dependency_injector.dart';
import 'service/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await dotenv.load(fileName: ".env");
  await AppConfig.initialize();
  final injector = DependencyInjector();
  injector.setup();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => DependencyInjector().authBloc),
      BlocProvider(create: (context) => DependencyInjector().hostProfileBloc),
      BlocProvider(create: (context) => DependencyInjector().eventBloc),
      BlocProvider(create: (context) => DependencyInjector().locationBloc),
      BlocProvider(create: (context) => DependencyInjector().videoPlayerCubit),
      BlocProvider(create: (context) => ThemeCubit(prefs)),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'FlareUp',
          theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          onGenerateRoute: AppRouts.generateRoute,
          initialRoute: AppRouts.logo,
          // home: AddEventScreen(),
        );
      },
    );
  }
}
