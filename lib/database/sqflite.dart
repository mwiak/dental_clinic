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
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    await mydb.execute('PRAGMA foreign_keys = ON');
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
    medical TEXT,
    surgery TEXT,
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
    details TEXT,
    date TEXT,
    cost REAL,
    notes TEXT
    
     )
   ''');

    await db.execute('''
  CREATE TABLE general_treatments (
    id INTEGER PRIMARY KEY, 
    patient_id INTEGER,
    treatment_type TEXT,
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
    dates TEXT,
    date TEXT,
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
    date TEXT,
    notes TEXT
      
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
  CREATE TABLE general_treatments_types (
    id INTEGER PRIMARY KEY, 
    type TEXT
    
     )
   ''');

    await db.execute('''
      CREATE TABLE treatment_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
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

    await db.insert('treatment_types', {'name': 'Filling'});
    await db.insert(
      'custom_fields',
      {
        'field_name': 'Filling Material',
        'field_type': 'dropdown',
        'treatment_type_id': '1',
      },
    );
    await db.insert(
      'field_options',
      {
        'option_value': 'Metal',
        'custom_field_id': '1',
      },
    );

    await db.insert(
      'field_options',
      {
        'option_value': 'Zircon',
        'custom_field_id': '1',
      },
    );

    await db.insert(
      'field_options',
      {
        'option_value': 'Khazaf',
        'custom_field_id': '1',
      },
    );
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
