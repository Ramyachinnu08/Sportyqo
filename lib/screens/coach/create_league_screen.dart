import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';
import 'package:flutter/services.dart';
import 'coach_home_screen.dart';

class CreateLeagueScreen extends StatefulWidget {
  const CreateLeagueScreen({super.key});

  @override
  State<CreateLeagueScreen> createState() =>
      _CreateLeagueScreenState();
}

class _CreateLeagueScreenState
    extends State<CreateLeagueScreen> {
  int _step = 0;
  final _nameController = TextEditingController();
  String _selectedLocation = 'Bangalore, Karnataka';
  String _selectedGender = 'Men\'s';
  int _teamsCount = 8;
  String? _selectedLeagueIcon;

  // predefined league icons to pick from
  final List<String> _leagueIcons = [
    '🏆', '⚽', '🏏', '🏀', '🏐', '🎯',
    '🦅', '⚔️', '🔥', '⚡', '🌟', '🛡️',
  ];

  // team icon options per team
  final List<String?> _teamIcons = List.filled(20, null);
  final List<String> _iconOptions = [
    '🦅', '⚽', '🏏', '🏀', '⚔️', '🔥',
    '⚡', '🌟', '🛡️', '🎯', '🏐', '🦁',
    '🐯', '🦊', '🐉', '🌊',
  ];

  final List<TextEditingController> _teamControllers =
      List.generate(8, (_) => TextEditingController());

  final List<String> _locations = [
    'Bangalore, Karnataka',
    'Mumbai, Maharashtra',
    'Delhi, Delhi',
    'Chennai, Tamil Nadu',
    'Hyderabad, Telangana',
    'Kolkata, West Bengal',
    'Pune, Maharashtra',
  ];

  bool _creating = false;
  String? _createdCode;

  Future<void> _createLeague() async {
    final name = _nameController.text.trim();
    final teamNames = <String>[];
    final teamEmojis = <String?>[];
    for (var i = 0; i < _teamsCount && i < _teamControllers.length; i++) {
      final t = _teamControllers[i].text.trim();
      if (t.isNotEmpty) {
        teamNames.add(t);
        teamEmojis.add(_teamIcons[i]);
      }
    }
    String? error;
    if (name.length < 3) {
      error = 'Please enter a league name';
    } else if (teamNames.length < 2) {
      error = 'Add at least 2 team names';
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error), backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _creating = true);
    try {
      // The league uses the coach's sport (set at registration).
      String? sportId;
      try {
        final me = await SportyQoApi.me();
        sportId = (me['sport'] as Map<String, dynamic>?)?['id'] as String?;
      } catch (_) {}
      if (sportId == null) {
        final sports = await SportyQoApi.sports();
        if (sports.isNotEmpty) {
          sportId = (sports.first as Map<String, dynamic>)['id'] as String?;
        }
      }
      if (sportId == null) {
        throw ApiException(0, 'BAD_REQUEST', 'No sport configured');
      }
      final league = await SportyQoApi.createLeague(
        name: name,
        location: _selectedLocation,
        gender: _selectedGender,
        sportId: sportId,
        iconEmoji: _selectedLeagueIcon,
        teams: [
          for (var i = 0; i < teamNames.length; i++)
            {
              'name': teamNames[i],
              if (teamEmojis[i] != null) 'iconEmoji': teamEmojis[i]!,
            }
        ],
      );
      if (!mounted) return;
      setState(() {
        _createdCode = league['leagueCode'] as String?;
        _step = 1;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      final detail = (e.details != null && e.details!.isNotEmpty)
          ? (e.details!.first['message'] ?? e.message)
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$detail'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _showLeagueIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose League Icon',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Pick an icon or upload your own logo',
                style:
                TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _leagueIcons.map((icon) {
                final isSelected = _selectedLeagueIcon == icon;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLeagueIcon = icon);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A6BFF).withOpacity(0.2)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A6BFF)
                              : Colors.white12,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Center(
                        child: Text(icon,
                            style: const TextStyle(fontSize: 28))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery opened! 🖼️'),
                    backgroundColor: Color(0xFF1A6BFF),
                  ),
                );
              },
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6BFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                        const Color(0xFF1A6BFF).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.photo_library,
                      color: Color(0xFF1A6BFF), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Custom Logo',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text('JPG, PNG supported',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    color: Colors.white38),
              ]),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTeamIconPicker(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Icon — ${_teamControllers[index].text.isEmpty ? 'Team ${index + 1}' : _teamControllers[index].text}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('Pick an icon or upload a team logo',
                style:
                TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _iconOptions.map((icon) {
                final isSelected = _teamIcons[index] == icon;
                return GestureDetector(
                  onTap: () {
                    setState(() => _teamIcons[index] = icon);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A6BFF).withOpacity(0.2)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A6BFF)
                              : Colors.white12,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Center(
                        child: Text(icon,
                            style: const TextStyle(fontSize: 26))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery opened! 🖼️'),
                    backgroundColor: Color(0xFF1A6BFF),
                  ),
                );
              },
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6BFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                        const Color(0xFF1A6BFF).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.photo_library,
                      color: Color(0xFF1A6BFF), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Team Logo',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text('JPG, PNG supported',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    color: Colors.white38),
              ]),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: _step == 0 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  // ── STEP 1: League Details ──
  Widget _buildStep1() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            const Text('Create League',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ]),
        ),

        const SizedBox(height: 16),

        _StepIndicator(currentStep: 0),

        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Let\'s build your league',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                    'Fill in the details below to create\nyour league.',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.5)),

                const SizedBox(height: 24),

                // ── League Logo Upload ──
                Center(
                  child: GestureDetector(
                    onTap: _showLeagueIconPicker,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF1A6BFF)
                                        .withOpacity(0.6),
                                    width: 2.5),
                              ),
                              child: Center(
                                child: _selectedLeagueIcon != null
                                    ? Text(_selectedLeagueIcon!,
                                    style: const TextStyle(
                                        fontSize: 44))
                                    : const Icon(Icons.shield_outlined,
                                    color: Colors.white38,
                                    size: 40),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A6BFF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('League Logo',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const Text('Tap to choose icon or upload',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      // League Name
                      _FormField(
                        icon: Icons.shield_outlined,
                        label: 'League Name',
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration:
                          _inputDecoration('Enter league name'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // League Location
                      _FormField(
                        icon: Icons.location_on_outlined,
                        label: 'League Location',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLocation,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1A1A1A),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                              icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white54),
                              items: _locations
                                  .map((l) => DropdownMenuItem(
                                  value: l, child: Text(l)))
                                  .toList(),
                              onChanged: (v) => setState(
                                      () => _selectedLocation = v!),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Gender
                      _FormField(
                        icon: Icons.people_outline,
                        label: 'Gender',
                        child: Row(children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                      () => _selectedGender = 'Men\'s'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'Men\'s'
                                      ? const Color(0xFF1A6BFF)
                                      : Colors.transparent,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text('Men\'s',
                                      style: TextStyle(
                                          color:
                                          _selectedGender == 'Men\'s'
                                              ? Colors.white
                                              : Colors.white54,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                      () => _selectedGender = 'Women\'s'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'Women\'s'
                                      ? const Color(0xFF1A6BFF)
                                      : Colors.transparent,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text('Women\'s',
                                      style: TextStyle(
                                          color: _selectedGender ==
                                              'Women\'s'
                                              ? Colors.white
                                              : Colors.white54,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 16),

                      // Teams Count
                      _FormField(
                        icon: Icons.people_alt_outlined,
                        label: 'Teams Count',
                        child: Row(children: [
                          GestureDetector(
                            onTap: () {
                              if (_teamsCount > 2) {
                                setState(() {
                                  _teamsCount--;
                                  if (_teamControllers.length >
                                      _teamsCount) {
                                    _teamControllers.removeLast();
                                  }
                                });
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                Border.all(color: Colors.white12),
                              ),
                              child: const Icon(Icons.remove,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text('$_teamsCount',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _teamsCount++;
                              _teamControllers
                                  .add(TextEditingController());
                            }),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A6BFF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 16),

                      // Team Names with icons
                      _FormField(
                        icon: Icons.list_alt_outlined,
                        label: 'Team Names',
                        subtitle:
                        'Enter the names of all teams in your league.',
                        child: Column(children: [
                          ...List.generate(
                            _teamControllers.length,
                                (i) => Padding(
                              padding:
                              const EdgeInsets.only(bottom: 10),
                              child: Row(children: [
                                // Team icon button
                                GestureDetector(
                                  onTap: () =>
                                      _showTeamIconPicker(i),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A6BFF)
                                          .withOpacity(0.12),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFF1A6BFF)
                                              .withOpacity(0.35)),
                                    ),
                                    child: Center(
                                      child: _teamIcons[i] != null
                                          ? Text(_teamIcons[i]!,
                                          style: const TextStyle(
                                              fontSize: 20))
                                          : const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: Color(0xFF1A6BFF),
                                          size: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _teamControllers[i],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13),
                                    decoration:
                                    _inputDecoration('Team name'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _teamControllers.removeAt(i);
                                    _teamsCount--;
                                  }),
                                  child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white38,
                                      size: 20),
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(() {
                              _teamControllers
                                  .add(TextEditingController());
                              _teamsCount++;
                            }),
                            child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add,
                                      color: Color(0xFF1A6BFF),
                                      size: 18),
                                  SizedBox(width: 4),
                                  Text('Add Team',
                                      style: TextStyle(
                                          color: Color(0xFF1A6BFF),
                                          fontWeight: FontWeight.w600)),
                                ]),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Continue Button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _creating ? null : _createLeague,
              icon: _creating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 18),
              label: Text(_creating ? 'Creating…' : 'Create League',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6BFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 2: League Created ──
  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => setState(() => _step = 0),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              const Text('Create League',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ]),
          ),

          const SizedBox(height: 16),

          _StepIndicator(currentStep: 1),

          const SizedBox(height: 32),

          // League logo shown in success screen
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF1A6BFF).withOpacity(0.3),
                    Colors.transparent,
                  ]),
                ),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6BFF).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color:
                      const Color(0xFF1A6BFF).withOpacity(0.5),
                      width: 2),
                ),
                child: Center(
                  child: _selectedLeagueIcon != null
                      ? Text(_selectedLeagueIcon!,
                      style: const TextStyle(fontSize: 48))
                      : const Icon(Icons.shield,
                      color: Color(0xFF1A6BFF), size: 50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text('League Created!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
              'Your league has been created successfully.\nShare the code below with players\nto invite them to join.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white54, fontSize: 13, height: 1.6)),

          const SizedBox(height: 28),

          // League Code Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('LEAGUE CODE',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600)),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                              text: _createdCode ?? ''));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Code Copied! 📋'),
                            backgroundColor: Color(0xFF1A6BFF),
                          ));
                        },
                        child: Row(children: const [
                          Icon(Icons.copy_outlined,
                              color: Color(0xFF1A6BFF), size: 16),
                          SizedBox(width: 4),
                          Text('Copy',
                              style: TextStyle(
                                  color: Color(0xFF1A6BFF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ]),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Center(
                    child: Text(_createdCode ?? '——————',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4)),
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(children: const [
                Icon(Icons.info_outline,
                    color: Color(0xFF1A6BFF), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'Players can use this code to join your league in the SportyQo app.',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.5)),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // Share via
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Share via',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Share.share(
                            'Join my league "${_nameController.text.trim()}" on SportyQo! Use code: ${_createdCode ?? ''}'),
                        child: Column(children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366)
                                  .withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                                child: Text('💬',
                                    style: TextStyle(fontSize: 28))),
                          ),
                          const SizedBox(height: 8),
                          const Text('WhatsApp',
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12)),
                        ]),
                      ),
                    ),
                    Container(
                        height: 50, width: 1, color: Colors.white10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Share.share(
                            'Join my league "${_nameController.text.trim()}" on SportyQo! Use code: ${_createdCode ?? ''}'),
                        child: Column(children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A6BFF)
                                  .withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.message_outlined,
                                color: Color(0xFF1A6BFF), size: 28),
                          ),
                          const SizedBox(height: 8),
                          const Text('Text Message',
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CoachHomeScreen()),
                        (route) => false,
                  ),
                  icon: const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 18),
                  label: const Text('View League Dashboard',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _step = 0),
                child: const Text('Create Another League',
                    style: TextStyle(
                        color: Color(0xFF1A6BFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// ── Form Field ────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget child;

  const _FormField({
    required this.icon,
    required this.label,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(icon, color: Colors.white38, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ],
              const SizedBox(height: 6),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep >= 0
                ? const Color(0xFF1A6BFF)
                : Colors.white12,
          ),
          child: Center(
            child: currentStep > 0
                ? const Icon(Icons.check,
                color: Colors.white, size: 14)
                : const Text('1',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 6),
        Text('League Details',
            style: TextStyle(
                color:
                currentStep >= 0 ? Colors.white : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white12,
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep >= 1
                ? const Color(0xFF1A6BFF)
                : Colors.white12,
          ),
          child: Center(
            child: Text('2',
                style: TextStyle(
                    color: currentStep >= 1
                        ? Colors.white
                        : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 6),
        Text('Generate Code',
            style: TextStyle(
                color:
                currentStep >= 1 ? Colors.white : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}