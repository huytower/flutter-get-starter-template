import 'package:flutter/widgets.dart';

import '../../core/config/tokens/cc_padding_params.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';

/// Extra Small Space (4pt)
class CcSpaceXS extends StatelessWidget {
  const CcSpaceXS({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: context.respPadding(CcPaddingParams.SPACE_XS),
    width: context.respPadding(CcPaddingParams.SPACE_XS),
  );
}

/// Small Space (8pt)
class CcSpaceSM extends StatelessWidget {
  const CcSpaceSM({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: context.respPadding(CcPaddingParams.SPACE_SM),
    width: context.respPadding(CcPaddingParams.SPACE_SM),
  );
}

/// Medium/Default Space (12pt)
class CcSpaceMD extends StatelessWidget {
  const CcSpaceMD({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: context.respPadding(CcPaddingParams.SPACE_MD),
    width: context.respPadding(CcPaddingParams.SPACE_MD),
  );
}

/// Large Space (16pt)
class CcSpaceLG extends StatelessWidget {
  const CcSpaceLG({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: context.respPadding(CcPaddingParams.SPACE_LG),
    width: context.respPadding(CcPaddingParams.SPACE_LG),
  );
}

/// Extra Large Space (24pt)
class CcSpaceXL extends StatelessWidget {
  const CcSpaceXL({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: context.respPadding(CcPaddingParams.SPACE_XL),
    width: context.respPadding(CcPaddingParams.SPACE_XL),
  );
}

/// Specialized Header Space
class CcSpaceHeader extends StatelessWidget {
  const CcSpaceHeader({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: context.respPadding(CcPaddingParams.SPACE_XL * 2));
}

/// Specialized Footer Space
class CcSpaceFooter extends StatelessWidget {
  const CcSpaceFooter({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: context.respPadding(CcPaddingParams.SPACE_XL * 3));
}
