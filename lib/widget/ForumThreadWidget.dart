
import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/DiscuzIndexResult.dart';
import 'package:discuz_flutter/JsonResult/DisplayForumResult.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/ForumThread.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/DisplayForumPage.dart';
import 'package:discuz_flutter/page/ViewThreadPage.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: must_be_immutable
class ForumThreadWidget extends StatelessWidget{

  ForumThread _forumThread;
  Discuz _discuz;
  User? _user;
  ThreadType? threadType;

  ForumThreadWidget(this._discuz,this._user,this._forumThread, this.threadType);

  Widget getTailingWidget(){
    if(_forumThread.getDisplayOrder() > 0){
      return Icon(Icons.vertical_align_top, color: Colors.redAccent,);
    }
    else{
      return Badge(
        badgeContent: Text(_forumThread.replies,style: TextStyle(color: Colors.white),),
        child: Icon(Icons.message_outlined),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Locale locale = Localizations.localeOf(context);
    log("languages ${locale} ${locale.toLanguageTag()} ${locale.scriptCode} ${locale.languageCode}");
    // retrieve threadtype
    String threadCategory = "";
    if(threadType!=null && threadType!.idNameMap.isNotEmpty && threadType!.idNameMap.containsKey(_forumThread.typeId)){
      threadCategory = threadType!.idNameMap[_forumThread.typeId]!;
    }

    return Container(
      child: ListTile(
        leading: ClipRRect(

          borderRadius: BorderRadius.circular(10000.0),
          child: CachedNetworkImage(
            imageUrl: URLUtils.getAvatarURL(_discuz, _forumThread.authorId),
            progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) =>
                CircleAvatar(

                  backgroundColor: CustomizeColor.getColorBackgroundById(_forumThread.getAuthorId()),
                  child: Text(_forumThread.author.length !=0 ? _forumThread.author[0].toUpperCase()
                      : S.of(context).anonymous,
                      style: TextStyle(color: Colors.white)),
                )
            ,
          ),
        ),
        title: Text(_forumThread.subject,style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: RichText(
          text: TextSpan(
            text: _forumThread.author,
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
              TextSpan(text: timeago.format(_forumThread.dbdatelineMinutes,locale: locale.scriptCode)),
              if(threadCategory.isNotEmpty)
                TextSpan(text: " / ",style: TextStyle(fontWeight: FontWeight.w300)),
              if(threadCategory.isNotEmpty)
                TextSpan(text: threadCategory,style: TextStyle(color: Theme.of(context).primaryColorDark)),
            ],
          ),
        ),
        trailing: getTailingWidget(),
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewThreadPage(discuz: _discuz, user: _user, tid: _forumThread.getTid(), key: UniqueKey(),))
          );
        },


      ),
    );
  }


}