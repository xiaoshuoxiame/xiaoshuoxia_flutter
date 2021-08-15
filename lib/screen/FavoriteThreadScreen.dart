
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/FavoriteThreadResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/DiscuzError.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/UserProfilePage.dart';
import 'package:discuz_flutter/page/ViewThreadSliverPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/EmptyScreen.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/screen/NullUserScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class FavoriteThreadScreen extends StatelessWidget {


  FavoriteThreadScreen();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FavoriteThreadStatefulWidget();
  }
}

class FavoriteThreadStatefulWidget extends StatefulWidget {


  FavoriteThreadStatefulWidget();

  _FavoriteThreadState createState() {
    return _FavoriteThreadState();
  }
}

class _FavoriteThreadState extends State<FavoriteThreadStatefulWidget> {

  late Dio _dio;
  late MobileApiClient _client;
  FavoriteThreadResult result = FavoriteThreadResult();
  DiscuzError? _error;
  int _page = 1;
  List<FavoriteThread> _pmList = [];

  late EasyRefreshController _controller;
  late ScrollController _scrollController;

  // 反向
  bool _reverse = false;
  // 方向
  Axis _direction = Axis.vertical;
  // Header浮动
  bool _headerFloat = false;
  // 无限加载
  bool _enableInfiniteLoad = true;
  // 控制结束
  bool _enableControlFinish = false;
  // 任务独立
  bool _taskIndependence = false;
  // 震动
  bool _vibration = true;
  // 是否开启刷新
  bool _enableRefresh = true;
  // 是否开启加载
  bool _enableLoad = true;
  // 顶部回弹
  bool _topBouncing = true;
  // 底部回弹
  bool _bottomBouncing = true;

  _FavoriteThreadState();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();

  }

  _invalidateHotThreadContent(Discuz discuz) async{
    _page = 1;
    await _loadPortalPrivateMessage(discuz);
  }

  Future<void> _loadPortalPrivateMessage(Discuz discuz) async {
    User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    this._dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    this._client = MobileApiClient(_dio, baseUrl: discuz.baseURL);

    // _client.hotThreadRaw(_page).then((value){
    //   log(value);
    //   result = HotThreadResult.fromJson(jsonDecode(value));
    //
    // });

    _client.favoriteThreadResult(_page).then((value){
      setState(() {
        result = value;
        _error = null;
        if (_page == 1) {
          _pmList = value.variables.pmList;
        } else {
          _pmList.addAll(value.variables.pmList);
        }
      });
      _page += 1;
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      // check for loaded all?
      log("Get HotThread ${_pmList.length} ${value.variables.count}");
      if (!_enableControlFinish) {
        _controller.finishLoad(
            noMore: _pmList.length >= value.variables.count);
      }

      if(user != null && value.variables.member_uid != user.uid){
        setState(() {
          _error = DiscuzError(S.of(context).userExpiredTitle(user.username), S.of(context).userExpiredSubtitle);
        });
      }

      if (value.getErrorString() != null) {
        EasyLoading.showError(value.getErrorString()!);
      }

      if(value.errorResult!= null){
        setState(() {
          _error = DiscuzError(value.errorResult!.key, value.errorResult!.content);
        });
      }
      else{
        setState(() {
          _error = null;
        });
      }


    })
    .catchError((onError,stacktrace){
      VibrationUtils.vibrateErrorIfPossible();
      EasyLoading.showError('${onError}');
      if (!_enableControlFinish) {
        _controller.resetLoadState();
        _controller.finishRefresh();
      }
      setState(() {
        _error = DiscuzError(
            onError.runtimeType.toString(), onError.toString());
      });
      throw(onError);
    });
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Consumer<DiscuzAndUserNotifier>(builder: (context,discuzAndUser, child){
      if(discuzAndUser.discuz == null){
        return NullDiscuzScreen();
      }
      else if(discuzAndUser.user == null){
        return NullUserScreen();
      }
      return Column(
        children: [
          if(_error!=null)
            ErrorCard(_error!.key, _error!.content,(){
              _controller.callRefresh();
            }
            ),
          Expanded(
              child: getEasyRefreshWidget(discuzAndUser.discuz!,discuzAndUser.user)
          )
        ],
      );
    });
  }

  Widget getEasyRefreshWidget(Discuz discuz, User? user){
    Locale locale = Localizations.localeOf(context);
    return EasyRefresh.custom(

      enableControlFinishRefresh: true,
      enableControlFinishLoad: true,
      taskIndependence: _taskIndependence,
      controller: _controller,
      scrollController: _scrollController,
      reverse: _reverse,
      scrollDirection: _direction,
      topBouncing: _topBouncing,
      bottomBouncing: _bottomBouncing,
      emptyWidget: _pmList.length == 0? EmptyScreen(): null,
      header: _enableRefresh? ClassicalHeader(
        enableInfiniteRefresh: false,
        bgColor:
        _headerFloat ? Theme.of(context).primaryColor : Colors.transparent,
        // infoColor: _headerFloat ? Colors.black87 : Theme.of(context).primaryColor,
        textColor: Theme.of(context).textTheme.headline1!.color == null? Theme.of(context).primaryColorDark: Theme.of(context).textTheme.headline1!.color!,
        float: _headerFloat,
        enableHapticFeedback: _vibration,
        refreshText: S.of(context).pullToRefresh,
        refreshReadyText: S.of(context).releaseToRefresh,
        refreshingText: S.of(context).refreshing,
        refreshedText: S.of(context).refreshed,
        refreshFailedText: S.of(context).refreshFailed,
        noMoreText: S.of(context).noMore,
        infoText: S.of(context).updateAt,
      )
          : null,
      footer: _enableLoad
          ? ClassicalFooter(
        textColor: Theme.of(context).textTheme.headline1!.color == null? Theme.of(context).primaryColorDark: Theme.of(context).textTheme.headline1!.color!,
        enableInfiniteLoad: _enableInfiniteLoad,
        enableHapticFeedback: _vibration,
        loadText: S.of(context).pushToLoad,
        loadReadyText: S.of(context).releaseToLoad,
        loadingText: S.of(context).loading,
        loadedText: S.of(context).loaded,
        loadFailedText: S.of(context).loadFailed,
        noMoreText: S.of(context).noMore,
        infoText: S.of(context).updateAt,
      )
          : null,
      onRefresh: _enableRefresh
          ? () async {
        _invalidateHotThreadContent(discuz);
        if (!_enableControlFinish) {
          _controller.resetLoadState();
          _controller.finishRefresh();
        }

      } : null,
      onLoad: _enableLoad
          ? () async {
        _loadPortalPrivateMessage(discuz);
      }
          : null,
      firstRefresh: true,
      firstRefreshWidget: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: SizedBox(
              height: 200.0,
              width: 300.0,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50.0,
                      height: 50.0,
                      child: SpinKitFadingCube(
                        color: Theme.of(context).primaryColor,
                        size: 25.0,
                      ),
                    ),
                    Container(
                      child: Text(S.of(context).loading),
                    )
                  ],
                ),
              ),
            )),
      ),
      slivers: <Widget>[

        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
                  FavoriteThread favoriteThread = _pmList[index];
              return Container(
                child: ListTile(
                  leading: InkWell(
                    child: ClipRRect(

                      borderRadius: BorderRadius.circular(10000.0),
                      child: CachedNetworkImage(
                        imageUrl: URLUtils.getAvatarURL(discuz, favoriteThread.uid.toString()),
                        progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            CircleAvatar(

                              backgroundColor: CustomizeColor.getColorBackgroundById(favoriteThread.uid),
                              child: Text(favoriteThread.author.length !=0 ? favoriteThread.author[0].toUpperCase()
                                  : S.of(context).anonymous,
                                  style: TextStyle(color: Colors.white)),
                            )
                        ,
                      ),
                    ),
                    onTap: () async{
                      VibrationUtils.vibrateWithClickIfPossible();
                      User? user = Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
                      await Navigator.push(
                          context,
                          platformPageRoute(context:context,builder: (context) => UserProfilePage(discuz,user, favoriteThread.uid)));
                    },
                  ),
                  title: Text(favoriteThread.title,style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: RichText(
                    text: TextSpan(
                      text: favoriteThread.author,
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        //TextSpan(text: S.of(context).publishAt, style: TextStyle(fontWeight: FontWeight.w300)),
                        TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
                        TextSpan(text: favoriteThread.description),
                        TextSpan(text: " · ",style: TextStyle(fontWeight: FontWeight.w300)),
                        TextSpan(text: TimeDisplayUtils.getLocaledTimeDisplay(context,favoriteThread.publishAt)),
                      ],
                    ),
                  ),

                  onTap: () async {
                    VibrationUtils.vibrateWithClickIfPossible();
                    await Navigator.push(
                        context,
                        platformPageRoute(context:context,builder: (context) => ViewThreadSliverPage( discuz,  user, favoriteThread.id,))
                    );
                  },


                ),
              );
            },
            childCount: _pmList.length
          ),
        ),
      ],
    );
  }
}
