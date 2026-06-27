import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'quick_numeric_keypad.dart';

class ReceiptForm extends StatefulWidget {
  const ReceiptForm({super.key});

  @override
  State<ReceiptForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends State<ReceiptForm> {
  String _amountStr = '0';
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  String _selectedSource = 'BIDV';

  void _onKeyPress(String key) {
    setState(() {
      if (_amountStr == '0') {
        if (key != '0' && key != '000') {
          _amountStr = key;
        }
      } else {
        _amountStr += key;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
  }

  String _formatAmount(String amount) {
    if (amount == '0') return '0';
    final formatter = el.NumberFormat('#,###', 'vi_VN');
    return formatter.format(int.parse(amount));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
              vertical: context.respPadding(CcPaddingParams.PAGE_XS),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(el.tr(CcLocaleKeys.transaction_amount)),
                const CcSpaceXS(),
                _buildAmountField(),
                const CcSpaceLG(),

                _buildLabel(el.tr(CcLocaleKeys.transaction_source_income)),
                const CcSpaceXS(),
                _buildSourceDropdown(),
                const CcSpaceLG(),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(
                            el.tr(CcLocaleKeys.transaction_reason_income),
                          ),
                          const CcSpaceXS(),
                          _buildTextField(
                            _reasonController,
                            el.tr(CcLocaleKeys.transaction_enter_content),
                          ),
                        ],
                      ),
                    ),
                    const CcSpaceMD(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(
                            el.tr(CcLocaleKeys.transaction_recipient),
                          ),
                          const CcSpaceXS(),
                          _buildTextField(
                            _recipientController,
                            el.tr(CcLocaleKeys.transaction_staff_name),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const CcSpaceLG(),

                _buildLabel(el.tr(CcLocaleKeys.transaction_time)),
                const CcSpaceXS(),
                _buildTimeRow(),
                const CcSpaceXL(),

                _buildSubmitButton(),
                const CcSpaceLG(),
              ],
            ),
          ),
        ),
        QuickNumericKeypad(
          onKeyPress: _onKeyPress,
          onDelete: _onDelete,
          onClear: () => setState(() => _amountStr = '0'),
          activeColor: const Color(0xFF13C07F),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return CcText(
      text,
      textStyle: context.ccTextTheme.labelMedium?.copyWith(
        color: Colors.grey[700],
        fontWeight: FontWeight.bold,
        fontSize: context.respFontSize(12),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      alignment: Alignment.centerRight,
      child: CcText(
        _formatAmount(_amountStr),
        textStyle: context.ccTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF13C07F),
          fontSize: context.respFontSize(24),
        ),
      ),
    );
  }

  Widget _buildSourceDropdown() {
    final sources = ['BIDV', 'Cash', 'Momo'];
    final accentColor = const Color(0xFF13C07F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSource,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: context.ccTextTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontSize: context.respFontSize(14),
          ),
          items: [
            ...sources.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 18,
                      color: Color(0xFFE54D42),
                    ),
                    const CcSpaceSM(),
                    CcText(
                      value,
                      textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                        fontSize: context.respFontSize(14),
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }),
            DropdownMenuItem<String>(
              value: 'ADD_NEW',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CcText(
                      el.tr(CcLocaleKeys.common_add_source),
                      textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                        fontSize: context.respFontSize(14),
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) {
            if (value == 'ADD_NEW') {
              // Handle add new logic here
            } else if (value != null) {
              setState(() => _selectedSource = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        style: context.ccTextTheme.bodyMedium?.copyWith(
          fontSize: context.respFontSize(14),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: Colors.grey[400],
            fontSize: context.respFontSize(13),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CcText(
                  '20/05/2026 03:35 CH',
                  textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                    fontSize: context.respFontSize(13),
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_month, size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
        const CcSpaceMD(),
        CcInteractBtnWrapper(
          useDebounce: true,
          isBouncing: true,
          onTap: () {},
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF13C07F).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, color: Color(0xFF13C07F), size: 18),
                const CcSpaceSM(),
                CcText(
                  el.tr(CcLocaleKeys.transaction_history),
                  textStyle: context.ccTextTheme.labelLarge?.copyWith(
                    color: const Color(0xFF13C07F),
                    fontWeight: FontWeight.bold,
                    fontSize: context.respFontSize(13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CcInteractBtnWrapper(
      useDebounce: true,
      isBouncing: true,
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF13C07F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF13C07F).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: CcText(
          el.tr(CcLocaleKeys.transaction_record_income),
          align: Alignment.center,
          textAlign: TextAlign.center,
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontSize: context.respFontSize(15),
          ),
        ),
      ),
    );
  }
}
