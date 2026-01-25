import 'package:flutter_test/flutter_test.dart';
import 'package:wayanusa/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Logic Unit Test', () {
    test('getProfile mengembalikan data user', () async {
      // mock API
      ApiService.getProfile = () async {
        return {
          'name': 'Boyy Logic',
          'email': 'logic@test.com',
          'profile_pic': null,
        };
      };

      final data = await ApiService.getProfile();

      expect(data, isNotNull);
      expect(data!['name'], 'Boyy Logic');
      expect(data['email'], 'logic@test.com');
    });

    test('getProfile null → fallback user', () async {
      ApiService.getProfile = () async => null;

      final data = await ApiService.getProfile();

      expect(data, isNull);
    });
  });
}
