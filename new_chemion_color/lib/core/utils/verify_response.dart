import 'package:new_chemion_color/app/data/models/models.dart';

verifyresponse(_) {
  if (_.runtimeType == AppError) {
    return true;
  } else {
    return false;
  }
}
