abstract class Entity {
  int id;

  Map<String, Object> toMap();

  void fromMap(Map<String, Object> map);

  @override
  bool operator ==(other) => id == other.id;
}
