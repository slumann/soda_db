import 'package:dost/dost.dart';

abstract class Repository<T extends Entity> {
  List<T> get entities;

  void put(T entity);

  void putAll(Iterable<T> entities);

  void remove(T entity);

  void removeAll(Iterable<T> entities);

  void clear();
}
