// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LoginResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResult _$LoginResultFromJson(Map<String, dynamic> json) {
  return LoginResult()
    ..version = json['Version'] as String
    ..charset = json['Charset'] as String
    ..errorResult = json['Message'] == null
        ? null
        : ErrorResult.fromJson(json['Message'] as Map<String, dynamic>)
    ..error = json['error'] as String?
    ..loginVariables =
        LoginVariables.fromJson(json['Variables'] as Map<String, dynamic>);
}

Map<String, dynamic> _$LoginResultToJson(LoginResult instance) =>
    <String, dynamic>{
      'Version': instance.version,
      'Charset': instance.charset,
      'Message': instance.errorResult,
      'error': instance.error,
      'Variables': instance.loginVariables,
    };

LoginVariables _$LoginVariablesFromJson(Map<String, dynamic> json) {
  return LoginVariables()
    ..cookiepre = json['cookiepre'] as String
    ..auth = json['auth'] as String?
    ..saltkey = json['saltkey'] as String
    ..member_username = json['member_username'] as String
    ..member_avatar = json['member_avatar'] as String
    ..member_uid = json['member_uid'] as String
    ..groupid = json['groupid'] as String
    ..readaccess = json['readaccess'] as String
    ..ismoderator = json['ismoderator'] as String?
    ..noticeCount =
        NoticeCount.fromJson(json['notice'] as Map<String, dynamic>);
}

Map<String, dynamic> _$LoginVariablesToJson(LoginVariables instance) =>
    <String, dynamic>{
      'cookiepre': instance.cookiepre,
      'auth': instance.auth,
      'saltkey': instance.saltkey,
      'member_username': instance.member_username,
      'member_avatar': instance.member_avatar,
      'member_uid': instance.member_uid,
      'groupid': instance.groupid,
      'readaccess': instance.readaccess,
      'ismoderator': instance.ismoderator,
      'notice': instance.noticeCount,
    };
