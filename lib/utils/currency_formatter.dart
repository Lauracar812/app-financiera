/// Utility class para formatear moneda en pesos colombianos
class CurrencyFormatter {
  /// Formatea un valor double a pesos colombianos con separadores de miles
  static String format(double amount) {
    final rounded = amount.round();
    final String amountStr = rounded.toString();

    // Agregar separadores de miles
    String formatted = '';
    int count = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = amountStr[i] + formatted;
      count++;
    }

    return 'COP \$$formatted';
  }

  /// Formatea con signo para transacciones
  static String formatWithSign(double amount, bool isIncome) {
    final sign = isIncome ? '+' : '-';
    return '$sign${format(amount.abs())}';
  }
}
