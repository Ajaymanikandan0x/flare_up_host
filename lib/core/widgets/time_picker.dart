import 'package:flare_up_host/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class TimeField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const TimeField({
    super.key,
    required this.controller,
    this.label,
    this.prefixIcon,
    this.onChanged,
    this.validator,
  });

  @override
  _TimeFieldState createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  final FixedExtentScrollController _hourController =
      FixedExtentScrollController();
  final FixedExtentScrollController _minuteController =
      FixedExtentScrollController();
  final FixedExtentScrollController _ampmController =
      FixedExtentScrollController();
  DateTime _selectedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializePickers();
  }

  void _initializePickers() {
    int currentHour = DateTime.now().hour % 12;
    int currentMinute = DateTime.now().minute;
    int ampmIndex = DateTime.now().hour >= 12 ? 1 : 0;

    _hourController.jumpToItem(currentHour);
    _minuteController.jumpToItem(currentMinute);
    _ampmController.jumpToItem(ampmIndex);
  }

  void _onHourChanged(int index) {
    setState(() {
      _selectedTime = _selectedTime.copyWith(hour: index % 12);
    });
  }

  void _onMinuteChanged(int index) {
    setState(() {
      _selectedTime = _selectedTime.copyWith(minute: index);
    });
  }

  void _onAmpmChanged(int index) {
    setState(() {
      int currentHour = _selectedTime.hour;
      if (index == 0 && currentHour >= 12) {
        _selectedTime = _selectedTime.copyWith(hour: currentHour - 12);
      } else if (index == 1 && currentHour < 12) {
        _selectedTime = _selectedTime.copyWith(hour: currentHour + 12);
      }
    });
  }

  void _updateControllerValue() {
    final hour = _selectedTime.hour;
    final minute = _selectedTime.minute;
    final formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    widget.controller.text = formattedTime;
    if (widget.onChanged != null) {
      widget.onChanged!(formattedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // Calculate responsive dimensions
    final pickerWidth = (Responsive.screenWidth * 0.25).clamp(50.0, 80.0);
    final ampmWidth = (Responsive.screenWidth * 0.18)
        .clamp(40.0, 60.0); // Smaller width for AM/PM
    final pickerHeight = Responsive.isTablet ? 180.0 : 150.0;
    final itemExtent = Responsive.isTablet ? 50.0 : 40.0;
    final selectedBoxHeight = Responsive.isTablet ? 55.0 : 45.0;
    final borderRadius = Responsive.borderRadius * 0.2;

    return Container(
      constraints: BoxConstraints(
        maxWidth: Responsive.screenWidth * 0.85,
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: _buildPicker(
                _hourController,
                12,
                _onHourChanged,
                (index) => (index + 1).toString().padLeft(2, '0'),
                'HH',
                BorderRadius.horizontal(left: Radius.circular(borderRadius)),
                pickerWidth,
                pickerHeight,
                itemExtent,
                selectedBoxHeight,
              ),
            ),
            Flexible(
              flex: 3,
              child: _buildPicker(
                _minuteController,
                60,
                _onMinuteChanged,
                (index) => index.toString().padLeft(2, '0'),
                'MM',
                BorderRadius.zero,
                pickerWidth,
                pickerHeight,
                itemExtent,
                selectedBoxHeight,
              ),
            ),
            Flexible(
              flex: 2, // Smaller flex for AM/PM
              child: _buildPicker(
                _ampmController,
                2,
                _onAmpmChanged,
                (index) => index == 0 ? 'am' : 'pm',
                'AM/PM',
                BorderRadius.horizontal(right: Radius.circular(borderRadius)),
                ampmWidth, // Use smaller width for AM/PM
                pickerHeight,
                itemExtent,
                selectedBoxHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(
    FixedExtentScrollController controller,
    int itemCount,
    ValueChanged<int> onSelectedItemChanged,
    String Function(int) formatLabel,
    String semanticLabel,
    BorderRadius borderRadius,
    double width,
    double height,
    double itemExtent,
    double selectedBoxHeight,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: itemExtent,
            diameterRatio: 1.2,
            offAxisFraction: 0,
            onSelectedItemChanged: (index) {
              onSelectedItemChanged(index);
              _updateControllerValue();
            },
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  child: TimeTileWidget(
                    time: formatLabel(index),
                    isSelected: false,
                  ),
                );
              },
              childCount: itemCount,
            ),
          ),
          Center(
            child: Container(
              height: selectedBoxHeight,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: borderRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeTileWidget extends StatelessWidget {
  final String time;
  final bool isSelected;

  const TimeTileWidget(
      {super.key, required this.time, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          time,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
        ),
      ),
    );
  }
}
