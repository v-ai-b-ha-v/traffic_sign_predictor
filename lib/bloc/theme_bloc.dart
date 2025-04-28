import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {

  bool _isDarkMode = false;
  
  ThemeBloc() : super(LightTheme()) {
    on<ToggleTheme>((event, emit) {
      
      _isDarkMode = !_isDarkMode;

      if(_isDarkMode){
        emit(DarkTheme());
      }else{
        emit(LightTheme());
      }

    });
  }
}
