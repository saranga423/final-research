class Helpers {
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String formatDate(DateTime date) {
    final y = date.year;
    final m = _twoDigits(date.month);
    final d = _twoDigits(date.day);
    final hh = _twoDigits(date.hour);
    final mm = _twoDigits(date.minute);
    final ss = _twoDigits(date.second);
    return '$y-$m-$d $hh:$mm:$ss';
  }

  static double clampValue(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
