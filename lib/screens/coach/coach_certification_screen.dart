import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';

class CoachCertificationScreen extends StatefulWidget {
  const CoachCertificationScreen({super.key});

  @override
  State<CoachCertificationScreen> createState() =>
      _CoachCertificationScreenState();
}

class _CoachCertificationScreenState
    extends State<CoachCertificationScreen> {
  int _step = 0;
  bool _submitting = false;

  final _nameController = TextEditingController();
  final _academyController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'Head Coach';
  String _selectedExperience = '6+ Years';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Prefill identity from the logged-in coach profile.
    try {
      final me = await SportyQoApi.me();
      if (!mounted) return;
      setState(() {
        _nameController.text = me['fullName'] as String? ?? '';
        _academyController.text = me['academy'] as String? ?? '';
        _mobileController.text = me['phone'] as String? ?? '';
        _emailController.text = me['email'] as String? ?? '';
        if (me['title'] is String && _roles.contains(me['title'])) {
          _selectedRole = me['title'] as String;
        }
        if (me['isVerifiedCoach'] == true) _step = 7; // already verified
      });
    } catch (_) {}
    // If a request already exists, jump straight to its real status.
    if (_step == 7) return;
    try {
      final certs = await SportyQoApi.coachCertifications();
      if (!mounted || certs.isEmpty) return;
      final latest = certs.first as Map<String, dynamic>;
      final status = (latest['status'] as String?)?.toUpperCase();
      setState(() {
        if (status == 'APPROVED') {
          _step = 7;
        } else if (status == 'PENDING') {
          _step = 6;
        }
      });
    } catch (_) {}
  }

  Future<void> _submitRequest() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ApiClient.instance.postMultipart('/coach/certifications', fields: {
        'title': '$_selectedRole Certification',
        'issuer': _academyController.text.trim(),
      });
      if (!mounted) return;
      setState(() => _step = 4);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  final List<String> _roles = [
    'Head Coach',
    'Assistant Coach',
    'Junior Coach',
    'Batting Coach',
    'Bowling Coach',
    'Fitness Coach',
  ];

  final List<String> _experiences = [
    '0-1 Years',
    '1-3 Years',
    '3-5 Years',
    '5-8 Years',
    '6+ Years',
    '10+ Years',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(child: _buildStep()),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildWhyGetCertified();
      case 1: return _buildBasicDetails();
      case 2: return _buildUploadDocuments();
      case 3: return _buildReviewProfile();
      case 4: return _buildRequestSubmitted();
      case 5: return _buildStatus(0);
      case 6: return _buildStatus(1);
      case 7: return _buildStatus(2);
      default: return _buildWhyGetCertified();
    }
  }

  // ── Step 0: Why Get Certified ──
  Widget _buildWhyGetCertified() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text('Get Certified',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 20),
            ]),
          ),
          const SizedBox(height: 28),

          // Shield icon
          Stack(alignment: Alignment.center, children: [
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF1A6BFF).withOpacity(0.2), Colors.transparent]),
              ),
            ),
            Container(
              width: 95, height: 95,
              decoration: BoxDecoration(
                color: const Color(0xFF1A6BFF).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A6BFF).withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.shield, color: Color(0xFF1A6BFF), size: 52),
            ),
            Positioned(
              bottom: 8, right: 8,
              child: Container(
                width: 30, height: 30,
                decoration: const BoxDecoration(color: Color(0xFF1A6BFF), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ),
          ]),

          const SizedBox(height: 20),
          const Text('Become a\nSportyQo Certified Coach',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.3)),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
                'Get verified and unlock exclusive opportunities to grow your coaching journey with SportyQo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Why Get Certified?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 16),
                  _BenefitTile(icon: Icons.shield_outlined, color: const Color(0xFF1A6BFF), title: 'Verified Coach Badge', subtitle: 'Stand out with a trusted badge on your profile.'),
                  _BenefitTile(icon: Icons.people_outline, color: const Color(0xFF00C853), title: 'Recommend Players', subtitle: 'Recommend talented players and help them shine.'),
                  _BenefitTile(icon: Icons.emoji_events_outlined, color: Colors.amber, title: 'Join Top Leagues', subtitle: 'Get access to top leagues across your state and country.'),
                  _BenefitTile(icon: Icons.network_check, color: AppColors.primary, title: 'Stand Out on the Network', subtitle: 'Increase your visibility and connect with top players, academies & scouts.'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _step = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Request Certification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Our team will review your details and\nget back to you within 24-48 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Step 1: Basic Details ──
  Widget _buildBasicDetails() {
    return Column(
      children: [
        _Header(title: 'Coach Certification', onBack: () => setState(() => _step = 0)),
        _Steps(current: 0),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Basic Details', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Please provide your basic information\nto get started.', style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                  child: Column(children: [
                    _Field(label: 'Full Name', controller: _nameController, hint: 'Enter full name'),
                    const SizedBox(height: 14),
                    _Field(label: 'Academy / Club', controller: _academyController, hint: 'Enter academy or club name'),
                    const SizedBox(height: 14),
                    _Dropdown(label: 'Role', value: _selectedRole, items: _roles, hint: 'Select your role', onChanged: (v) => setState(() => _selectedRole = v!)),
                    const SizedBox(height: 14),
                    _Dropdown(label: 'Coaching Experience', value: _selectedExperience, items: _experiences, hint: 'Select experience', onChanged: (v) => setState(() => _selectedExperience = v!)),
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mobile Number', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10)),
                            child: Row(children: const [
                              Text('+91', style: TextStyle(color: Colors.white, fontSize: 14)),
                              SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
                            ]),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Enter mobile number',
                                hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Field(label: 'Email Address', controller: _emailController, hint: 'Enter email address', keyboardType: TextInputType.emailAddress),
                  ]),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _Btn(label: 'Continue', onTap: () => setState(() => _step = 2)),
      ],
    );
  }

  // ── Step 2: Upload Documents ──
  Widget _buildUploadDocuments() {
    return Column(
      children: [
        _Header(title: 'Coach Certification', onBack: () => setState(() => _step = 1)),
        _Steps(current: 1),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upload Documents', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Upload your certificates and academy\nID to verify your credentials.', style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
                const SizedBox(height: 20),
                _UploadCard(title: 'Coaching Certificate', subtitle: 'Upload certificate'),
                const SizedBox(height: 14),
                _UploadCard(title: 'Academy ID / Document', subtitle: 'Upload academy ID or any official document'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1A6BFF).withOpacity(0.2)),
                  ),
                  child: Row(children: const [
                    Icon(Icons.security, color: Color(0xFF1A6BFF), size: 16),
                    SizedBox(width: 10),
                    Expanded(child: Text('Your documents are safe and\nsecure with SportyQo.', style: TextStyle(color: Color(0xFF1A6BFF), fontSize: 12, height: 1.4))),
                  ]),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _Btn(label: 'Continue', onTap: () => setState(() => _step = 3)),
      ],
    );
  }

  // ── Step 3: Review Profile ──
  Widget _buildReviewProfile() {
    return Column(
      children: [
        _Header(title: 'Coach Certification', onBack: () => setState(() => _step = 2)),
        _Steps(current: 2),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Review Your Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Please review your details before\nsubmitting your request.', style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Basic Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      GestureDetector(onTap: () => setState(() => _step = 1), child: const Text('Edit', style: TextStyle(color: Color(0xFF1A6BFF), fontSize: 13, fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 12),
                    _RRow('Full Name', _nameController.text),
                    const Divider(color: Colors.white10, height: 16),
                    _RRow('Academy / Club', _academyController.text),
                    const Divider(color: Colors.white10, height: 16),
                    _RRow('Role', _selectedRole),
                    const Divider(color: Colors.white10, height: 16),
                    _RRow('Coaching Experience', _selectedExperience),
                    const Divider(color: Colors.white10, height: 16),
                    _RRow('Mobile Number', '+91 ${_mobileController.text}'),
                    const Divider(color: Colors.white10, height: 16),
                    _RRow('Email Address', _emailController.text),
                  ]),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Documents', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      GestureDetector(onTap: () => setState(() => _step = 2), child: const Text('Edit', style: TextStyle(color: Color(0xFF1A6BFF), fontSize: 13, fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 12),
                    _DocRow('Coaching Certificate', 'Certificate.pdf'),
                    const SizedBox(height: 8),
                    _DocRow('Academy ID / Document', 'Academy_ID.pdf'),
                  ]),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6BFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Text('By submitting, you agree to our terms and verification process.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 11)),
        ),
      ],
    );
  }

  // ── Step 4: Request Submitted ──
  Widget _buildRequestSubmitted() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _Header(title: 'Coach Certification', onBack: () => setState(() => _step = 3)),
          const SizedBox(height: 32),

          Stack(alignment: Alignment.center, children: [
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF00C853).withOpacity(0.25), Colors.transparent]),
              ),
            ),
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00C853), width: 3),
                color: const Color(0xFF00C853).withOpacity(0.1),
              ),
              child: const Icon(Icons.check, color: Color(0xFF00C853), size: 52),
            ),
          ]),

          const SizedBox(height: 24),
          const Text('Request Submitted!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text('Thank you for applying. Our team will review your details and get back to you within 24-48 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What Happens Next?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 16),
                  _NextTile(icon: Icons.check_circle, color: const Color(0xFF1A6BFF), title: 'Request Received', subtitle: 'We have received your application.', isDone: true),
                  _NextTile(icon: Icons.check_circle, color: const Color(0xFF1A6BFF), title: 'Under Review', subtitle: 'Our team is verifying your details and documents.', isDone: true),
                  _NextTile(icon: Icons.radio_button_unchecked, color: Colors.white24, title: 'Verified', subtitle: 'Once approved, you will get your Verified Coach badge.', isDone: false, isLast: true),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Status Screens (Request Received / Under Review / Verified) ──
  Widget _buildStatus(int level) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => setState(() => _step = level == 0 ? 4 : level + 4),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text('Certification Status', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 20),
            ]),
          ),

          const SizedBox(height: 28),

          // ── Status Icon ──
          _StatusIcon(level: level),

          const SizedBox(height: 20),

          Text(
            level == 0 ? 'Request Received' : level == 1 ? 'Under Review' : 'You\'re a Verified Coach!',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              level == 0
                  ? 'We have received your certification request successfully.'
                  : level == 1
                  ? 'Our team is reviewing your details and documents.'
                  : 'Congratulations! You are now a SportyQo Certified Coach.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
            ),
          ),

          const SizedBox(height: 24),

          // ── Application Card ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
              child: Column(children: [
                const Align(alignment: Alignment.centerLeft, child: Text('Your Application', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
                const SizedBox(height: 12),
                Row(children: [
                  const SizedBox(width: 80, child: Text('Name', style: TextStyle(color: Colors.white38, fontSize: 12))),
                  Expanded(child: Text(_nameController.text.isEmpty ? '—' : _nameController.text, style: const TextStyle(color: Colors.white, fontSize: 13))),
                  if (level == 2) const Icon(Icons.check_circle, color: Color(0xFF1A6BFF), size: 18),
                ]),
                const Divider(color: Colors.white10, height: 16),
                _RRow('Academy', _academyController.text.isEmpty ? '—' : _academyController.text),
                const Divider(color: Colors.white10, height: 16),
                _RRow('Role', _selectedRole),
                const Divider(color: Colors.white10, height: 16),
                _RRow('Status', level == 2 ? 'Verified' : level == 1 ? 'Under Review' : 'Received'),
              ]),
            ),
          ),

          const SizedBox(height: 14),

          // ── Status Timeline ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 12),
                  _Timeline(title: 'Request Received', date: 'Done', state: 'done', isLast: false),
                  _Timeline(
                    title: 'Under Review',
                    date: level >= 1 ? (level == 1 ? 'In Progress' : 'Done') : '',
                    state: level >= 2 ? 'done' : level == 1 ? 'active' : 'pending',
                    isLast: false,
                  ),
                  _Timeline(
                    title: 'Verified',
                    date: level >= 2 ? 'Done' : '',
                    state: level >= 2 ? 'done' : 'pending',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Info Banner ──
          if (level == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1A6BFF).withOpacity(0.3)),
                ),
                child: Row(children: const [
                  Icon(Icons.notifications_outlined, color: Color(0xFF1A6BFF), size: 16),
                  SizedBox(width: 10),
                  Expanded(child: Text('You will be notified via email and app once there is an update.', style: TextStyle(color: Color(0xFF1A6BFF), fontSize: 12, height: 1.4))),
                ]),
              ),
            ),

          if (level == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(children: const [
                  Icon(Icons.access_time, color: Colors.amber, size: 16),
                  SizedBox(width: 10),
                  Expanded(child: Text('This usually takes 24-48 hours.\nThank you for your patience.', style: TextStyle(color: Colors.amber, fontSize: 12, height: 1.4))),
                ]),
              ),
            ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  level == 2 ? 'Go to Profile' : 'Go to Home',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Status Icon Widget ────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final int level;
  const _StatusIcon({required this.level});

  @override
  Widget build(BuildContext context) {
    if (level == 0) {
      // Blue clipboard with check badge
      return Stack(alignment: Alignment.center, children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF1A6BFF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.assignment, color: Color(0xFF1A6BFF), size: 56),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(color: Color(0xFF1A6BFF), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
        ),
      ]);
    } else if (level == 1) {
      // Amber/orange clipboard with search badge
      return Stack(alignment: Alignment.center, children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.assignment, color: Colors.amber, size: 56),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
            child: const Icon(Icons.search, color: Colors.black, size: 16),
          ),
        ),
      ]);
    } else {
      // Blue shield with laurels and check for verified
      return Stack(alignment: Alignment.center, children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [const Color(0xFF1A6BFF).withOpacity(0.25), Colors.transparent]),
          ),
        ),
        Container(
          width: 95, height: 95,
          decoration: BoxDecoration(
            color: const Color(0xFF1A6BFF).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1A6BFF).withOpacity(0.5), width: 2),
          ),
          child: const Icon(Icons.shield, color: Color(0xFF1A6BFF), size: 52),
        ),
        const Positioned(
          child: Icon(Icons.check, color: Color(0xFF1A6BFF), size: 28),
        ),
      ]);
    }
  }
}

// ── Timeline Widget ───────────────────────────────────────────────────

class _Timeline extends StatelessWidget {
  final String title, date, state;
  final bool isLast;
  const _Timeline({required this.title, required this.date, required this.state, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDone = state == 'done';
    final isActive = state == 'active';

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? const Color(0xFF00C853)
                : isActive
                ? Colors.amber
                : Colors.white12,
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 13)
              : isActive
              ? const Icon(Icons.circle, color: Colors.amber, size: 8)
              : null,
        ),
        if (!isLast) Container(width: 1, height: 36, color: Colors.white10),
      ]),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: isDone || isActive ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              if (date.isNotEmpty)
                Text(date,
                    style: TextStyle(
                        color: isActive
                            ? Colors.amber
                            : isDone
                            ? const Color(0xFF00C853)
                            : Colors.white38,
                        fontSize: 11)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ]);
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        GestureDetector(onTap: onBack, child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20)),
        const SizedBox(width: 16),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _Steps extends StatelessWidget {
  final int current;
  const _Steps({required this.current});

  @override
  Widget build(BuildContext context) {
    const labels = ['Basic Details', 'Documents', 'Review', 'Submit'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: List.generate(4, (i) {
          final isDone = i < current;
          final isActive = i == current;
          return Expanded(
            child: Row(children: [
              Column(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone || isActive ? const Color(0xFF1A6BFF) : Colors.white12,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : Text('${i + 1}', style: TextStyle(color: isDone || isActive ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(labels[i], style: TextStyle(color: isDone || isActive ? Colors.white : Colors.white38, fontSize: 9)),
              ]),
              if (i < 3)
                Expanded(child: Container(height: 1, color: i < current ? const Color(0xFF1A6BFF) : Colors.white12, margin: const EdgeInsets.only(bottom: 16))),
            ]),
          );
        }),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  const _Field({required this.label, required this.hint, required this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label, value, hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown({required this.label, required this.value, required this.items, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A6BFF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title, subtitle;
  const _UploadCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A6BFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(color: Color(0xFF1A6BFF), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            )),
          ]),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(children: const [
              Icon(Icons.cloud_upload_outlined, color: Color(0xFF1A6BFF), size: 32),
              SizedBox(height: 8),
              Text.rich(TextSpan(children: [
                TextSpan(text: 'Tap to upload or ', style: TextStyle(color: Colors.white38, fontSize: 12)),
                TextSpan(text: 'browse', style: TextStyle(color: Color(0xFF1A6BFF), fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
              Text('(JPG, PNG, PDF - Max 5MB)', style: TextStyle(color: Colors.white24, fontSize: 11)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _BenefitTile({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.4)),
          ],
        )),
      ]),
    );
  }
}

class _RRow extends StatelessWidget {
  final String label, value;
  const _RRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
    ]);
  }
}

class _DocRow extends StatelessWidget {
  final String title, file;
  const _DocRow(this.title, this.file);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.description_outlined, color: Colors.white38, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(file, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      )),
      const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 18),
    ]);
  }
}

class _NextTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final bool isDone, isLast;
  const _NextTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.isDone, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? color : Colors.white12),
          child: Icon(icon, color: isDone ? Colors.white : Colors.white38, size: 14),
        ),
        if (!isLast) Container(width: 1, height: 44, color: Colors.white10),
      ]),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: isDone ? Colors.white : Colors.white38, fontWeight: FontWeight.w600, fontSize: 13)),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.4)),
          const SizedBox(height: 16),
        ]),
      )),
    ]);
  }
}