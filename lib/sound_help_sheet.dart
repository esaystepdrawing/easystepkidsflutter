import 'package:flutter/material.dart';

/// Reusable sound help bottom sheet.
/// Import this file wherever SoundHelpSheet is needed.
class SoundHelpSheet extends StatelessWidget {
  const SoundHelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Sound Help',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _section(
              icon: Icons.check_circle,
              color: Colors.green,
              title: 'Check these first',
              children: [
                _row(Icons.notifications_off, Colors.orange,
                    'Silent switch',
                    'Flip the physical switch on the side of your phone.'),
                _row(Icons.volume_up, Colors.blue, 'Volume up',
                    'Press the volume up button while the app is open.'),
                _row(Icons.touch_app, Colors.purple, 'Tap the speaker',
                    'Tap the blue speaker button inside any tracing screen.'),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              icon: Icons.download,
              color: Colors.blue,
              title: 'Download Indian language voices',
              children: [
                const Text(
                  'Hindi, Telugu, Tamil, Gujarati, Marathi, Urdu, '
                      'Malayalam and Kannada voices may need a one-time download.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 10),
                _step('1', 'Open device Settings'),
                _step('2', 'Tap Accessibility or Language & Input'),
                _step('3', 'Find Text-to-Speech and your language'),
                _step('4', 'Download any available voice'),
                _step('5', 'Come back and tap the speaker button 🔊'),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              icon: Icons.check_circle_outline,
              color: Colors.green,
              title: 'No download needed',
              children: [
                const Text(
                  'English, Spanish, German, French, Portuguese, '
                      'Japanese and Chinese work on all devices.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              icon: Icons.email,
              color: Colors.orange,
              title: 'Still not working?',
              children: [
                const Text(
                  'Email us at support@easystepkids.com',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color)),
            ),
          ]),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, Color color, String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(detail,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}