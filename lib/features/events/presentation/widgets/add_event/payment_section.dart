import 'package:flutter/material.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/form_field.dart';
import '../../../../../core/widgets/toggle.dart';

class PaymentSection extends StatefulWidget {
  final TextEditingController eventTicketPriceController;
  final bool isPaymentRequired;
  final ValueChanged<bool> onPaymentRequiredChanged;

  const PaymentSection({
    super.key,
    required this.eventTicketPriceController,
    required this.isPaymentRequired,
    required this.onPaymentRequiredChanged,
  });

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Responsive.spacingHeight),
        Row(
          children: [
            const Text('Payment Required'),
            const Spacer(),
            ToggleButton(
              initialValue: widget.isPaymentRequired,
              onChanged: widget.onPaymentRequiredChanged,
            ),
          ],
        ),
        if (widget.isPaymentRequired) ...[
          SizedBox(height: Responsive.spacingHeight),
          AppFormField(
            hint: 'Ticket Price',
            controller: widget.eventTicketPriceController,
            keyboardType: TextInputType.number,
            icon: const Icon(Icons.attach_money),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter ticket price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}