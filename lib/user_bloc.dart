import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_repository.dart';
import 'user_model.dart';

abstract class UserEvent {}

class FetchUsersEvent extends UserEvent {}

class SearchUsersEvent extends UserEvent {
  final String query;
  SearchUsersEvent(this.query);
}

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  UserLoaded(this.users);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<SearchUsersEvent>(_onSearchUsers);
  }

  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await userRepository.fetchUsersFromApi();
      await userRepository.saveUsersToDatabase(users);
      final savedUsers = await userRepository.getUsersFromDatabase();
      emit(UserLoaded(savedUsers));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(SearchUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await userRepository.getUsersFromDatabase(searchQuery: event.query);
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
