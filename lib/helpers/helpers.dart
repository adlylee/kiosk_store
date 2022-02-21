import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/barang.dart';
import '../models/stokBarang.dart';
import '../models/cart.dart';

class Helpers {
  static Helpers _helper;
  static Database _database;

  Helpers._createObject();

  factory Helpers() {
    if (_helper == null) {
      _helper = Helpers._createObject();
    }
    return _helper;
  }

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'pos.db';

    var todoDatabase = openDatabase(path, version: 1, onCreate: _createDb);

    return todoDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE barang (
        id_barang INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_barang TEXT,
        harga TEXT
      ) ''');
    await db.execute('''
    CREATE TABLE stok (
        id_stok INTEGER PRIMARY KEY AUTOINCREMENT,
        id_barang TEXT,
        tipe_barang TEXT,
        stok TEXT
      ) ''');
    await db.execute('''
    CREATE TABLE jual (
        id_jual INTEGER PRIMARY KEY AUTOINCREMENT,
        no_pesanan TEXT,
        no_cart TEXT,
        tanggal TEXT,
        diskon INTEGER,
        total INTEGER
      ) ''');
    await db.execute('''
    CREATE TABLE cart (
        id_cart INTEGER PRIMARY KEY AUTOINCREMENT,
        no_cart TEXT,
        id_stok INTEGER,
        jumlah INTEGER,
        harga INTEGER,
        is_bayar TEXT
      ) ''');
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDb();
    }
    return _database;
  }

  Future<List<Map<String, dynamic>>> selectBarang() async {
    Database db = await this.database;
    var mapList = await db.query('barang', orderBy: 'nama_barang');
    return mapList;
  }

  Future<List<Map<String, dynamic>>> selectBarangById(String id) async {
    Database db = await this.database;
    var mapList =
        await db.query('barang', where: 'id_barang=?', whereArgs: [id]);
    return mapList;
  }

  Future<int> insertBarang(Barang object) async {
    Database db = await this.database;
    int count = await db.insert('barang', object.toMap());
    return count;
  }

  Future<int> updateBarang(Barang object) async {
    Database db = await this.database;
    int count = await db.update('barang', object.toMap(),
        where: 'id_barang=?', whereArgs: [object.idBarang]);
    return count;
  }

  Future<int> deleteBarang(int id) async {
    Database db = await this.database;
    int count =
        await db.delete('barang', where: 'id_barang=?', whereArgs: [id]);
    return count;
  }

  Future<List<Barang>> getBarangList() async {
    var barangMapList = await selectBarang();
    int count = barangMapList.length;
    List<Barang> barangList = List<Barang>();
    for (int i = 0; i < count; i++) {
      barangList.add(Barang.fromMap(barangMapList[i]));
    }
    return barangList;
  }

  Future<List<Barang>> getBarangListById(String id) async {
    var barangMapList = await selectBarangById(id);
    int count = barangMapList.length;
    // Barang barangList = Barang.fromMap(barangMapList[0]);
    List<Barang> barangList = List<Barang>();
    for (int i = 0; i < count; i++) {
      barangList.add(Barang.fromMap(barangMapList[i]));
    }
    return barangList;
  }

  Future<List<Map<String, dynamic>>> selectStok() async {
    Database db = await this.database;
    var mapList = await db.rawQuery(
        'SELECT stok.id_stok , stok.id_barang , barang.nama_barang , stok.tipe_barang , barang.harga , stok.stok FROM stok JOIN barang ON stok.id_barang = barang.id_barang');
    return mapList;
  }

  Future<List<Map<String, dynamic>>> selectStokNotEmpty() async {
    Database db = await this.database;
    var mapList = await db.rawQuery(
        "SELECT stok.id_stok , stok.id_barang , barang.nama_barang , stok.tipe_barang , barang.harga , stok.stok FROM stok JOIN barang ON stok.id_barang = barang.id_barang WHERE stok.stok != '0'");
    return mapList;
  }

  Future<int> insertStok(StokBarang object) async {
    Database db = await this.database;
    int count = await db.insert('stok', object.toMap());
    return count;
  }

  Future<int> updateStok(StokBarang object) async {
    Database db = await this.database;
    int count = await db.update('stok', object.toMap(),
        where: 'id_stok=?', whereArgs: [object.idStok]);
    return count;
  }

  Future<int> deleteStok(int id) async {
    Database db = await this.database;
    int count = await db.delete('stok', where: 'id_stok=?', whereArgs: [id]);
    return count;
  }

  Future<List<StokBarang>> getStokList() async {
    var stokMapList = await selectStok();
    int count = stokMapList.length;
    List<StokBarang> stokList = List<StokBarang>();
    for (int i = 0; i < count; i++) {
      stokList.add(StokBarang.fromMap(stokMapList[i]));
    }
    return stokList;
  }

  Future<List<StokBarang>> getStokListNotEmpty() async {
    var stokMapList = await selectStokNotEmpty();
    int count = stokMapList.length;
    List<StokBarang> stokList = List<StokBarang>();
    for (int i = 0; i < count; i++) {
      stokList.add(StokBarang.fromMap(stokMapList[i]));
    }
    return stokList;
  }

  Future<int> insertCart(Cart object) async {
    Database db = await this.database;
    int count = await db.insert('cart', object.toMap());
    return count;
  }

  Future<List<Map<String, dynamic>>> selectCart() async {
    Database db = await this.database;
    var mapList = await db.query('cart', groupBy: 'no_cart');
    return mapList;
  }

  Future<List<Map<String, dynamic>>> selectCartValue(String id) async {
    Database db = await this.database;
    var mapList = await db.rawQuery(
        "SELECT cart.id_cart , cart.no_cart , cart.id_stok , barang.nama_barang , cart.jumlah , cart.harga , stok.tipe_barang FROM cart JOIN stok ON cart.id_stok = stok.id_stok JOIN barang ON stok.id_barang = barang.id_barang WHERE cart.no_cart ='"+id+"'");
    return mapList;
  }

  Future<List<Cart>> getCartList() async {
    var kartMapList = await selectCart();
    int count = kartMapList.length;
    List<Cart> kart = List<Cart>();
    for (int i = 0; i < count; i++) {
      kart.add(Cart.fromMap(kartMapList[i]));
    }
    return kart;
  }

  Future<List<Cart>> getCartListValue(String id) async {
    var kartMapList = await selectCartValue(id);
    int count = kartMapList.length;
    List<Cart> kart = List<Cart>();
    for (int i = 0; i < count; i++) {
      kart.add(Cart.fromMap(kartMapList[i]));
    }
    return kart;
  }

  Future<int> deleteCart(int id) async {
    Database db = await this.database;
    int count =
        await db.delete('cart', where: 'id_cart=?', whereArgs: [id]);
    return count;
  }
}
