import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'monity.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        profileImagePath TEXT
      )
    ''');

    // Tabel transactions
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
  }

  // ─── USER OPERATIONS ────────────────────────────────────────────

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserByEmailOrUsername(String emailOrUsername) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [emailOrUsername, emailOrUsername],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<bool> isEmailTaken(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<bool> isUsernameTaken(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ─── TRANSACTION OPERATIONS ────────────────────────────────────

  Future<void> insertTransaction(TransactionModel tx) async {
    final db = await database;
    await db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getTransactionsByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertDemoTransactions(int userId) async {
    final now = DateTime.now();
    final demos = [
      TransactionModel(
        id: 'demo-1-$userId',
        userId: userId,
        title: 'Gaji Bulanan',
        amount: 5000000.0,
        type: 'pemasukan',
        category: 'Gaji',
        date: now.subtract(const Duration(days: 2)),
      ),
      TransactionModel(
        id: 'demo-2-$userId',
        userId: userId,
        title: 'Belanja Bulanan',
        amount: 1500000.0,
        type: 'pengeluaran',
        category: 'Kebutuhan',
        date: now.subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: 'demo-3-$userId',
        userId: userId,
        title: 'Beli Kopi',
        amount: 50000.0,
        type: 'pengeluaran',
        category: 'Gaya Hidup',
        date: now,
      ),
      TransactionModel(
        id: 'demo-4-$userId',
        userId: userId,
        title: 'Freelance Design',
        amount: 800000.0,
        type: 'pemasukan',
        category: 'Freelance',
        date: now.subtract(const Duration(days: 5)),
      ),
      TransactionModel(
        id: 'demo-5-$userId',
        userId: userId,
        title: 'Makan Siang',
        amount: 35000.0,
        type: 'pengeluaran',
        category: 'Makanan',
        date: now.subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: 'demo-6-$userId',
        userId: userId,
        title: 'Transportasi',
        amount: 120000.0,
        type: 'pengeluaran',
        category: 'Transportasi',
        date: now.subtract(const Duration(days: 6)),
      ),
    ];

    for (final tx in demos) {
      await insertTransaction(tx);
    }
  }
}
