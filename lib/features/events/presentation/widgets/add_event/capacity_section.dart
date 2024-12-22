import 'package:flutter/material.dart';

class CapacitySection extends StatelessWidget {
  final TextEditingController eventParticipantCapacityController;

  const CapacitySection({
    super.key,
    required this.eventParticipantCapacityController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Capacity Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: eventParticipantCapacityController,
          decoration: const InputDecoration(
            labelText: 'Participant Capacity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
