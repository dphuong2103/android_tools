import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // Use this to get a valid directory path

class TableName {
  static final String devices = "devices";
  static final String batches = "batches";
  static final String deviceBatches = "device_batch";
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Database? _db; // Use nullable Database

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!; // Check for initialization

    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;

    // Set database path manually
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDocDir.path, 'app_database.db');

    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${TableName.devices}(
              ip TEXT PRIMARY KEY
            )
          ''');

          await db.execute('''
          CREATE TABLE IF NOT EXISTS ${TableName.batches}(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
          ''');

          await db.execute('''
          CREATE TABLE IF NOT EXISTS ${TableName.deviceBatches}(
            batch_id TEXT NOT NULL,
            device_serial_number TEXT NOT NULL,
            PRIMARY KEY (batch_id, device_serial_number),
            FOREIGN KEY (batch_id) REFERENCES ${TableName.batches}(id) ON DELETE CASCADE
          )
          ''');
          },
      ),
    );

    return _db!;
  }

  // Close the database safely
  Future<void> closeDb() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null; // Reset the database instance
    }
  }
}
