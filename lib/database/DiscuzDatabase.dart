// database.dart

// required package imports
import 'dart:async';
import 'package:discuz_flutter/dao/DiscuzDao.dart';
import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;



part 'DiscuzDatabase.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Discuz])
abstract class DiscuzDatabase extends FloorDatabase {
  DiscuzDao get discuzDao;
}