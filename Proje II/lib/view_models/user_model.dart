import 'package:flutter/material.dart';
import 'package:kou_servis/models/user.dart';
import 'package:kou_servis/repository/user_repository.dart';
import 'package:kou_servis/services/auth_base.dart';
import 'package:kou_servis/services/locator.dart';

enum ViewState {IDLE, BUSY}

class UserModel with ChangeNotifier implements AuthBase{

  ViewState _state = ViewState.IDLE;
  UserRepository _userRepository = locator<UserRepository>();
  AppUser? _user;

  UserModel(){
    currentUser();
  }

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  ViewState get state => _state;

  AppUser? get user => _user;

  @override
  Future<AppUser?> currentUser() async{
    try{
      state = ViewState.BUSY;
      _user = await _userRepository.currentUser();
      if (_user != null)
        return _user;
      else
        return null;
    }catch(e){
      debugPrint("$e");
      return null;
    }finally{
      state = ViewState.IDLE;
    }
  }

}
