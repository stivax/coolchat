import 'package:coolchat/account.dart';
import 'package:flutter/material.dart';

class AccountProvider with ChangeNotifier {
  Account _accountCurentState =
      Account(email: '', userName: '', password: '', avatar: '', id: 0);
  bool _isLogin = false;

  AccountProvider() {
    _loadAccount();
  }

  Account get accountProvider => _accountCurentState;
  bool get isLoginProvider => _isLogin;

  Future<void> _loadAccount() async {
    _accountCurentState = await readAccountFromStorage();
    if (_accountCurentState.email.isNotEmpty) {
      _isLogin = true;
    }
    notifyListeners();
  }

  void addAccount(Account account) {
    _accountCurentState = account;
    if (_accountCurentState.email.isNotEmpty) {
      _isLogin = true;
    } else {
      _isLogin = false;
    }
    notifyListeners();
  }

  void clearAccount() {
    _accountCurentState =
        Account(email: '', userName: '', password: '', avatar: '', id: 0);
    if (_accountCurentState.email.isEmpty) {
      _isLogin = false;
    }
    notifyListeners();
  }
}
