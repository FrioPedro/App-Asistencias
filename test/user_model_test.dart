import 'package:app_asistencias/models/user/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserModel fromJson creates valid object', () {
    final user = UserModel.fromJson({
      "documento": "74085467",
      "nombres": "Pedro",
      "apellidos": "Arteta Flores",
      "zone": "Sur",
    });

    expect(user.names, 'Pedro');
    expect(user.lastNames, 'Arteta Flores');
    expect(user.zone, 'Sur');
  });

  test('UserModel fromIngresosJson parses ingresos structure', () {
    final ingresos = [
      {
        "Document": "73218899",
        "Collaborator": "Alexander Iman Yarleque",
        "Letters": "AI",
      },
      {
        "Document": "71265636",
        "Collaborator": "Luis Hernandez",
        "Letters": "LH",
      },
    ];

    final users = ingresos
      .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
  
    expect(users.length, 2);

    expect(users[0].nationalId, "73218899");
    expect(users[0].names, 'Alexander');
    expect(users[0].lastNames, 'Iman Yarleque');
    //expect(users[0].zone, '');

    expect(users[1].nationalId, "71265636");
    expect(users[1].names, 'Luis');
    expect(users[1].lastNames, 'Hernandez');
    //expect(users[1].zone, '');
  
  });
}
