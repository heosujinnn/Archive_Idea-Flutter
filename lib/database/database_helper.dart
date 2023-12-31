import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/idea_info.dart';

class DatabaseHelper {
  late Database database;

  //데이터베이스 초기화 및 열기
  Future<void> initDatabase() async {
    String path = join(await getDatabasesPath(), 'archive_idea.db');
    database = await openDatabase(path, version: 2, onCreate: (db, version) {
      // 최초 생성 시, 새로운 테이블을 생성합니다.
      db.execute('''
      CREATE TABLE IF NOT EXISTS tb_idea(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT, 
        motive TEXT,
        content TEXT,
        priority INTEGER,
        feedback TEXT,
        createdAt INTEGER
      )
    ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      // 이전 버전과 새로운 버전 간의 차이를 처리하는 로직을 작성합니다.
      if (oldVersion < 2) {
        // 새로운 버전에서 추가된 스키마를 여기에 추가합니다.
        await db.execute('ALTER TABLE tb_idea ADD COLUMN createdAt INTEGER');
      }
    });
  }

  //insert
  Future<int> insertIdeaInfo(IdeaInfo idea) async {
    return await database.insert('tb_idea', idea.toMap());
  }

  //select
  Future<List<IdeaInfo>> getAllIdeaInfo() async {
    final List<Map<String, dynamic>> result = await database.query('tb_idea');
    return List.generate(result.length, (index) {
      return IdeaInfo.fromMap(result[index]);
    });
  }

  //update (id에 접근)
  Future<int> updateIdeaInfo(IdeaInfo idea) async {
    return await database.update(
      'tb_idea', idea.toMap(), where: 'id=?', whereArgs: [idea.id],);
  }

  //delete
  Future<int> deleteIdeaInfo(int id) async {
    return await database.delete('tb_idea', where: 'id=?', whereArgs: [id],);
  }

  // 데이터베이스 닫기 * 앱 내에서 데베 사용하지 않을 경우 닫아줘야함.
  Future<void> closeDatabase() async{
    await database.close();
  }
}