import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//class for database calls
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
        onCreate: _onCreate, version: 2, onUpgrade: _onUpgrade);
    await mydb.execute('PRAGMA foreign_keys = ON');
    return mydb;
  }

  _onUpgrade(Database db, int oldversion, int newversion) async {
    print("onUpgrade =====================================");
  }

  deleteDP() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'archive.db');
    print(path);
    await deleteDatabase(path);
  }

  _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('''
  CREATE TABLE user (
    id INTEGER PRIMARY KEY  , 
    name TEXT ,
    center TEXT,
    language TEXT,
    is_dark_mode BOOLEAN,
    display_mode TEXT
    
     )
   ''');

    await db.execute('''
  CREATE TABLE remote_user (
    id INTEGER PRIMARY KEY  , 
    name TEXT ,
    device TEXT,
    token TEXT
    
     )
   ''');

    await db.execute('''
  CREATE TABLE patients (
    id INTEGER PRIMARY KEY  , 
    firstname TEXT ,
    lastname TEXT,
    normalized_name TEXT,
    age TEXT,
    phone_number TEXT,
    address TEXT,
    medical TEXT,
    surgery TEXT,
    notes TEXT,
    date TEXT
     
     )
   ''');

    await db.execute('''
  CREATE TABLE patient_info (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    n_alive_kids INTEGER,
    n_failed_pr INTEGER,
    n_normal_births INTEGER,
    n_artificial_births INTEGER,
    last_period_date TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE   
     )
   ''');

    await db.execute('''
  CREATE TABLE sessions (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    date TEXT,
    details TEXT,
    pregnancy_id INTEGER,
    FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE   
     )
   ''');

    await db.execute('''
  CREATE TABLE pregnancies (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    start_date TEXT,
    expected_birth_date TEXT,
    status TEXT DEFAULT 'ongoing',
    complete_date TEXT,
    summary TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE   
     )
   ''');

    await db.execute('''
  CREATE TABLE drugs_invoice (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    drugs TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE   
     )
   ''');

    await db.execute('''
  CREATE TABLE notifications (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    name TEXT,
    title TEXT,
    end_date TEXT,
    status TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE   
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
  CREATE TABLE pregnancy_end_status (
    id INTEGER PRIMARY KEY, 
    value TEXT
     )
   ''');

    await db.execute('''
  CREATE TABLE shortcuts (
    id INTEGER PRIMARY KEY,
    category TEXT, 
    value TEXT
     )
   ''');

    await db.execute('''
      CREATE TABLE custom_fields (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        treatment_type_id INTEGER,
        field_name TEXT NOT NULL,
        field_type TEXT NOT NULL, -- e.g., 'text', 'dropdown', 'date'
        field_order INTEGER,
        FOREIGN KEY (treatment_type_id) REFERENCES treatment_types (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE field_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        custom_field_id INTEGER,
        option_value TEXT NOT NULL,
        FOREIGN KEY (custom_field_id) REFERENCES custom_fields (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE implants_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_fields_implants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        implant_type_id INTEGER,
        field_name TEXT NOT NULL,
        field_type TEXT NOT NULL, -- e.g., 'text', 'dropdown', 'date'
        field_order INTEGER,
        FOREIGN KEY (implant_type_id) REFERENCES implants_types (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE field_options_implants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        custom_field_id INTEGER,
        option_value TEXT NOT NULL,
        FOREIGN KEY (custom_field_id) REFERENCES custom_fields_implants (id) ON DELETE CASCADE
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

  add10KEntry() async {
    for (int x = 1; x < 5000; x++) {
      await insertData(
          ''' INSERT INTO patients (firstname,lastname,age,phone_number,date) VALUES ('ahmed','mohammed','25','2546898','20/02/2020')''');
    }
  }

// SELECT
// DELETE
// UPDATE
// INSERT
}
