import 'package:dio/dio.dart';

void main() async {
  try {
    final response = await Dio().get('https://ipwho.is/');
    print(response.data);
  } catch(e) {
    print(e);
  }
}
