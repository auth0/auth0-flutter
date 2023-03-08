class DateUtils {
  static DateTime parseArabicDate(final String arabicDateString) {
    final String englishDateString = arabicDateString.replaceAllMapped(
      RegExp('[٠١٢٣٤٥٦٧٨٩]'),
      (final match) =>
          String.fromCharCode(match.group(0)!.codeUnitAt(0) - 1632 + 48),
    );

    final DateTime date = DateTime.parse(englishDateString);
    return date;
  }
}
