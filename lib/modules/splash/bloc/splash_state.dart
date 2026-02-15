part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

final class SplashInitial extends SplashState {}

sealed class SplashActionState extends SplashState {}

final class NavigateToHomeActionState extends SplashActionState {}
