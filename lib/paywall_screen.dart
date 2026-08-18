import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'data/content_dataset.dart';

/// Port of PaywallView.swift. A parental gate guards the purchase, then the
/// one-time unlock is offered. Closes itself as soon as the entitlement lands.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const PaywallScreen(),
      ),
    );
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _gatePassed = false;
  bool _popped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        elevation: 0,
      ),
      body: Consumer<PurchaseProvider>(
        builder: (context, purchase, _) {
          // Dismiss once unlocked, mirroring .onChange(of: store.isUnlocked).
          if (purchase.isUnlocked && !_popped) {
            _popped = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).maybePop();
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _gatePassed
                  ? _PurchaseContent(purchase: purchase)
                  : ParentalGate(
                onSuccess: () => setState(() => _gatePassed = true),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- Purchase

class _PurchaseContent extends StatelessWidget {
  const _PurchaseContent({required this.purchase});

  final PurchaseProvider purchase;

  @override
  Widget build(BuildContext context) {
    // Everything except English is behind the unlock.
    final paid = ContentDataset.languages.where((l) => l.id != 'en').toList();
    final names = paid.take(5).map((l) => l.name).join(', ');
    final more = paid.length - 5;

    return Column(
      children: [
        const Text('🌍', style: TextStyle(fontSize: 70)),
        const SizedBox(height: 12),
        const Text(
          'Unlock All Languages',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Text(
          '$names and $more more — one-time purchase, yours forever. '
              'No subscription.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 28),

        if (purchase.error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              purchase.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade900, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: purchase.isLoading ? null : purchase.purchase,
            child: purchase.isLoading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              // Falls back only if the store hasn't answered yet.
              'Unlock for ${purchase.price ?? '...'}',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Visible when the product never loaded — usually the product isn't
        // active in Play Console yet, or propagation hasn't finished.
        if (purchase.product == null && !purchase.isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              'Store unavailable right now. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),

        TextButton(
          onPressed: purchase.isLoading ? null : purchase.restore,
          child: const Text('Restore Purchases'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text('Not now', style: TextStyle(color: Colors.grey.shade600)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Gate

/// Simple adult verification: answer a multiplication question.
class ParentalGate extends StatefulWidget {
  const ParentalGate({required this.onSuccess, super.key});

  final VoidCallback onSuccess;

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  final _random = Random();
  final _controller = TextEditingController();

  late int _a;
  late int _b;
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _newQuestion() {
    _a = 6 + _random.nextInt(4); // 6...9
    _b = 6 + _random.nextInt(4);
  }

  void _submit() {
    if (int.tryParse(_controller.text.trim()) == _a * _b) {
      widget.onSuccess();
    } else {
      setState(() {
        _wrong = true;
        _controller.clear();
        _newQuestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.escalator_warning, size: 60, color: Colors.blue),
        const SizedBox(height: 14),
        const Text(
          'Ask a Grown-Up',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'To continue, please solve:',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 18),
        Text(
          '$_a × $_b = ?',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: 140,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Answer',
              filled: true,
              fillColor: Colors.grey.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_wrong)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('Try again', style: TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}