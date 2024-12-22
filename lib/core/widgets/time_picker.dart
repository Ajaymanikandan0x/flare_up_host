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
    final formattedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    widget.controller.text = formattedTime;
    if (widget.onChanged != null) {
      widget.onChanged!(formattedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPicker(
              _hourController,
              12,
              _onHourChanged,
              (index) => (index + 1).toString().padLeft(2, '0'),
              'HH',
              const BorderRadius.only(
                  topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
          _buildPicker(
              _minuteController,
              60,
              _onMinuteChanged,
              (index) => index.toString().padLeft(2, '0'),
              'MM',
              BorderRadius.zero),
          _buildPicker(
              _ampmController,
              2,
              _onAmpmChanged,
              (index) => index == 0 ? 'am' : 'pm',
              'AM/PM',
              const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
        ],
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
  ) {
    return SizedBox(
      width: 75,
      height: 150,
      child: Stack(
        children: [
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            diameterRatio: 1.2,
            offAxisFraction: 0,
            onSelectedItemChanged: onSelectedItemChanged,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  child: TimeTileWidget(
                      time: formatLabel(index), isSelected: false),
                );
              },
              childCount: itemCount,
            ),
          ),
          Center(
            child: Container(
              height: 45,
              width: double.infinity,
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
