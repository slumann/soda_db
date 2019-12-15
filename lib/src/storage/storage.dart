import 'package:soda_db/src/storage/repository.dart';
import 'package:soda_db/src/storage/soda_entity.dart';

typedef EntityFactory<T> = T Function(Map<String, dynamic>);

abstract class Storage {
  Future<void> open(String path);

  void registerEntity<T extends SodaEntity>(
      String repoName, EntityFactory<T> factory);

  Repository<T> getRepository<T extends SodaEntity>(String name);

  Future<void> close();
}
