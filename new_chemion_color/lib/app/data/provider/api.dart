import 'package:get/get_connect/connect.dart';

const apiUrl = 'http://localhost:4000';

class MyApi extends GetConnect {
  // getFeeds() async {
  //   final response = await get('$apiUrl/feed');
  //   if (response.hasError) {
  //     return AppError(message: '서버 오류가 발생하였습니다.');
  //   } else {
  //     return feedFromJson(response.body);
  //   }
  // }
}
