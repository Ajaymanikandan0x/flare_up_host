import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

class ToggleButton extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onChanged;
  
  const ToggleButton({
    super.key,
    this.initialValue = false,
    required this.onChanged,
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late bool isSwitchOn;

  @override
  void initState() {
    super.initState();
    isSwitchOn = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Switch(
        value: isSwitchOn,
        activeColor: AppPalette.gradient2,
        onChanged: (value) {
          setState(() {
            isSwitchOn = value;
          });
          widget.onChanged(value);
        },
      ),
    );
  }
}
