// lib/features/events/presentation/screens/event_approval_waiting_screen.dart
import 'package:flare_up_host/core/routes/routs.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/responsive_utils.dart';

class EventApprovalWaitingScreen extends StatelessWidget {
  const EventApprovalWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.pending_actions,
                size: 100,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Event Pending Approval',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your event has been submitted and is waiting for admin approval. You will be notified once it\'s approved.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRouts.appNav, (route) => false),
                text: 'Back to Events',
                width: double.infinity,
                height: Responsive.buttonHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}