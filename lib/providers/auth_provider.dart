



class AuthProvider {
  
  bool _isAuthenticated = false;
  
   bool get isAuthenticated => _isAuthenticated;

  void notifyListeners() {
    // This would normally notify listeners in a ChangeNotifier
  }

  Future<void> login(String email, String password) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));

    // Here you would normally handle authentication logic
    _isAuthenticated = true;
    notifyListeners();
    }

  Future<void> logout() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));

    // Here you would normally handle logout logic
    _isAuthenticated = false;
    notifyListeners();
  }


}