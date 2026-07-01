import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'access_code_screen.dart';

class VerificationSentScreen extends StatelessWidget {
  const VerificationSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios,
                      color:
                      isDark ? AppColors.textWhite : AppColors.textDark),
                ),
              ),
              const Spacer(),
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send,
                    size: 60, color: Color(0xFF00C853)),
              ),
              const SizedBox(height: 32),
              Text(
                'Verification Request Sent',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We have received your mobile number.\nWe will send you updates on SMS and WhatsApp.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.textGrey, height: 1.6),
              ),
              const SizedBox(height: 32),
              // Updates via
              const Text('Updates via',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _UpdateOption(icon: Icons.sms_outlined, label: 'SMS'),
                  const SizedBox(width: 32),
                  _UpdateOption(
                      icon: Icons.chat_outlined, label: 'WhatsApp'),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AccessCodeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  const _UpdateOption({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00C853), size: 28),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                color: AppColors.textGrey, fontSize: 13)),
      ],
    );
  }
}