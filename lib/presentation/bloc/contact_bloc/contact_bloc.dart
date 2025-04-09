import 'package:bloc/bloc.dart';
import 'package:using_chat_api/data/auth_service.dart';
import 'package:using_chat_api/data/chat_service.dart';
import 'package:using_chat_api/model/contact_model.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final AuthService _authService;
  final ChatService _chatService;

  ContactBloc(this._authService, this._chatService) : super(ContactLoading()) {
    on<FetchContacts>(_onFetchContacts);
  }

  Future<void> _onFetchContacts(
      FetchContacts event, Emitter<ContactState> emit) async {
    try {
      final token = await _authService.loadToken();
      await emit.forEach(
        _chatService.getContactsStream(token!),
        onData: (contacts) => ContactLoaded(contacts),
        onError: (e, _) => ContactError(e.toString()),
      );
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }
}
