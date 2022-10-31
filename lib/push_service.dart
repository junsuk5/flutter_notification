import 'package:http/http.dart' as http;

class PushService {
  // 싱글턴
  // static final PushService _pushService = PushService._internal();
  //
  // factory PushService() {
  //   return _pushService;
  // }
  //
  // PushService._internal();

   static Future<bool> sendPush(String title, String body) async {
    try {
      var url = Uri.parse(
          'https://us-central1-fir-test-532fb.cloudfunctions.net/sendFcm');
      var response = await http.post(
        url,
        body: {'title': '$title', 'body': '$body'},
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}