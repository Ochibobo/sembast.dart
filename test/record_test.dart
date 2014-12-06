library tekartik_iodb.record_test;

// basically same as the io runner but with extra output
import 'package:tekartik_test/test_config_io.dart';
import 'package:tekartik_iodb/database.dart';
import 'package:tekartik_io_tools/platform_utils.dart';
import 'package:path/path.dart';


void main() {
  useVMConfiguration();
  defineTests();
}

void defineTests() {


  String dbPath = join(scriptDirPath, "tmp", "test.db");

  group('record', () {
    Database db;

    setUp(() {
      db = new Database();
      return Database.deleteDatabase(dbPath).then((_) {
        return db.open(dbPath, 1);
      });
    });

    tearDown(() {
      db.close();
    });

    test('put/get', () {
      Store store = db.mainStore;
      Record record = new Record(store, "hi", 1);
      return store.putRecord(record).then((Record record) {
        expect(record.key, 1);
        expect(record.value, "hi");
        expect(record.deleted, false);
        expect(record.store, store);
      }).then((_) {
        return store.getRecord(1).then((Record record) {
          expect(record.key, 1);
          expect(record.value, "hi");
          expect(record.deleted, false);
          expect(record.store, store);
        });
      });
    });
  });

  group('find', () {
    Database db;
    Store store;
    Record record1, record2, record3;
    setUp(() {
      db = new Database();
      return Database.deleteDatabase(dbPath).then((_) {
        return db.open(dbPath, 1);
      }).then((_) {
        store = db.mainStore;
        record1 = new Record(store, "hi", 1);
        record2 = new Record(store, "ho", 2);
        record3 = new Record(store, "ha", 3);
        return store.putRecords([record1, record2, record3]);
      });
    });

    tearDown(() {
      db.close();
    });

    test('equal', () {
      Finder finder = new Finder();
      finder.filter = new Filter.equal(Field.VALUE, "hi");
      return store.findRecords(finder).then((List<Record> records) {
        expect(records.length, 1);
        expect(records[0], record1);
      }).then((_) {
        Finder finder = new Finder();
        finder.filter = new Filter.equal(Field.VALUE, "ho");
        return store.findRecords(finder).then((List<Record> records) {
          expect(records.length, 1);
          expect(records[0], record2);
        });
      }).then((_) {
        Finder finder = new Finder();
        finder.filter = new Filter.equal(Field.VALUE, "hum");
        return store.findRecords(finder).then((List<Record> records) {
          expect(records.length, 0);
        });
      });
    });



    test('less_greater', () {
      Finder finder = new Finder();
      finder.filter = new Filter.lessThan(Field.VALUE, "hi");
      return store.findRecords(finder).then((List<Record> records) {
        expect(records.length, 1);
        expect(records[0], record3);
      }).then((_) {
        Finder finder = new Finder();
        finder.filter = new Filter.greaterThan(Field.VALUE, "hi");
        return store.findRecords(finder).then((List<Record> records) {
          expect(records.length, 1);
          expect(records[0], record2);
        });
      }).then((_) {
        Finder finder = new Finder();
        finder.filter = new Filter.greaterThan(Field.VALUE, "hum");
        return store.findRecords(finder).then((List<Record> records) {
          expect(records.length, 0);
        });

      }).then((_) {
        Finder finder = new Finder();
        finder.filter = new Filter.greaterThanOrEquals(Field.VALUE, "ho");
        return store.findRecords(finder).then((List<Record> records) {
          expect(records.length, 1);
          expect(records[0], record2);
        });
      }).then((_) {
        Finder finder = new Finder();
        finder.filter = new Filter.lessThanOrEquals(Field.VALUE, "ha");
        return store.findRecords(finder).then((List<Record> records) {
          expect(records.length, 1);
          expect(records[0], record3);
        });
      }).then((_) {
        Finder finder = new Finder();
        finder.filter = new Filter.inList(Field.VALUE, ["ho"]);
        return store.findRecords(finder).then((List<Record> records) {
          expect(records.length, 1);
          expect(records[0], record2);
        });
      });
    });

    test('composite', () {
      Finder finder = new Finder();
      finder.filter = new Filter.and([new Filter.lessThan(Field.VALUE, "ho"), new Filter.greaterThan(Field.VALUE, "ha")]);
      return store.findRecords(finder).then((List<Record> records) {
        expect(records.length, 1);
        expect(records[0], record1);
      }).then((_) {
        Finder finder = new Finder();
        finder.filter = new Filter.or([new Filter.lessThan(Field.VALUE, "hi"), new Filter.greaterThan(Field.VALUE, "hum")]);
        return store.findRecords(finder).then((List<Record> records) {
          expect(records.length, 1);
          expect(records[0], record3);
        });
      });
    });
  });
}
