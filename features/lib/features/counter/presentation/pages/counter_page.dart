import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../bloc/counter_bloc.dart';
import '../widgets/counter_action_button.dart';

@RoutePage()
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CounterBloc>()..add(const LoadCounterEvent()),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: CcText(el.tr(CcLocaleKeys.home_title))),
      body: const CcColCenter(
        children: [
          CounterDisplay(),
          CcSpaceSM(),
          CcRowCenter(
            children: [DecrementButton(), CcSpaceSM(), IncrementButton()],
          ),
        ],
      ),
    );
  }
}

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return switch (state) {
          CounterLoading() => const CircularProgressIndicator(),
          CounterLoaded(counter: var counter) => CcText(
            '${counter.value}',
            fontSize: CcTypographyParams.headlineLarge,
            color: context.ccColorScheme.primary,
          ),
          CounterError(message: var message) => CcText(
            '${el.tr(CcLocaleKeys.app_error_general)}: $message',
          ),
          _ => CcText(el.tr(CcLocaleKeys.home_welcome)),
        };
      },
    );
  }
}

class IncrementButton extends StatelessWidget {
  const IncrementButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CounterActionButton(
      onTap: () {
        context.read<CounterBloc>().add(const IncrementCounterEvent());
      },
      icon: Icons.add_circle_outline,
      color: context.ccColorScheme.primary,
    );
  }
}

class DecrementButton extends StatelessWidget {
  const DecrementButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CounterActionButton(
      onTap: () {
        context.read<CounterBloc>().add(const DecrementCounterEvent());
      },
      icon: Icons.remove_circle_outline,
      color: context.ccColorScheme.error,
    );
  }
}
