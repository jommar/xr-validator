apiUrl({String url, String params = ''}) {
  final authKey = 'cfd7CqlQF4kAr42Z4FAitavfQSx0Tbd5';
  final urlString = 'https://apps.uerm.edu.ph:3443/$url?auth=$authKey$params';
  // final urlString = 'http://10.107.4.220:3000/$url?auth=$authKey$params';
  return urlString;
}
