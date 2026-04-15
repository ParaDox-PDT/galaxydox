abstract final class EpicImageUrlBuilder {
  static const _baseUrl = 'https://epic.gsfc.nasa.gov/archive/natural';

  static String build({required DateTime date, required String imageName}) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$_baseUrl/$year/$month/$day/png/$imageName.png';
  }
}
