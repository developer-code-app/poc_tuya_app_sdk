class Home {
  Home({
    required this.homeId,
    required this.name,
  });

  factory Home.fromMap(Map map) {
    return Home(
      homeId: map['home_id'].toString(),
      name: map['name'],
    );
  }

  final String homeId;
  final String name;
}
