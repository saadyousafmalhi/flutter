import 'package:http/http.dart' as http;
import 'base_service.dart';
import '../models/user.dart';

class UserService extends BaseService {
  UserService({http.Client? client}) : super(client: client);

  Future<List<User>> fetchUsers() async {
    final res = await client
        .get(url('/users'))
        .timeout(const Duration(seconds: 12));
    throwOnError(res);
    final data = decodeJson<List>(res);
    return data.map((e) => User.fromJson(e)).toList();
  }
}
