import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/ViewThreadResult.dart';
import 'package:discuz_flutter/dao/BlockUserDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/BlockUser.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Post.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ReportContentPage.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/AttachmentWidget.dart';
import 'package:discuz_flutter/widget/DiscuzHtmlWidget.dart';
import 'package:discuz_flutter/widget/PostCommentWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

int POST_BLOCKED = 1;
int POST_WARNED = 2;
int POST_REVISED = 4;
int POST_MOBILE = 8;

class PostWidget extends StatelessWidget{
  Post _post;
  Discuz _discuz;
  int _authorId;
  String formhash;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  int? tid;

  PostWidget(this._discuz, this._post, this._authorId, this.formhash, {this.onAuthorSelectedCallback, this.postCommentList, this.ignoreFontCustomization, this.jumpToPidCallback, this.tid});

  @override
  Widget build(BuildContext context) {
    return PostStatefulWidget(this._discuz, this._post, this._authorId,this.formhash,
      onAuthorSelectedCallback: this.onAuthorSelectedCallback,
      postCommentList: this.postCommentList,
      ignoreFontCustomization: this.ignoreFontCustomization,
      jumpToPidCallback: this.jumpToPidCallback,
      tid: this.tid,
    );
  }


}

class PostStatefulWidget extends StatefulWidget{
  Post _post;
  Discuz _discuz;
  int _authorId;
  String formhash;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  int? tid;

  PostStatefulWidget(this._discuz, this._post, this._authorId,this.formhash, {this.onAuthorSelectedCallback, this.postCommentList, this.ignoreFontCustomization, this.jumpToPidCallback, this.tid});

  @override
  PostState createState() {
    return PostState(this._discuz, this._post, this._authorId,this.formhash,
        onAuthorSelectedCallback: this.onAuthorSelectedCallback,
        postCommentList: this.postCommentList,
        ignoreFontCustomization: this.ignoreFontCustomization,
        jumpToPidCallback: this.jumpToPidCallback,
        tid: this.tid
    );
  }


}

// ignore: must_be_immutable
class PostState extends State<PostStatefulWidget> {
  Post _post;
  Discuz _discuz;
  User? _user;
  int _authorId;
  VoidCallback? onAuthorSelectedCallback;
  JumpToPidCallback? jumpToPidCallback;
  Map<String, List<Comment>>? postCommentList;
  bool? ignoreFontCustomization = false;
  String formhash;
  int? tid;

  bool isFontStyleIgnored(){
    if(ignoreFontCustomization == null || ignoreFontCustomization == false){
      return false;
    }
    else{
      return true;
    }
  }

  List<Comment> getCommentList(){
    if(postCommentList == null){
      return [];
    }
    String pid = _post.pid.toString();
    if(postCommentList!.containsKey(pid)){
      return postCommentList![pid]!;
    }
    else{
      return [];
    }
  }

  PostState(this._discuz, this._post, this._authorId,this.formhash, {this.onAuthorSelectedCallback, this.postCommentList, this.ignoreFontCustomization, this.jumpToPidCallback, this.tid});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDB();
  }

  late BlockUserDao _blockUserDao;
  bool isUserBlocked = false;

  _loadDB() async{
    _blockUserDao = await AppDatabase.getBlockUserDao();
    // query whether use get blocked
    Discuz discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz!;
    _user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    List<BlockUser> userBlockedInDB = await _blockUserDao.isUserBlocked(_post.authorId, discuz);
    log("get blocked info ${userBlockedInDB} In DB");
    if (userBlockedInDB.isEmpty){
      setState(() {
        this.isUserBlocked = false;
      });
    }
    else{
      setState(() {
        this.isUserBlocked = true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {

    if(this.isUserBlocked){
      // show blocked user interface
      return Container(
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(

              children: [
                Text(S.of(context).contentPostByBlockUserTitle(_post.author), style:Theme.of(context).textTheme.headline6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      child: Text(S.of(context).unblockContent),
                      onPressed: () async{
                        VibrationUtils.vibrateWithClickIfPossible();
                        setState(() {
                          this.isUserBlocked = false;
                        });
                      },
                    ),
                    TextButton(
                      child: Text(S.of(context).unblockUser),
                      onPressed: () async{
                        // unblock user
                        VibrationUtils.vibrateWithClickIfPossible();
                        setState(() {
                          this.isUserBlocked = false;
                        });
                        await _blockUserDao.deleteBlockUserByUid(_post.authorId,  _discuz);
                      },
                    )
                  ],
                )
              ],
            )
          ),
        ),
      );
    }
    String _html = _post.message;
    if(this.isFontStyleIgnored()){
      // regex
      _html = _html.replaceAll(RegExp(r'<font.*?>',multiLine: true), "").replaceAll(RegExp(r'<\font.*?>'), "");
    }


    return Consumer<TypeSettingNotifierProvider>(
        builder: (context, typesetting, _) {
      return Container(
          child: Card(
            elevation: 4.0,
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Container(
                        width: 30.0,
                        height: 30.0,
                        child: InkWell(
                          child: CachedNetworkImage(
                            imageUrl: URLUtils.getSmallAvatarURL(
                                _discuz, _post.authorId.toString()),
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) => Container(
                              child: CircleAvatar(
                                backgroundColor:
                                    CustomizeColor.getColorBackgroundById(
                                        _post.authorId),
                                child: Text(
                                  _post.author.length != 0
                                      ? _post.author[0].toUpperCase()
                                      : S.of(context).anonymous,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          20
                                  ),
                                ),
                              ),
                            ),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          onTap: () async {
                            User? user = Provider.of<DiscuzAndUserNotifier>(
                                    context,
                                    listen: false)
                                .user;
                            VibrationUtils.vibrateWithClickIfPossible();
                            await Navigator.push(
                                context,
                                platformPageRoute(
                                    context: context,
                                    builder: (context) => UserProfilePage(
                                        _discuz, user, _post.authorId)));
                          },
                        ),
                      ),
                    ),
                    Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 4.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // username and OP come first
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: "",
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                      text: _post.author,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                          16)),
                                  if (_authorId == _post.authorId)
                                    TextSpan(
                                        text: ' ' + S.of(context).postAuthorLabel,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor,
                                            fontSize:
                                            16)),
                                ],
                              ),
                            ),

                            RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: TimeDisplayUtils.getLocaledTimeDisplay(context,_post.publishAt,),
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  if (_post.status & POST_REVISED != 0)
                                    TextSpan(
                                        text: ' · ' + S.of(context).editedPost,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor,
                                            fontSize: 14)),

                                ],
                              ),
                            ),
                          ],

                        ),



                      ],
                    )),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        if (_post.status & POST_MOBILE != 0)
                          Padding(
                            padding: EdgeInsets.only(right: 2.0),
                            child: Icon(
                              Icons.smartphone,
                              size: 16
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(right: 2.0),
                          child: Text(
                            S.of(context).postPosition(_post.position),
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                        ),
                        if(_user !=  null)
                          IconButton(
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 0, bottom: 0),
                            icon: Icon(Icons.flag,size: 16),
                            onPressed: () {
                              VibrationUtils.vibrateWithClickIfPossible();
                              Navigator.push(
                                  context,
                                  platformPageRoute(
                                      context: context,
                                      builder: (context) => ReportContentPage(_post.author,_post.pid, 0, formhash)));
                            },

                          ),
                        PopupMenuButton(
                          padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 0, bottom: 0),
                          icon: Icon(PlatformIcons(context).ellipsis,size: 16),
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              child: Text(S.of(context).replyPost),
                              value: 0,
                            ),
                            PopupMenuItem<int>(
                              child: Text(
                                  S.of(context).viewUserInfo(_post.author)),
                              value: 1,
                            ),
                            PopupMenuItem<int>(
                              child: Text(S.of(context).onlyViewAuthor),
                              value: 2,
                            ),
                            if(!this.isUserBlocked)
                              PopupMenuItem<int>(
                                child: Text(S.of(context).blockUser),
                                value: 3,
                              ),
                            if(this.isUserBlocked)
                              PopupMenuItem<int>(
                                child: Text(S.of(context).unblockUser),
                                value: 4,
                              ),
                          ],
                          onSelected: (int pos) async{
                            VibrationUtils.vibrateWithClickIfPossible();
                            switch (pos) {
                              case 0:
                                {
                                  // set provider to

                                  Provider.of<ReplyPostNotifierProvider>(
                                      context,
                                      listen: false)
                                      .setPost(_post);
                                  break;
                                }
                              case 1:
                                {
                                  User? user =
                                      Provider.of<DiscuzAndUserNotifier>(
                                          context,
                                          listen: false)
                                          .user;
                                  Navigator.push(
                                      context,
                                      platformPageRoute(
                                          context: context,
                                          builder: (context) => UserProfilePage(
                                              _discuz, user, _post.authorId)));
                                  break;
                                }
                              case 2:
                                {
                                  // set provider to

                                  if(onAuthorSelectedCallback!=null){
                                    VibrationUtils.vibrateWithClickIfPossible();
                                    onAuthorSelectedCallback!();
                                  }
                                  break;
                                }
                              case 3:
                                {
                                  // block user
                                  setState(() {
                                    this.isUserBlocked = true;
                                  });
                                  BlockUser blockUser = BlockUser(_post.authorId, _post.author, DateTime.now(), _discuz);
                                  int insertId = await _blockUserDao.insertBlockUser(blockUser);
                                  log("insert id into block user ${insertId}");
                                  break;
                                }
                              case 4:
                                {
                                  // unblock user
                                  setState(() {
                                    this.isUserBlocked = false;
                                  });
                                  _blockUserDao.deleteBlockUserByUid(_post.authorId,  _discuz);
                                  break;
                                }
                            }
                          },
                        )
                      ],
                    )

                  ],
                ),
                // banned or warn
                if (_post.status & POST_BLOCKED != 0)
                  getPostBlockedBlock(context),
                if (_post.status & POST_WARNED != 0) getPostWarnBlock(context),

                // rich text rendering
                DiscuzHtmlWidget(_discuz, _html,
                  tid: this.tid,
                  callback: jumpToPidCallback,
                ),
                if (_post.attachmentMapper.isNotEmpty)
                  ListView.builder(
                    itemBuilder: (context, index) {
                      Attachment attachment = _post.getAttachmentList()[index];
                      return AttachmentWidget(_discuz, attachment);
                    },
                    itemCount: _post.getAttachmentList().length,
                    physics: new NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  ),
                if(getCommentList().length != 0)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        itemBuilder: (context, index){
                          Comment comment = getCommentList()[index];
                          return PostCommentWidget(comment);
                        },
                        itemCount: getCommentList().length,
                        physics: new NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                      )
                    ],
                  ),

              ],
            )),
      ));
    });
  }

  Widget getPostBlockedBlock(BuildContext context) {
    return Container(
      color:  Colors.red.withOpacity(0.15),
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: Row(
          children: [
            Icon(Icons.block, color: Colors.red,),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(S.of(context).blockedPost, style: TextStyle(color: Colors.red),),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getPostWarnBlock(BuildContext context) {
    return Container(
      color:  Colors.deepOrange.withOpacity(0.15),
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.deepOrange,),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(S.of(context).warnedPost, style: TextStyle(color: Colors.deepOrange),),
              ),
            )
          ],
        ),
      ),
    );

  }

  Widget getPostRevisedBlock(BuildContext context) {
    return Container(
        color:  Colors.blue.withOpacity(0.15),
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.blue,),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(S.of(context).revisedPost, style: TextStyle(color: Colors.blue),),
                ),
              )
            ],
          ),
        ),
    );
  }
}

