import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _gatePassed = false;
  bool _purchasing = false;

  // Parental gate
  late int _a, _b;
  final _answerController = TextEditingController();
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _newQuestion() {
    _a = 6 + DateTime.now().millisecond % 4; // 6-9
    _b = 6 + (DateTime.now().microsecond % 4); // 6-9
    _answerController.clear();
    _wrong = false;
  }

  void _checkGate() {
    final answer = int.tryParse(_answerController.text.trim());
    if (answer == _a * _b) {
      setState(() { _gatePassed = true; _wrong = false; });
    } else {
      setState(() { _wrong = true; _newQuestion(); });
    }
  }

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    try {
      // Wire to in_app_purchase plugin for production
      // For now simulate success after 1 second
      await Future.delayed(const Duration(seconds: 1));
      await context.read<PurchaseProvider>().unlock();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      await context.read<PurchaseProvider>().restore();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F5FF), Color(0xFFEFF8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _gatePassed ? _purchaseContent() : _gateContent(),
          ),
        ),
      ),
    );
  }

  // ── Parental gate ─────────────────────────────────────────────────

  Widget _gateContent() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.family_restroom, size: 64, color: Colors.blue),
        const SizedBox(height: 16),
        const Text('Ask a Grown-Up',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('To continue, please solve:',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Text('$_a × $_b = ?',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        SizedBox(
          width: 140,
          child: TextField(
            controller: _answerController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: '?',
            ),
          ),
        ),
        if (_wrong) ...[
          const SizedBox(height: 8),
          const Text('Try again', style: TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _checkGate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)),
          ),
          child: const Text('Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now'),
        ),
      ],
    );
  }

  // ── Purchase screen ───────────────────────────────────────────────

  Widget _purchaseContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('🌍', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 16),
        const Text('Unlock All Languages',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text(
          'Hindi, Telugu, Tamil, Gujarati, Marathi, Urdu, Malayalam, '
              'Kannada, Spanish, German, French, Portuguese, Japanese and '
              'Chinese — one-time purchase, yours forever. No subscription.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 32),

        // Pricing card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.orange.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Best Value',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(height: 12),
              const Text('All Languages',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('\$1.99',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87)),
              const Text('One-time purchase',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              ...[
                'Everything in Free',
                '14 more languages',
                'Hindi, Telugu, Tamil & more',
                'Japanese, Chinese & more',
                'Yours forever',
              ].map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(f,
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              )),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Buy button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _purchasing ? null : _purchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _purchasing
                ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Text('Unlock for \$1.99',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: _purchasing ? null : _restore,
          child: const Text('Restore Purchases'),
        ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now',
              style: TextStyle(color: Colors.grey)),
        ),

        const SizedBox(height: 16),
        const Text(
          'easystepkids.com',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}