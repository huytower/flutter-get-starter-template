import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class ExpandedCollapseCardWidget extends StatefulWidget {
  const ExpandedCollapseCardWidget({
    Key? key,
    required this.title,
    required this.child,
    this.backgroundColor = CcBaseColors.white100,
    this.shadowColor,
    this.isExpanded = false,
  }) : super(key: key);

  final String title;
  final Widget child;
  final Color backgroundColor;
  final Color? shadowColor;
  final bool isExpanded;

  @override
  _ExpandedCollapseCardWidgetState createState() =>
      _ExpandedCollapseCardWidgetState();
}

class _ExpandedCollapseCardWidgetState
    extends State<ExpandedCollapseCardWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: context.respPadding(12.0)),
    decoration: BoxDecoration(
      color: widget.backgroundColor,
      borderRadius: CcWidgetHelper.getBorderRoundedLG(),
      boxShadow: [
        BoxShadow(
          color: (widget.shadowColor ?? context.ccColorScheme.outlineVariant)
              .withOpacity(0.5),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.all(context.respPadding(16.0)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: context.respFontSize(16.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const CcSpaceXS(),
          Padding(
            padding: EdgeInsets.all(context.respPadding(16.0)),
            child: widget.child,
          ),
        ],
      ],
    ),
  );
}
