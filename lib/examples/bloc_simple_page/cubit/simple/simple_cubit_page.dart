import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/di/di.dart';
import 'simple_cubit.dart';
import 'simple_cubit_interface.dart';
import 'simple_cubit_state.dart';
import 'widgets/simple_counter_item.dart';
import 'widgets/simple_show_track_log_button.dart';

/// CUBIT : UI
/// Step 3 : create UI presentation||page
/// - BlocProvider : init Controller
/// - BlocBuilder : notify data set changed, depends on state
///
@RoutePage()
class SimpleCubitPage extends StatelessWidget {
  const SimpleCubitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ccColorScheme.surface,
      body: SafeArea(
        child: FadePageWrapper(
          child: BlocProvider<SimpleCubitInterface>(
            create: (BuildContext context) => getIt<SimpleCubitInterface>(),
            child: Builder(builder: (context) => buildPage(context)),
          ),
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context) {
    return buildContainer(context);
  }

  Widget buildContainer(BuildContext context) {
    final cubit = context.read<SimpleCubitInterface>();
    return CcColCenter(
      children: [
        buildTitle(context),
        const CcSpaceSM(),
        SimpleCounterItem(cubit: cubit),
        const CcSpaceSM(),
        SimpleCounterItem(cubit: cubit),
        const CcSpaceSM(),
        const SimpleShowTrackLogButton(),
      ],
    );
  }

  /// Build the counter title display
  SizedBox buildTitle(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: BlocBuilder<SimpleCubit, SimpleCubitState>(
          builder: (context, state) {
            return CcText(
              state.counter.toString(),
              textStyle: context.ccTextTheme.headlineLarge?.copyWith(
                color: context.ccColorScheme.error,
              ),
            );
          },
        ),
      ),
    );
  }
}
