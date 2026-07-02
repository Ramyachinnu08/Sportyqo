import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';

class JoinLeagueScreen extends StatefulWidget {
  final Function(String teamName, String leagueName)? onJoined;
  const JoinLeagueScreen({super.key, this.onJoined});

  @override
  State<JoinLeagueScreen> createState() => _JoinLeagueScreenState();
}

class _JoinLeagueScreenState extends State<JoinLeagueScreen> {
  int _step = 0;
  final List<String> _code = ['', '', '', '', '', ''];
  int _activeBox = 0;
  String? _selectedTeam;
  bool _verifying = false;
  String? _joinedLeagueName;

  Future<void> _verifyAndJoin() async {
    setState(() => _verifying = true);
    try {
      final result = await SportyQoApi.joinLeague(_code.join());
      if (!mounted) return;
      _joinedLeagueName =
          (result['league'] as Map<String, dynamic>?)?['name'] as String?;
      setState(() => _step = 1);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code == 'CONFLICT'
            ? 'You have already joined this league'
            : e.message),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  final List<Map<String, dynamic>> _teams = [
    {
      'name': 'Falcons FC',
      'division': 'U16 Division',
      'players': 28,
      'emoji': '🦅',
      'roster': [
        {'name': 'Aarav Mehta', 'position': 'Striker', 'qoScore': 87},
        {'name': 'Rohan Sharma', 'position': 'Midfielder', 'qoScore': 82},
        {'name': 'Vikram Singh', 'position': 'Defender', 'qoScore': 79},
        {'name': 'Karan Patel', 'position': 'Goalkeeper', 'qoScore': 85},
        {'name': 'Dev Kapoor', 'position': 'Winger', 'qoScore': 76},
      ],
    },
    {
      'name': 'Alpha Warriors',
      'division': 'U16 Division',
      'players': 26,
      'emoji': '⚔️',
      'roster': [
        {'name': 'Arjun Reddy', 'position': 'Striker', 'qoScore': 90},
        {'name': 'Sahil Khan', 'position': 'Midfielder', 'qoScore': 84},
        {'name': 'Yash Verma', 'position': 'Defender', 'qoScore': 78},
        {'name': 'Aditya Nair', 'position': 'Goalkeeper', 'qoScore': 81},
      ],
    },
    {
      'name': 'Thunder Strikers',
      'division': 'U16 Division',
      'players': 24,
      'emoji': '⚡',
      'roster': [
        {'name': 'Ishaan Gupta', 'position': 'Striker', 'qoScore': 88},
        {'name': 'Rahul Joshi', 'position': 'Midfielder', 'qoScore': 80},
        {'name': 'Aryan Malhotra', 'position': 'Defender', 'qoScore': 75},
      ],
    },
    {
      'name': 'Green Field United',
      'division': 'U16 Division',
      'players': 30,
      'emoji': '⚽',
      'roster': [
        {'name': 'Pranav Iyer', 'position': 'Striker', 'qoScore': 86},
        {'name': 'Kabir Das', 'position': 'Midfielder', 'qoScore': 83},
        {'name': 'Veer Choudhary', 'position': 'Defender', 'qoScore': 77},
        {'name': 'Aniket Rao', 'position': 'Goalkeeper', 'qoScore': 79},
      ],
    },
  ];

  void _onKeyTap(String val) {
    if (val == '⌫') {
      if (_activeBox > 0) {
        setState(() {
          _activeBox--;
          _code[_activeBox] = '';
        });
      }
      return;
    }
    if (_activeBox < 6) {
      setState(() {
        _code[_activeBox] = val;
        if (_activeBox < 5) _activeBox++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: _step == 0
            ? _buildEnterCode()
            : _step == 1
            ? _buildSelectTeam()
            : _buildSuccess(),
      ),
    );
  }

  // ── STEP 1: Enter League Code ──
  Widget _buildEnterCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                                text: 'Join League',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                            TextSpan(
                                text: '.',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                          'Enter the league code shared\nby your coach or organizer.',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              height: 1.5)),
                    ],
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.primary.withOpacity(0.3),
                      Colors.transparent
                    ]),
                  ),
                  child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 36))),
                ),
              ]),
            ],
          ),
        ),
        const Spacer(),
        Center(
          child: Column(children: [
            const Icon(Icons.grid_view_rounded,
                color: AppColors.primary, size: 32),
            const SizedBox(height: 16),
            const Text('Enter League Code',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
                'Ask your coach or organizer for the\n6-digit league code',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final isFilled = _code[i].isNotEmpty;
                final isActive = _activeBox == i;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 44,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : (isFilled
                          ? AppColors.primary.withOpacity(0.6)
                          : Colors.white12),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _code[i].isNotEmpty ? _code[i] : '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline, color: AppColors.primary, size: 14),
                SizedBox(width: 6),
                Text('Secure & Private',
                    style: TextStyle(color: AppColors.primary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Your league code is safe with us.',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ]),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_code.every((c) => c.isNotEmpty) && !_verifying)
                  ? _verifyAndJoin
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Continue',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ),
        Container(
          color: const Color(0xFF0F0F2A),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(children: [
            _buildKeyRow(['1', '2', '3']),
            const SizedBox(height: 8),
            _buildKeyRow(['4', '5', '6']),
            const SizedBox(height: 8),
            _buildKeyRow(['7', '8', '9']),
            const SizedBox(height: 8),
            _buildKeyRow(['', '0', '⌫']),
          ]),
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      children: keys.map((k) {
        if (k.isEmpty) return const Expanded(child: SizedBox());
        return Expanded(
          child: GestureDetector(
            onTap: () => _onKeyTap(k),
            child: Container(
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A3A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: k == '⌫'
                    ? const Icon(Icons.backspace_outlined,
                    color: Colors.white, size: 20)
                    : Text(k,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── STEP 2: Choose Your Team ──
  Widget _buildSelectTeam() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => setState(() => _step = 0),
            child: const Icon(Icons.arrow_back_ios,
                color: Colors.white, size: 20),
          ),
        ),
      ),
      const SizedBox(height: 12),
      _StepIndicator(currentStep: 1),
      const SizedBox(height: 20),
      const Icon(Icons.people_alt_outlined,
          color: AppColors.primary, size: 36),
      const SizedBox(height: 12),
      const Text('Choose Your Team',
          style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(children: [
          TextSpan(
              text: 'Select the team you want to join in\n',
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          TextSpan(
              text: 'Under16 Pro League.',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F2A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  shape: BoxShape.circle),
              child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('LEAGUE',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 1)),
                Text('Under16 Pro League',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text('Season 2024-25',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: const Text('AVAILABLE TEAMS',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final t = _teams[i];
            final isSelected = _selectedTeam == t['name'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedTeam = t['name'] as String),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.white12,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child: Text(t['emoji'] as String,
                            style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['name'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text(t['division'] as String,
                            style: const TextStyle(
                                color: AppColors.primary, fontSize: 12)),
                        Row(children: [
                          const Icon(Icons.people_outline,
                              color: Colors.white38, size: 13),
                          const SizedBox(width: 4),
                          Text('${t['players']} Players',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                        ]),
                      ],
                    ),
                  ),
                  // ── View Players button ──
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _TeamRosterScreen(
                            teamName: t['name'] as String,
                            emoji: t['emoji'] as String,
                            roster: t['roster'] as List<Map<String, dynamic>>,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.visibility_outlined,
                          color: Colors.white60, size: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white24,
                          width: 2),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 14)
                        : null,
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedTeam == null
                ? null
                : () => setState(() => _step = 2),
            icon: const Icon(Icons.arrow_forward,
                color: Colors.white, size: 18),
            label: const Text('Continue',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_outline, color: Colors.white38, size: 12),
            SizedBox(width: 4),
            Text('Your data is safe and secure with us.',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    ]);
  }

  // ── STEP 3: League Joined! ──
  Widget _buildSuccess() {
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => setState(() => _step = 1),
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Stack(alignment: Alignment.center, children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withOpacity(0.4),
                Colors.transparent
              ]),
            ),
          ),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 48),
          ),
        ]),
        const SizedBox(height: 24),
        const Text('League Joined!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('You have successfully joined the league.',
            style: TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F2A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _teams.firstWhere(
                          (t) => t['name'] == _selectedTeam,
                      orElse: () => {'emoji': '🦅'},
                    )['emoji'] as String,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(_selectedTeam ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('U16 Division',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              Row(children: [
                const Text('🏆', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Under16 Pro League',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text('Season 2024-25',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
              'Your matches, stats and Qo Points\nwill now be tracked.',
              textAlign: TextAlign.center,
              style:
              TextStyle(color: Colors.white38, fontSize: 13, height: 1.5)),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.onJoined != null && _selectedTeam != null) {
                    widget.onJoined!(
                      _selectedTeam!,
                      _joinedLeagueName ?? 'Your League',
                    );
                  }
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 18),
                label: const Text('Go to League',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back Home',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Code Entered', 'Select Team', 'Joined'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (i) {
        final isDone = i < currentStep;
        final isActive = i == currentStep;
        return Row(children: [
          Column(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone || isActive
                    ? AppColors.primary
                    : Colors.white10,
                border: Border.all(
                    color: isDone || isActive
                        ? AppColors.primary
                        : Colors.white24,
                    width: 2),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check,
                    color: Colors.white, size: 16)
                    : Text('${i + 1}',
                    style: TextStyle(
                        color:
                        isActive ? Colors.white : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 4),
            Text(steps[i],
                style: TextStyle(
                    color: isActive ? Colors.white : Colors.white38,
                    fontSize: 10)),
          ]),
          if (i < steps.length - 1)
            Container(
              width: 40,
              height: 2,
              margin: const EdgeInsets.only(bottom: 16),
              color: i < currentStep ? AppColors.primary : Colors.white12,
            ),
        ]);
      }),
    );
  }
}

// ── Team Roster Screen ──────────────────────────────────────────────────

class _TeamRosterScreen extends StatelessWidget {
  final String teamName;
  final String emoji;
  final List<Map<String, dynamic>> roster;

  const _TeamRosterScreen({
    required this.teamName,
    required this.emoji,
    required this.roster,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(teamName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('${roster.length} Players',
                  style:
                  const TextStyle(color: Colors.white38, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: roster.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = roster[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F2A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (p['name'] as String).substring(0, 1),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'] as String,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            Text(p['position'] as String,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Qo ${p['qoScore']}',
                            style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}