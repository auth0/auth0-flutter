import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyAccountCard extends StatefulWidget {
  final Auth0 auth0;
  final String domain;
  final String? scheme;
  final void Function(String output) onOutput;

  const MyAccountCard({
    required this.auth0,
    required this.domain,
    required this.onOutput,
    this.scheme,
    final Key? key,
  }) : super(key: key);

  @override
  State<MyAccountCard> createState() => _MyAccountCardState();
}

class _MyAccountCardState extends State<MyAccountCard> {
  String? _accessToken;
  MyAccountApi? _myAccount;
  bool _isExpanded = false;
  bool _useDPoP = false;

  final _phoneController = TextEditingController(text: '+1234567890');
  final _emailController = TextEditingController(text: 'test@example.com');

  String? _lastEnrollmentId;
  String? _lastAuthSession;
  String? _lastFactorType;

  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _log(final String message) {
    debugPrint('[MyAccount] $message');
    widget.onOutput(message);
  }

  Future<void> _loginForMyAccount() async {
    try {
      _log('Logging in with audience: '
          'https://${widget.domain}/me/ ...');

      final webAuth = widget.auth0.webAuthentication(
        scheme: widget.scheme,
      );
      final result = await webAuth.login(
        audience: 'https://${widget.domain}/me/',
        scopes: {
          'openid',
          'profile',
          'email',
          'offline_access',
          'read:me:authentication_methods',
          'create:me:authentication_methods',
          'update:me:authentication_methods',
          'delete:me:authentication_methods',
          'read:me:enrollments',
          'read:me:factors',
        },
      );

      setState(() {
        _accessToken = result.accessToken;
        _myAccount = widget.auth0
            .myAccount(accessToken: _accessToken!, useDPoP: _useDPoP);
      });

      _log('Login successful!\n'
          'Access Token: ${_accessToken!.substring(0, 30)}...\n'
          'Scopes obtained. Ready for My Account API calls.');
    } catch (e) {
      _log('Login Error: $e');
    }
  }

  Future<void> _getAuthMethods() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      _log('Calling getAuthenticationMethods()...');
      final methods = await _myAccount!.getAuthenticationMethods();
      if (methods.isEmpty) {
        _log('No authentication methods enrolled.');
        return;
      }
      final output = StringBuffer(
          'Authentication Methods (${methods.length}):\n');
      for (final m in methods) {
        output.writeln('---');
        output.writeln('  ID: ${m.id}');
        output.writeln('  Type: ${m.type}');
        if (m.name != null) output.writeln('  Name: ${m.name}');
        if (m.phoneNumber != null) output.writeln('  Phone: ${m.phoneNumber}');
        if (m.email != null) output.writeln('  Email: ${m.email}');
        if (m.createdAt != null) output.writeln('  Created: ${m.createdAt}');
        if (m.lastAuthAt != null) {
          output.writeln('  Last Auth: ${m.lastAuthAt}');
        }
      }
      _log(output.toString());
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _getFactors() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      _log('Calling getFactors()...');
      final factors = await _myAccount!.getFactors();
      if (factors.isEmpty) {
        _log('No factors available.');
        return;
      }
      final output = StringBuffer('Available Factors (${factors.length}):\n');
      for (final f in factors) {
        output.writeln('  - ${f.type}: usage=${f.usage?.join(", ") ?? "none"}');
      }
      _log(output.toString());
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _enrollPhone() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      final phone = _phoneController.text.trim();
      _log('Calling enrollPhone(phone: $phone, type: sms)...');
      final challenge = await _myAccount!.enrollPhone(
        phoneNumber: phone,
        type: PhoneType.sms,
      );
      setState(() {
        _lastEnrollmentId = challenge.id;
        _lastAuthSession = challenge.authSession;
        _lastFactorType = 'phone';
      });
      _log('Enrollment Challenge:\n'
          '  ID: ${challenge.id}\n'
          '  Auth Session: ${challenge.authSession}\n'
          '  Recovery Code: ${challenge.recoveryCode ?? "N/A"}\n'
          '\n** Enter OTP received via SMS and tap Verify OTP **');
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _enrollEmail() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      final email = _emailController.text.trim();
      _log('Calling enrollEmail(email: $email)...');
      final challenge = await _myAccount!.enrollEmail(email: email);
      _log('Enrollment SUCCESS - '
          'ID: ${challenge.id} | '
          'AuthSession: ${challenge.authSession}');
      setState(() {
        _lastEnrollmentId = challenge.id;
        _lastAuthSession = challenge.authSession;
        _lastFactorType = 'email';
      });
      _log('** Enter OTP received via Email and tap Verify OTP **');
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _enrollTotp() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      _log('Calling enrollTotp()...');
      final challenge = await _myAccount!.enrollTotp();
      setState(() {
        _lastEnrollmentId = challenge.id;
        _lastAuthSession = challenge.authSession;
        _lastFactorType = 'totp';
      });
      _log('TOTP Enrollment Challenge:\n'
          '  ID: ${challenge.id}\n'
          '  Auth Session: ${challenge.authSession}\n'
          '  TOTP Secret: ${challenge.totpSecret ?? "N/A"}\n'
          '  TOTP URI: ${challenge.totpUri ?? "N/A"}\n'
          '  Barcode URI: ${challenge.barcodeUri ?? "N/A"}\n'
          '  Recovery Code: ${challenge.recoveryCode ?? "N/A"}\n'
          '\n** Add secret to authenticator app, enter code, '
          'tap Verify OTP **');
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _enrollPush() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      _log('Calling enrollPush()...');
      final challenge = await _myAccount!.enrollPush();
      setState(() {
        _lastEnrollmentId = challenge.id;
        _lastAuthSession = challenge.authSession;
        _lastFactorType = 'push-notification';
      });
      _log('Push Enrollment Challenge:\n'
          '  ID: ${challenge.id}\n'
          '  Auth Session: ${challenge.authSession}\n'
          '  Barcode URI: ${challenge.barcodeUri ?? "N/A"}\n'
          '  Recovery Code: ${challenge.recoveryCode ?? "N/A"}');
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _enrollRecoveryCode() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      _log('Calling enrollRecoveryCode()...');
      final challenge = await _myAccount!.enrollRecoveryCode();
      setState(() {
        _lastEnrollmentId = challenge.id;
        _lastAuthSession = challenge.authSession;
        _lastFactorType = 'recovery-code';
      });
      _log('Recovery Code Enrollment:\n'
          '  ID: ${challenge.id}\n'
          '  Auth Session: ${challenge.authSession}\n'
          '  Recovery Code: ${challenge.recoveryCode ?? "N/A"}');
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _verifyOtp() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    if (_lastEnrollmentId == null || _lastAuthSession == null) {
      _log('Error: No pending enrollment. Enroll a factor first.');
      return;
    }
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _log('Error: Enter OTP code.');
      return;
    }
    try {
      _log('Calling verifyOtp(\n'
          '  id: $_lastEnrollmentId,\n'
          '  authSession: $_lastAuthSession,\n'
          '  otp: $otp)...');
      final method = await _myAccount!.verifyOtp(
        id: _lastEnrollmentId!,
        authSession: _lastAuthSession!,
        otp: otp,
        factorType: _lastFactorType!,
      );
      _log('OTP Verified Successfully! Enrollment complete.\n'
          '  Method: ${method.type} (id: ${method.id})');
      setState(() {
        _lastEnrollmentId = null;
        _lastAuthSession = null;
        _lastFactorType = null;
        _otpController.clear();
      });
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _confirmEnrollment() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    if (_lastEnrollmentId == null || _lastAuthSession == null) {
      _log('Error: No pending enrollment. Enroll push/recovery first.');
      return;
    }
    try {
      _log('Calling confirmEnrollment(\n'
          '  id: $_lastEnrollmentId,\n'
          '  authSession: $_lastAuthSession)...');
      final method = await _myAccount!.confirmEnrollment(
        id: _lastEnrollmentId!,
        authSession: _lastAuthSession!,
        factorType: _lastFactorType!,
      );
      _log('Enrollment confirmed!\n'
          '  Method: ${method.type} (id: ${method.id})');
      setState(() {
        _lastEnrollmentId = null;
        _lastAuthSession = null;
        _lastFactorType = null;
      });
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _updateLastMethod() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      _log('Fetching methods to update the last one...');
      final methods = await _myAccount!.getAuthenticationMethods();
      if (methods.isEmpty) {
        _log('No methods to update.');
        return;
      }
      final target = methods.last;
      const newName = 'Updated by example app';
      _log('Updating method ${target.id} (${target.type}) '
          'with name "$newName"...');
      final updated = await _myAccount!.updateAuthenticationMethod(
        id: target.id,
        name: newName,
      );
      _log('Updated successfully: ${updated.id} '
          '(name: ${updated.name ?? "N/A"})');
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  Future<void> _logout() async {
    try {
      _log('Logging out...');
      final webAuth = widget.auth0.webAuthentication(
        scheme: widget.scheme,
      );
      await webAuth.logout();
      setState(() {
        _accessToken = null;
        _myAccount = null;
        _lastEnrollmentId = null;
        _lastAuthSession = null;
        _otpController.clear();
      });
      _log('Logged out successfully.');
    } catch (e) {
      _log('Logout Error: $e');
    }
  }

  Future<void> _deleteLastMethod() async {
    if (_myAccount == null) {
      _log('Error: Not logged in. Login first.');
      return;
    }
    try {
      _log('Fetching methods to delete the last one...');
      final methods = await _myAccount!.getAuthenticationMethods();
      if (methods.isEmpty) {
        _log('No methods to delete.');
        return;
      }
      final target = methods.last;
      _log('Deleting method: ${target.id} (${target.type})...');
      await _myAccount!.deleteAuthenticationMethod(id: target.id);
      _log('Deleted successfully: ${target.id}');
    } on MyAccountException catch (e) {
      _log('MyAccountException: [${e.statusCode}] ${e.code} - ${e.message}');
    } catch (e) {
      _log('Error: $e');
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'My Account API (MFA)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const Spacer(),
                  if (_accessToken != null)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const Divider(),
              if (_accessToken == null) ...[
                const Text(
                  'Login with My Account audience to get started:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Use DPoP',
                      style: TextStyle(fontSize: 13)),
                  subtitle: const Text(
                    'Secure requests with sender-constrained tokens',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  value: _useDPoP,
                  onChanged: (final value) =>
                      setState(() => _useDPoP = value),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _loginForMyAccount,
                  icon: const Icon(Icons.login),
                  label: const Text('Login for My Account'),
                ),
              ] else ...[
                const Text(
                  'Read Operations',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildButton('Get Auth Methods', _getAuthMethods,
                        Icons.list),
                    _buildButton(
                        'Get Factors', _getFactors, Icons.security),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enroll',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSmallButton('Enroll', _enrollPhone),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSmallButton('Enroll', _enrollEmail),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildButton('Enroll TOTP', _enrollTotp,
                        Icons.qr_code),
                    _buildButton('Enroll Push', _enrollPush,
                        Icons.notifications),
                    _buildButton('Enroll Recovery', _enrollRecoveryCode,
                        Icons.restore),
                  ],
                ),
                if (_lastEnrollmentId != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Verify Enrollment',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _otpController,
                          decoration: const InputDecoration(
                            labelText: 'OTP Code',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _verifyOtp,
                        child: const Text('Verify OTP'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'For push / recovery code (no OTP):',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  _buildButton('Confirm Enrollment', _confirmEnrollment,
                      Icons.check, color: Colors.green),
                ],
                const SizedBox(height: 12),
                const Text(
                  'Manage',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _buildButton('Update Last Method', _updateLastMethod,
                    Icons.edit, color: Colors.teal),
                const SizedBox(height: 12),
                const Text(
                  'Delete',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _buildButton('Delete Last Method', _deleteLastMethod,
                    Icons.delete, color: Colors.red),
                const SizedBox(height: 12),
                const Text(
                  'Session',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _buildButton('Logout', _logout,
                    Icons.logout, color: Colors.orange),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      final String label, final VoidCallback onPressed, final IconData icon,
      {final Color color = Colors.indigo}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildSmallButton(final String label, final VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
