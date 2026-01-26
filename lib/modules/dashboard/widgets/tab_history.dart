import 'package:flutter/cupertino.dart';

class TabHistoryManager {
  final List<int> _history = [];
  int _currentPosition = -1;

  // Initialize with the starting tab
  void initialize(int index) {
    _history.clear();
    _history.add(index);
    _currentPosition = 0;
  }

  // Get current tab without navigating
  int? getCurrentTab() {
    if (_currentPosition >= 0 && _currentPosition < _history.length) {
      return _history[_currentPosition];
    }
    return null;
  }

  // Called when navigating to a new tab (user interaction)
  // Only clears forward history when isNewNavigation is true
  void navigate(int fromIndex, int toIndex, {bool isNewNavigation = true}) {
    // Only clear forward history for new user navigations
    // Don't clear when navigating via back/forward buttons
    if (isNewNavigation && _currentPosition < _history.length - 1) {
      _history.removeRange(_currentPosition + 1, _history.length);
    }

    // Add the new tab to history only if it's a new navigation
    if (isNewNavigation) {
      _history.add(toIndex);
      _currentPosition++;
    }
    printHistory();
  }

  // Go back in history
  int? goBack() {
    if (_currentPosition > 0) {
      _currentPosition--;
      printHistory();
      final position = _history[_currentPosition];
      return position;
    }
    return null;
  }

  // Go forward in history
  int? goForward() {
    if (_currentPosition < _history.length - 1) {
      _currentPosition++;
      printHistory();
      return _history[_currentPosition];
    }
    return null;
  }

  bool get canGoBack => _currentPosition > 0;
  bool get canGoForward => _currentPosition < _history.length - 1;
  bool get hasHistory => _currentPosition > 0;

  // Debug helper
  void printHistory() {
    debugPrint('History: $_history');
    debugPrint('Current position: $_currentPosition');
    if (_currentPosition >= 0 && _currentPosition < _history.length) {
      debugPrint('Current tab: ${_history[_currentPosition]}');
    }
  }
}
