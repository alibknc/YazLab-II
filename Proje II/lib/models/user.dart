class AppUser {
  final String? userID;
  String? name;
  String? nick;
  bool? admin;
  bool? basvuruDurumu;
  String? konumID;

  AppUser({this.userID,
    this.nick,
    this.name,
    this.basvuruDurumu,
    this.konumID,
    this.admin
  });

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'konumID': konumID,
      'nick': nick ?? "user",
      'name': name ?? "",
      'admin': admin ?? false,
      'basvuruDurumu': basvuruDurumu ?? false
    };
  }

  AppUser.fromMap(var user)
      : userID = user['userID'],
        konumID = user['konumID'],
        nick = user['nick'],
        admin = user['admin'],
        basvuruDurumu = user['basvuruDurumu'],
        name = user['name'];

}
