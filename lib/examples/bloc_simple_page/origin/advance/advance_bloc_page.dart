import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/di/di.dart';
import 'advance_bloc.dart';
import 'advance_bloc_state.dart';
import 'widgets/advance_counter_item.dart';

@RoutePage()
class AdvanceBlocPage extends StatelessWidget {
  const AdvanceBlocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FadePageWrapper(
      child: BlocProvider(
        create: (BuildContext context) => getIt<AdvanceBloc>(),
        child: Builder(builder: (context) => buildPage(context)),
      ),
    );
  }

  Widget buildPage(BuildContext context) {
    return buildContainer(context);
  }

  Widget buildContainer(BuildContext context) {
    final bloc = getIt<AdvanceBloc>();
    return CcColCenter(
      children: [
        buildTitle(context),
        const CcSpaceSM(),
        AdvanceCounterItem(bloc: bloc),
        const CcSpaceSM(),
        AdvanceCounterItem(bloc: bloc),
      ],
    );
  }

  /// Build the title based on bloc type
  SizedBox buildTitle(BuildContext context) {
    Widget child = ccWhen(
      variable: getIt<AdvanceBloc>().blocType,
      conditions: {
        BlocType.builder: () => buildBlocBuilder(context),
        BlocType.selector: () => buildBlocSelector(context),
        BlocType.listener: () => buildBlocListener(context),
        BlocType.consumer: () => buildBlocConsumer(context),
      },
    );

    return SizedBox(
      width: double.infinity,
      child: Center(child: child),
    );
  }

  Widget buildBlocBuilder(BuildContext context) {
    return BlocBuilder<AdvanceBloc, AdvanceBlocState>(
      builder: (context, state) {
        return buildBlocUI(context, context.ccColorScheme.primary);
      },
    );
  }

  Widget buildBlocSelector(BuildContext context) {
    return BlocSelector<AdvanceBloc, AdvanceBlocState, AdvanceBlocStateB>(
      selector: (state) => AdvanceBlocStateB(),
      builder: (context, state) {
        return buildBlocUI(context, context.ccColorScheme.secondary);
      },
    );
  }

  Widget buildBlocListener(BuildContext context) {
    return BlocListener<AdvanceBloc, AdvanceBlocState>(
      listener: (context, state) {},
      child: buildBlocUI(context, context.ccColorScheme.tertiary),
    );
  }

  Widget buildBlocConsumer(BuildContext context) {
    return BlocConsumer<AdvanceBloc, AdvanceBlocState>(
      listener: (context, state) {},
      builder: (context, state) {
        return buildBlocUI(context, context.ccColorScheme.error);
      },
    );
  }

  /// Build bloc UI with theme colors
  CcText buildBlocUI(BuildContext context, Color color) {
    return CcText(
      getIt<AdvanceBloc>().counter.toString(),
      textStyle: context.ccTextTheme.headlineLarge?.copyWith(color: color),
    );
  }
}
