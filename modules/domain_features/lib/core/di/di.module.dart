// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:domain_features/features/examples/bloc_simple_page/cubit/simple/simple_cubit.dart'
    as _i691;
import 'package:domain_features/features/examples/bloc_simple_page/cubit/simple/simple_cubit_interface.dart'
    as _i402;
import 'package:domain_features/features/examples/bloc_simple_page/origin/advance/advance_bloc.dart'
    as _i1004;
import 'package:injectable/injectable.dart' as _i526;

class DomainFeaturesPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i1004.AdvanceBloc>(
      () => _i1004.AdvanceBloc(),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i402.SimpleCubitInterface>(
      () => _i691.SimpleCubit(),
      dispose: (i) => i.close(),
    );
  }
}
