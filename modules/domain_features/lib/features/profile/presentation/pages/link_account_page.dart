import 'dart:async';

import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/auth/domain/phone_auth_status.dart';
import 'package:cc_micro_features/features/auth/domain/repositories/firebase_auth_repository.dart';
import 'package:cc_micro_features/features/auth/presentation/pages/widgets/phone_otp_input.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';

/// Lets a user signed in with one Firebase provider (phone or Google) also
/// link the other, so either can be used to log in afterward. Reads current
/// link state from `CcUserEntity.linkedProviderIds` (`User.providerData`
/// under the hood) — the only reliable signal, since `email`/`phoneNumber`
/// alone don't reveal which provider set them.
class LinkAccountPage extends StatefulWidget {
  const LinkAccountPage({super.key});

  @override
  State<LinkAccountPage> createState() => _LinkAccountPageState();
}

class _LinkAccountPageState extends State<LinkAccountPage> {
  List<String> _linkedProviderIds = const [];
  bool _isLinkingGoogle = false;
  bool _isLinkingPhone = false;
  bool _phoneCodeSent = false;
  String? _verificationId;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  StreamSubscription<PhoneAuthStatus>? _phoneAuthSubscription;

  bool get _isGoogleLinked => _linkedProviderIds.contains('google.com');
  bool get _isPhoneLinked => _linkedProviderIds.contains('phone');

  @override
  void initState() {
    super.initState();
    _linkedProviderIds =
        getIt<SessionContract>().currentUser?.linkedProviderIds ?? const [];
  }

  @override
  void dispose() {
    _phoneAuthSubscription?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _linkGoogle() async {
    setState(() => _isLinkingGoogle = true);
    final result = await getIt<FirebaseAuthRepository>().linkWithGoogle();
    if (!mounted) return;
    setState(() => _isLinkingGoogle = false);
    result.when(
      (user) {
        setState(() => _linkedProviderIds = user.linkedProviderIds);
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.profile_link_account_success),
        );
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: error.message,
      ),
    );
  }

  void _sendPhoneCode() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() => _isLinkingPhone = true);

    // Cancel any still-live listener from a prior tap so a stale callback
    // can't race with this one and overwrite _verificationId with an
    // outdated value.
    _phoneAuthSubscription?.cancel();
    _phoneAuthSubscription = getIt<FirebaseAuthRepository>()
        .verifyPhoneNumberForLinking(phoneNumber: phone)
        .listen((status) {
          if (!mounted) return;
          switch (status) {
            case PhoneAuthStatusCodeSent(:final verificationId):
              setState(() {
                _verificationId = verificationId;
                _phoneCodeSent = true;
                _isLinkingPhone = false;
              });
            case PhoneAuthStatusCompleted(:final user):
              setState(() {
                _linkedProviderIds = user.linkedProviderIds;
                _isLinkingPhone = false;
                _phoneCodeSent = false;
              });
              CcSnackBarHelper.showSuccessSnackBar(
                context: context,
                message: el.tr(CcLocaleKeys.profile_link_account_success),
              );
            case PhoneAuthStatusFailed(:final failure):
              setState(() => _isLinkingPhone = false);
              CcSnackBarHelper.showErrorSnackBar(
                context: context,
                message: failure.message,
              );
            case PhoneAuthStatusAutoRetrievalTimeout():
            case PhoneAuthStatusStarted():
              break;
          }
        });
  }

  Future<void> _verifyPhoneCode(String code) async {
    final verificationId = _verificationId;
    if (verificationId == null) return;
    setState(() => _isLinkingPhone = true);
    final result = await getIt<FirebaseAuthRepository>().linkWithPhoneNumber(
      verificationId: verificationId,
      smsCode: code,
    );
    if (!mounted) return;
    setState(() => _isLinkingPhone = false);
    result.when(
      (user) {
        setState(() {
          _linkedProviderIds = user.linkedProviderIds;
          _phoneCodeSent = false;
        });
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.profile_link_account_success),
        );
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: error.message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CcText(el.tr(CcLocaleKeys.profile_link_account_title)),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.PAGE_MD),
          ),
          children: [
            CcText(
              el.tr(CcLocaleKeys.profile_link_account_subtitle),
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ),
            const CcSpaceLG(),
            _buildGoogleRow(context),
            const CcSpaceMD(),
            _buildPhoneSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleRow(BuildContext context) {
    return _buildProviderCard(
      context,
      icon: Icons.g_mobiledata_rounded,
      label: el.tr(CcLocaleKeys.profile_link_account_google),
      isLinked: _isGoogleLinked,
      trailing: _isGoogleLinked
          ? null
          : _isLinkingGoogle
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: _linkGoogle,
              child: CcText(el.tr(CcLocaleKeys.profile_link_account_action)),
            ),
    );
  }

  Widget _buildPhoneSection(BuildContext context) {
    return _buildProviderCard(
      context,
      icon: Icons.phone_android_rounded,
      label: el.tr(CcLocaleKeys.profile_link_account_phone),
      isLinked: _isPhoneLinked,
      trailing: null,
      child: _isPhoneLinked
          ? null
          : Padding(
              padding: EdgeInsets.only(
                top: context.respPadding(CcPaddingParams.SPACE_SM),
              ),
              child: _phoneCodeSent
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PhoneOtpInput(
                          controller: _otpController,
                          onCompleted: _verifyPhoneCode,
                        ),
                        const CcSpaceSM(),
                        if (_isLinkingPhone)
                          const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: () =>
                                _verifyPhoneCode(_otpController.text),
                            child: CcText(
                              el.tr(
                                CcLocaleKeys.profile_link_account_verify_code,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: el.tr(
                                CcLocaleKeys.profile_link_account_phone_hint,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const CcSpaceXS(),
                        _isLinkingPhone
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : TextButton(
                                onPressed: _sendPhoneCode,
                                child: CcText(
                                  el.tr(
                                    CcLocaleKeys.profile_link_account_send_code,
                                  ),
                                ),
                              ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildProviderCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isLinked,
    Widget? trailing,
    Widget? child,
  }) {
    return Container(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.ccColorScheme.primary),
              const CcSpaceSM(),
              Expanded(
                child: CcText(
                  label,
                  textStyle: context.ccTextTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isLinked)
                CcText(
                  el.tr(CcLocaleKeys.profile_link_account_linked),
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: context.ccColorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                ?trailing,
            ],
          ),
          ?child,
        ],
      ),
    );
  }
}
