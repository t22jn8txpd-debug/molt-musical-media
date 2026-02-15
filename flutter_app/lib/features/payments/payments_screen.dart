import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/services.dart';
import '../../app/theme.dart';
import '../../shared/widgets/gradient_button.dart';

/// Payment options screen for hiring agents.
/// Supports USDC (Solana), Apple Pay, and Stripe.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key, this.services});

  final AppServices? services;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _selectedMethod = 'usdc';
  double _amount = 25.0;
  bool _isProcessing = false;
  String? _resultMessage;
  bool _isSuccess = false;

  // Stub wallet address
  final _walletController = TextEditingController();

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _resultMessage = null;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      switch (_selectedMethod) {
        case 'usdc':
          _resultMessage = 'Solana wallet connect coming soon! Your wallet will be prompted to approve \$${_amount.toStringAsFixed(2)} USDC.';
          _isSuccess = true;
          break;
        case 'apple_pay':
          _resultMessage = 'Apple Pay integration coming soon! Amount: \$${_amount.toStringAsFixed(2)}';
          _isSuccess = true;
          break;
        case 'stripe':
          _resultMessage = 'Stripe checkout coming soon! You\'ll be redirected to a secure payment page for \$${_amount.toStringAsFixed(2)}.';
          _isSuccess = true;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: MoltColors.backgroundGradient),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // Header
          ShaderMask(
            shaderCallback: (b) => MoltColors.purplePinkGradient.createShader(b),
            child: Text(
              '💰 Payments',
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pay for agent services with crypto or traditional payment methods.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Amount selector
          _SectionCard(
            title: '💵 Amount',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${_amount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: MoltColors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: MoltColors.purple,
                    inactiveTrackColor: MoltColors.surfaceLight,
                    thumbColor: MoltColors.purple,
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _amount,
                    min: 5,
                    max: 500,
                    divisions: 99,
                    onChanged: (v) => setState(() => _amount = v),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [10.0, 25.0, 50.0, 100.0, 250.0].map((a) {
                    final isSelected = (_amount - a).abs() < 1;
                    return GestureDetector(
                      onTap: () => setState(() => _amount = a),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? MoltColors.purplePinkGradient : null,
                          color: isSelected ? null : MoltColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? null
                              : Border.all(color: MoltColors.purple.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '\$${a.toInt()}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : MoltColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment methods
          _SectionCard(
            title: '💳 Payment Method',
            child: Column(
              children: [
                // USDC (Solana)
                _PaymentMethodCard(
                  name: 'USDC on Solana',
                  icon: '🪙',
                  subtitle: 'Fast & low fees • 2.5% platform fee',
                  description: 'Connect your Solana wallet (Phantom, Solflare) to pay with USDC stablecoin.',
                  isSelected: _selectedMethod == 'usdc',
                  color: const Color(0xFF9945FF),
                  onTap: () => setState(() => _selectedMethod = 'usdc'),
                  child: _selectedMethod == 'usdc'
                      ? Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: MoltColors.darker,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Wallet Address', style: TextStyle(color: MoltColors.textMuted, fontSize: 11)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _walletController,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    decoration: const InputDecoration(
                                      hintText: 'Connect wallet or paste address...',
                                      hintStyle: TextStyle(color: MoltColors.textMuted, fontSize: 12),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: GradientButton(
                                      label: '🔌 Connect Phantom Wallet',
                                      onPressed: () {
                                        setState(() {
                                          _walletController.text = 'Phantom wallet connection coming soon...';
                                        });
                                      },
                                      height: 40,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF9945FF), Color(0xFF14F195)],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
                const SizedBox(height: 10),

                // Apple Pay
                _PaymentMethodCard(
                  name: 'Apple Pay',
                  icon: '🍎',
                  subtitle: 'Quick checkout • Standard fees',
                  description: 'Pay instantly with Apple Pay using your saved cards.',
                  isSelected: _selectedMethod == 'apple_pay',
                  color: Colors.white,
                  onTap: () => setState(() => _selectedMethod = 'apple_pay'),
                ),
                const SizedBox(height: 10),

                // Stripe
                _PaymentMethodCard(
                  name: 'Stripe',
                  icon: '💳',
                  subtitle: 'Credit/Debit card • Secure checkout',
                  description: 'Pay with any major credit or debit card via Stripe secure checkout.',
                  isSelected: _selectedMethod == 'stripe',
                  color: const Color(0xFF635BFF),
                  onTap: () => setState(() => _selectedMethod = 'stripe'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          _SectionCard(
            title: '📋 Summary',
            child: Column(
              children: [
                _SummaryRow('Amount', '\$${_amount.toStringAsFixed(2)}'),
                _SummaryRow('Platform Fee (2.5%)', '\$${(_amount * 0.025).toStringAsFixed(2)}'),
                const Divider(color: MoltColors.surfaceLight),
                _SummaryRow(
                  'Total',
                  '\$${(_amount * 1.025).toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Result message
          if (_resultMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isSuccess
                    ? MoltColors.success.withValues(alpha: 0.1)
                    : MoltColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isSuccess
                      ? MoltColors.success.withValues(alpha: 0.3)
                      : MoltColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _resultMessage!,
                style: TextStyle(
                  color: _isSuccess ? MoltColors.success : MoltColors.error,
                  fontSize: 13,
                ),
              ),
            ),

          // Pay button
          GradientButton(
            label: _isProcessing
                ? 'Processing...'
                : _selectedMethod == 'usdc'
                    ? '🪙 Pay with USDC'
                    : _selectedMethod == 'apple_pay'
                        ? '🍎 Pay with Apple Pay'
                        : '💳 Pay with Stripe',
            icon: _isProcessing ? null : Icons.payment,
            onPressed: _isProcessing ? null : _processPayment,
            isLoading: _isProcessing,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.name,
    required this.icon,
    required this.subtitle,
    required this.description,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.child,
  });

  final String name;
  final String icon;
  final String subtitle;
  final String description;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
                  color.withValues(alpha: 0.15),
                  MoltColors.surface,
                ])
              : null,
          color: isSelected ? null : MoltColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : MoltColors.purple.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected ? Colors.white54 : MoltColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 24)
                else
                  Icon(Icons.radio_button_unchecked, color: MoltColors.textMuted, size: 24),
              ],
            ),
            if (isSelected && child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.isBold = false});
  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : MoltColors.textMuted,
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? MoltColors.purple : Colors.white70,
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: MoltColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MoltColors.purple.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
