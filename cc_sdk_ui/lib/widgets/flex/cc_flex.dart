import 'package:flutter/widgets.dart';

/// Standard Column with Center alignment
class CcColCenter extends StatelessWidget {
  final List<Widget> children;
  final int? flex;
  final MainAxisSize mainAxisSize;

  const CcColCenter({
    super.key,
    required this.children,
    this.flex,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final col = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: mainAxisSize,
      children: children,
    );
    return flex != null ? Flexible(flex: flex!, child: col) : col;
  }
}

/// Standard Column with Start alignment
class CcColStart extends StatelessWidget {
  final List<Widget> children;
  final int? flex;
  final MainAxisSize mainAxisSize;

  const CcColStart({
    super.key,
    required this.children,
    this.flex,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final col = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: mainAxisSize,
      children: children,
    );
    return flex != null ? Flexible(flex: flex!, child: col) : col;
  }
}

/// Standard Row with Center alignment
class CcRowCenter extends StatelessWidget {
  final List<Widget> children;
  final int? flex;
  final MainAxisSize mainAxisSize;

  const CcRowCenter({
    super.key,
    required this.children,
    this.flex,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: mainAxisSize,
      children: children,
    );
    return flex != null ? Flexible(flex: flex!, child: row) : row;
  }
}

/// Standard Row with Start alignment
class CcRowStart extends StatelessWidget {
  final List<Widget> children;
  final int? flex;
  final MainAxisSize mainAxisSize;

  const CcRowStart({
    super.key,
    required this.children,
    this.flex,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: mainAxisSize,
      children: children,
    );
    return flex != null ? Flexible(flex: flex!, child: row) : row;
  }
}

/// Standard Row with Between alignment
class CcRowBetween extends StatelessWidget {
  final List<Widget> children;
  final int? flex;
  final MainAxisSize mainAxisSize;

  const CcRowBetween({
    super.key,
    required this.children,
    this.flex,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: mainAxisSize,
      children: children,
    );
    return flex != null ? Flexible(flex: flex!, child: row) : row;
  }
}
