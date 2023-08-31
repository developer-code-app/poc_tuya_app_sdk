import 'package:bloc/bloc.dart';

class UIBlockingCubit extends Cubit<bool> {
  UIBlockingCubit() : super(false);

  void block() => emit(true);
  void unblock() => emit(false);
}
