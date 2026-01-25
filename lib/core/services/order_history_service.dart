import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Order History Model
class HistoryOrder {
  final int? id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final DateTime createdAt;

  HistoryOrder({
    this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HistoryOrder.fromMap(Map<String, dynamic> map) {
    return HistoryOrder(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      productImage: map['productImage'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory HistoryOrder.fromJson(String source) =>
      HistoryOrder.fromMap(jsonDecode(source));
}

/// Order History Service
/// خدمة سجل الطلبات
class OrderHistoryService {
  static const String _tableName = 'order_history';
  static Database? _database;

  /// Initialize database
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final String path = join(
      await getDatabasesPath(),
      'khodargy_order_history.db',
    );
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        productImage TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        UNIQUE(productId, createdAt)
      )
    ''');
  }

  /// Add order to history
  static Future<int> addOrder({
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required int quantity,
  }) async {
    try {
      final db = await database;
      return await db.insert(_tableName, {
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'price': price,
        'quantity': quantity,
        'createdAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('❌ Error adding order to history: $e');
      return 0;
    }
  }

  /// Get all history orders
  static Future<List<HistoryOrder>> getHistory() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'createdAt DESC',
      );

      return List<HistoryOrder>.from(maps.map((x) => HistoryOrder.fromMap(x)));
    } catch (e) {
      print('❌ Error getting history: $e');
      return [];
    }
  }

  /// Get unique products from history (group by productId, latest first)
  static Future<List<HistoryOrder>> getUniqueHistory() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM $_tableName
        GROUP BY productId
        ORDER BY createdAt DESC
      ''');

      return List<HistoryOrder>.from(maps.map((x) => HistoryOrder.fromMap(x)));
    } catch (e) {
      print('❌ Error getting unique history: $e');
      return [];
    }
  }

  /// Delete order from history
  static Future<int> deleteOrder(int id) async {
    try {
      final db = await database;
      return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Error deleting order: $e');
      return 0;
    }
  }

  /// Clear all history
  static Future<int> clearHistory() async {
    try {
      final db = await database;
      return await db.delete(_tableName);
    } catch (e) {
      print('❌ Error clearing history: $e');
      return 0;
    }
  }

  /// Close database
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
