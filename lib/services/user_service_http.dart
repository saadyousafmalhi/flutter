import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import '../models/user.dart';
import 'user_service.dart';

class UserServiceHttp extends BaseService implements UserService {
  UserServiceHttp({http.Client? client}) : super(client: client);

  @override
  Future<List<User>> fetchUsers() async {
    debugPrint('HTTP CALL → UserServiceHttp.fetchUsers()');
    final res = await client
        .get(url('/users'))
        .timeout(const Duration(seconds: 12));
    throwOnError(res);
    final data = decodeJson<List>(res);
    return data.map((e) => User.fromJson(e)).toList();
  }
}
