import 'package:flutter/cupertino.dart';

import '../theme/text_theme.dart';

class AppText extends StatelessWidget {
  final String data;
  final double? fontsSize;
  const AppText({super.key, required this.data, this.fontsSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTextStyles.primaryTextTheme(fontSize: fontsSize),
    );
  }
}
