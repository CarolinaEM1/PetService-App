import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/dueno.dart';
import '../models/mascota.dart';
import '../models/categoria.dart';
import '../models/servicio.dart';
import '../models/cita.dart';
import '../models/detalle_cita.dart';
import '../models/cita_completa.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'canina.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE duenos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            telefono TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE mascotas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            raza TEXT NOT NULL,
            dueno_id INTEGER NOT NULL,
            FOREIGN KEY (dueno_id) REFERENCES duenos(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE categorias(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE servicios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            categoria_id INTEGER NOT NULL,
            FOREIGN KEY (categoria_id) REFERENCES categorias(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE citas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mascota_id INTEGER NOT NULL,
            fecha TEXT NOT NULL,
            hora TEXT NOT NULL,
            estatus TEXT NOT NULL,
            recordatorio TEXT NOT NULL,
            FOREIGN KEY (mascota_id) REFERENCES mascotas(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE detalle_cita(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cita_id INTEGER NOT NULL,
            servicio_id INTEGER NOT NULL,
            cantidad INTEGER NOT NULL,
            FOREIGN KEY (cita_id) REFERENCES citas(id),
            FOREIGN KEY (servicio_id) REFERENCES servicios(id)
          )
        ''');
      },
    );
  }

  // =========================
  // CRUD DUEÑOS
  // =========================
  static Future<int> insertDueno(Dueno dueno) async {
    final db = await database;
    return await db.insert('duenos', dueno.toMap());
  }

  static Future<List<Dueno>> getDuenos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('duenos');
    return List.generate(maps.length, (i) => Dueno.fromMap(maps[i]));
  }

  static Future<int> updateDueno(Dueno dueno) async {
    final db = await database;
    return await db.update(
      'duenos',
      dueno.toMap(),
      where: 'id = ?',
      whereArgs: [dueno.id],
    );
  }

  static Future<int> deleteDueno(int id) async {
    final db = await database;
    return await db.delete(
      'duenos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // CRUD MASCOTAS
  // =========================
  static Future<int> insertMascota(Mascota mascota) async {
    final db = await database;
    return await db.insert('mascotas', mascota.toMap());
  }

  static Future<List<Mascota>> getMascotas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mascotas');
    return List.generate(maps.length, (i) => Mascota.fromMap(maps[i]));
  }

  static Future<int> updateMascota(Mascota mascota) async {
    final db = await database;
    return await db.update(
      'mascotas',
      mascota.toMap(),
      where: 'id = ?',
      whereArgs: [mascota.id],
    );
  }

  static Future<int> deleteMascota(int id) async {
    final db = await database;
    return await db.delete(
      'mascotas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // CRUD CATEGORÍAS
  // =========================
  static Future<int> insertCategoria(Categoria categoria) async {
    final db = await database;
    return await db.insert('categorias', categoria.toMap());
  }

  static Future<List<Categoria>> getCategorias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categorias');
    return List.generate(maps.length, (i) => Categoria.fromMap(maps[i]));
  }

  static Future<int> updateCategoria(Categoria categoria) async {
    final db = await database;
    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  static Future<int> deleteCategoria(int id) async {
    final db = await database;
    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // CRUD SERVICIOS
  // =========================
  static Future<int> insertServicio(Servicio servicio) async {
    final db = await database;
    return await db.insert('servicios', servicio.toMap());
  }

  static Future<List<Servicio>> getServicios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('servicios');
    return List.generate(maps.length, (i) => Servicio.fromMap(maps[i]));
  }

  static Future<List<Servicio>> getServiciosPorCategoria(int categoriaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'servicios',
      where: 'categoria_id = ?',
      whereArgs: [categoriaId],
    );
    return List.generate(maps.length, (i) => Servicio.fromMap(maps[i]));
  }

  static Future<int> updateServicio(Servicio servicio) async {
    final db = await database;
    return await db.update(
      'servicios',
      servicio.toMap(),
      where: 'id = ?',
      whereArgs: [servicio.id],
    );
  }

  static Future<int> deleteServicio(int id) async {
    final db = await database;
    return await db.delete(
      'servicios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // CRUD CITAS
  // =========================
  static Future<int> insertCita(Cita cita) async {
    final db = await database;
    return await db.insert('citas', cita.toMap());
  }

  static Future<List<Cita>> getCitas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'citas',
      orderBy: 'fecha ASC, hora ASC',
    );
    return List.generate(maps.length, (i) => Cita.fromMap(maps[i]));
  }

  static Future<List<Cita>> getCitasPorEstatus(String estatus) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'citas',
      where: 'estatus = ?',
      whereArgs: [estatus],
      orderBy: 'fecha ASC, hora ASC',
    );
    return List.generate(maps.length, (i) => Cita.fromMap(maps[i]));
  }

  static Future<List<Cita>> getCitasPorFecha(String fecha) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'citas',
      where: 'fecha = ?',
      whereArgs: [fecha],
      orderBy: 'hora ASC',
    );
    return List.generate(maps.length, (i) => Cita.fromMap(maps[i]));
  }

  static Future<int> updateCita(Cita cita) async {
    final db = await database;
    return await db.update(
      'citas',
      cita.toMap(),
      where: 'id = ?',
      whereArgs: [cita.id],
    );
  }

  static Future<int> updateEstatusCita(int id, String nuevoEstatus) async {
    final db = await database;
    return await db.update(
      'citas',
      {'estatus': nuevoEstatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCita(int id) async {
    final db = await database;
    return await db.delete(
      'citas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // CRUD DETALLE CITA
  // =========================
  static Future<int> insertDetalleCita(DetalleCita detalle) async {
    final db = await database;
    return await db.insert('detalle_cita', detalle.toMap());
  }

  static Future<List<DetalleCita>> getDetallesPorCita(int citaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'detalle_cita',
      where: 'cita_id = ?',
      whereArgs: [citaId],
    );
    return List.generate(maps.length, (i) => DetalleCita.fromMap(maps[i]));
  }

  static Future<int> updateDetalleCita(DetalleCita detalle) async {
    final db = await database;
    return await db.update(
      'detalle_cita',
      detalle.toMap(),
      where: 'id = ?',
      whereArgs: [detalle.id],
    );
  }

  static Future<int> deleteDetalleCita(int id) async {
    final db = await database;
    return await db.delete(
      'detalle_cita',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // CITAS COMPLETAS CON JOIN
  // =========================
  static Future<List<CitaCompleta>> getCitasCompletas({
    String? estatus,
  }) async {
    final db = await database;

    String query = '''
      SELECT 
        citas.id,
        mascotas.nombre AS mascota_nombre,
        duenos.nombre AS dueno_nombre,
        citas.fecha,
        citas.hora,
        citas.estatus
      FROM citas
      INNER JOIN mascotas ON citas.mascota_id = mascotas.id
      INNER JOIN duenos ON mascotas.dueno_id = duenos.id
    ''';

    List<dynamic> args = [];

    if (estatus != null && estatus != 'todos') {
      query += ' WHERE citas.estatus = ?';
      args.add(estatus);
    }

    query += ' ORDER BY citas.fecha ASC, citas.hora ASC';

    final List<Map<String, dynamic>> result = await db.rawQuery(query, args);

    return result.map((e) => CitaCompleta.fromMap(e)).toList();
  }
}