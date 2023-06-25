import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_state.freezed.dart';

@freezed
class MainState with _$MainState {
  const factory MainState.loading() = MainStateLoading;

  const factory MainState.loaded({
    required bool isAdRemoved,
    required String chosenLanguage,
    required String localeLanguage,
  }) = MainStateLoaded;
}
