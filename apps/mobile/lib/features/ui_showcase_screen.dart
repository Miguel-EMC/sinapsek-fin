import 'package:flutter/material.dart';
import '../core/widgets/custom_buttons.dart';
import '../core/widgets/custom_alerts.dart';
import '../core/widgets/balance_card.dart';
import '../core/widgets/action_grid.dart';
import '../core/widgets/transaction_row.dart';

class UIShowcaseScreen extends StatelessWidget {
  const UIShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Showcase'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BalanceCard(
              title: 'Total Balance',
              balance: '\$2,450.00',
              subtitle: 'Updated 2 mins ago',
            ),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ActionGrid(
              items: [
                ActionGridItem(icon: Icons.send, label: 'Send', onTap: () {}),
                ActionGridItem(icon: Icons.account_balance_wallet, label: 'Pay', onTap: () {}),
                ActionGridItem(icon: Icons.add, label: 'Top up', onTap: () {}),
                ActionGridItem(icon: Icons.more_horiz, label: 'More', onTap: () {}),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Buttons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Primary Button', onPressed: () {}),
            const SizedBox(height: 12),
            SecondaryButton(label: 'Secondary Button', onPressed: () {}),
            const SizedBox(height: 24),
            const Text('Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Success Alert',
                    onPressed: () => CustomAlerts.showSuccess(context, 'Operation successful!'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Error Alert',
                    onPressed: () => CustomAlerts.showError(context, 'Something went wrong.'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Inputs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: 'Invalid email address',
              ),
            ),
            const SizedBox(height: 24),
            const Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            const TransactionRow(
              title: 'Netflix Subscription',
              subtitle: 'Entertainment • Today',
              amount: '-\$12.99',
              icon: Icons.play_arrow,
            ),
            const TransactionRow(
              title: 'Salary Deposit',
              subtitle: 'Work • Yesterday',
              amount: '+\$3,200.00',
              icon: Icons.attach_money,
              isNegative: false,
            ),
            const TransactionRow(
              title: 'Starbucks Coffee',
              subtitle: 'Food & Drink • 2 days ago',
              amount: '-\$4.50',
              icon: Icons.local_cafe,
            ),
          ],
        ),
      ),
    );
  }
}
