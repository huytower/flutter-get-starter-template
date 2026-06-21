import 'package:cc_sdk_ui/core/config/tokens/cc_typography_params.dart';
import 'package:cc_sdk_ui/widgets/flex/cc_flex.dart';
import 'package:cc_sdk_ui/widgets/space/cc_space.dart';
import 'package:cc_sdk_ui/widgets/state/base_progress_indicator.dart';
import 'package:cc_sdk_ui/widgets/text/cc_text.dart';
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

/// A reusable [LoadMoreDelegate] implementation for the cc_mixin package.
///
/// This class isolates the load-more presentation logic from the mixin, keeping
/// the mixin focused on construction and configuration.
class CcLoadMoreItem extends LoadMoreDelegate {
  const CcLoadMoreItem();

  @override
  Widget buildChild(
    LoadMoreStatus status, {
    LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english,
  }) {
    final text = builder(status);

    switch (status) {
      case LoadMoreStatus.fail:
        return _buildText(text, color: PrjColors.error);
      case LoadMoreStatus.idle:
        return _buildText(text, color: PrjColors.warning);
      case LoadMoreStatus.loading:
        return _buildLoading(text);
      case LoadMoreStatus.nomore:
        return _buildText(text);
      case LoadMoreStatus.outScreen:
        throw UnimplementedError();
    }
  }

  Widget _buildLoading(String text) {
    return CcRowCenter(
      children: <Widget>[
        const Center(child: CcProgressIndicator(paddingTop: 0)),
        const CcSpaceLG(),
        _buildText(text),
      ],
    );
  }

  CcText _buildText(
    String text, {
    Color? color,
    TextAlign? textAlign,
    Alignment? align,
  }) {
    return CcText(
      text,
      fontSize: CcTypographyParams.bodyLarge,
      color: color ?? PrjColors.mediumEmphasis,
      textAlign: textAlign ?? TextAlign.center,
      align: align ?? Alignment.center,
    );
  }
}
