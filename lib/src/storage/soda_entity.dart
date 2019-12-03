mixin SodaEntity {
  int id;

  Map<String, Object> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SodaEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
