import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  intialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'archive.db');

    Database mydb = await openDatabase(path,
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return mydb;
  }

  _onUpgrade(Database db, int oldversion, int newversion) async {
    await db.execute('''
  CREATE TABLE expenses (
    id INTEGER PRIMARY KEY, 
    description TEXT,
    date TEXT,
    amount REAL   
     )
   ''');
    await db.execute('''
  CREATE TABLE backup (
    id INTEGER PRIMARY KEY, 
    token TEXT,
     is_enabled INTEGER,
    date TEXT
    
     )
   ''');
    print("onUpgrade =====================================");
  }

  deleteDP() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'archive.db');
    print(path);
    await deleteDatabase(path);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE user (
    id INTEGER PRIMARY KEY  , 
    name TEXT ,
    center TEXT,
    language TEXT,
    is_dark_mode BOOLEAN
    
     )
   ''');

    await db.execute('''
  CREATE TABLE prices (
    id INTEGER PRIMARY KEY  , 
    exchange REAL 
     )
   ''');

    await db.execute('''
  CREATE TABLE patients (
    id INTEGER PRIMARY KEY  , 
    firstname TEXT ,
    lastname TEXT,
    age TEXT,
    phone_number TEXT,
    pre_ill TEXT,
    pre_surg TEXT,
    notes TEXT,
    date TEXT
     
     )
   ''');

    await db.execute('''
  CREATE TABLE treatments (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    tooth_code INTEGER,
    treatment TEXT,
    sub_treatment TEXT,
    date TEXT,
    cost REAL,
    notes TEXT
     )
   ''');

    await db.execute('''
  CREATE TABLE gum_treatments (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    treatment TEXT,
    date TEXT,
    cost REAL,
    notes TEXT
     )
   ''');

    await db.execute('''
  CREATE TABLE implants (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    tooth_code INTEGER,
    type TEXT,
    details TEXT,
    cost REAL,
    notes TEXT
     )
   ''');

    await db.execute('''
  CREATE TABLE payments (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    title TEXT,
    amount REAL,
    date TEXT   
     )
   ''');

    await db.execute('''
  CREATE TABLE notifications (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    name TEXT,
    title TEXT,
    end_date TEXT,
    isChecked TEXT   
     )
   ''');
    await db.execute('''
  CREATE TABLE expenses (
    id INTEGER PRIMARY KEY, 
    description TEXT,
    date TEXT,
    amount REAL   
     )
   ''');

    await db.execute('''
  CREATE TABLE backup (
    id INTEGER PRIMARY KEY, 
    token TEXT,
    is_enabled INTEGER,
    date TEXT
    
     )
   ''');

    await db.execute('''
  CREATE TABLE treatments_repo (
    id INTEGER PRIMARY KEY, 
    type TEXT,
    sub_types TEXT
     )
   ''');

    await db.execute('''
  CREATE TABLE gum_treatments_repo (
    id INTEGER PRIMARY KEY, 
    type TEXT
     )
   ''');

    await db.execute('''
  CREATE TABLE implants_repo (
    id INTEGER PRIMARY KEY, 
    type TEXT,
    sub_types TEXT
     )
   ''');

    print(" onCreate =====================================");
  }

  readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  insertData(String sql, [List<dynamic>? arguments]) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

// SELECT
// DELETE
// UPDATE
// INSERT
}
