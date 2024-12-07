import 'package:dental_clinic/model/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/sqldb.mock.mocks.dart';

void main() {
  late UserModel sut;
  late MockSqlDb mockSqlDb;

  setUp(() {
    sut = UserModel();
    mockSqlDb = MockSqlDb();
    sut.dataHelper = mockSqlDb;
  });

  test('createNewUser must call insertData with correct query', () async {
    // Arrange
    const name = 'John Doe';
    const center = 'Dental Clinic';
    const language = 'en';
    const isDark = true;

    when(mockSqlDb.insertData(any)).thenAnswer((_) async => 1);

    // Act
    await sut.createNewUser(name, center, language, isDark);

    // Assert
    verify(mockSqlDb.insertData(
            '''INSERT INTO user (name,center,language,is_dark_mode,display_mode) VALUES ('$name', '$center', '$language',$isDark,'compact')'''))
        .called(1);
  });

  test('getUserData must return data', () async {
    const name = 'John Doe';
    const center = 'dental center';
    const language = 'en';
    const isDark = true;
    const displayMode = 'compact';

    when(mockSqlDb.readData(any)).thenAnswer((_) async => [
          {
            'name': name,
            'center': center,
            'language': language,
            'is_dark_mode': isDark,
            'display_mode': displayMode
          }
        ]);

    await sut.getUserData();

    verify(mockSqlDb.readData('''SELECT * FROM user WHERE id = 1 '''))
        .called(1);
  });
}
