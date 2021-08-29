

import 'package:discuz_flutter/dao/UserDao.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ExploreWebsitePage.dart';
import 'package:discuz_flutter/page/TestFlightBannerPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/ConfigurationScreen.dart';
import 'package:discuz_flutter/screen/DiscuzPortalScreen.dart';
import 'package:discuz_flutter/screen/HotThreadScreen.dart';
import 'package:discuz_flutter/screen/NotificationScreen.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ExclusiveDiscuzPortalPage extends StatelessWidget{
  Discuz _discuz;

  ExclusiveDiscuzPortalPage(this._discuz);

  @override
  Widget build(BuildContext context) {
    return ExclusiveDiscuzPortalStatefulWidget(this._discuz);
  }
}

class ExclusiveDiscuzPortalStatefulWidget extends StatefulWidget{
  Discuz _discuz;

  ExclusiveDiscuzPortalStatefulWidget(this._discuz);

  @override
  ExclusiveDiscuzPortalState createState() {
    return ExclusiveDiscuzPortalState(this._discuz);
  }

}

class ExclusiveDiscuzPortalState extends State<ExclusiveDiscuzPortalStatefulWidget>{

  Discuz _discuz;
  ExclusiveDiscuzPortalState(this._discuz);

  late PlatformTabController tabController;

  late UserDao _userDao;

  void _initDb() async {
    Provider.of<DiscuzAndUserNotifier>(context, listen: false).setDiscuz(_discuz);
    final db = await DBHelper.getAppDb();
    _userDao = db.userDao;
    await _setFirstUserInDiscuz(_discuz.id!);
  }

  Future<void> _setFirstUserInDiscuz(int discuzId) async{
    List<User> userList = await _userDao.findAllUsersByDiscuzId(discuzId);
    if(userList.isNotEmpty && userList.length > 0){
      print("find a user in the database ${userList.length}");
      Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(userList.last);
      // might need to refresh the layout
    }

  }

  _showNotificationIfFirstlyShown() async{
    int flag = await UserPreferencesUtils.getTestFlightNotificationFlag();
    if(flag == 0){
      // shown
      Navigator.push(
          context,
          platformPageRoute(
              context: context,
              builder: (context) => TestFlightBannerPage()));
    }
  }



  @override
  void initState() {
    super.initState();

    _initDb();



    tabController = PlatformTabController(
      initialIndex: 0,
    );




    _showNotificationIfFirstlyShown();
  }



  @override
  Widget build(BuildContext context) {


    return PlatformTabScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      tabController: tabController,
      materialTabs: (_,__) => MaterialNavBarData(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      appBarBuilder: (_,index) => PlatformAppBar(
        title: Text(_discuz.siteName),
        automaticallyImplyLeading: false,
      ),
      items: [
        BottomNavigationBarItem(
            icon: new Icon(CupertinoIcons.today),
            label: S.of(context).sitePage),
        BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: S.of(context).index),
        BottomNavigationBarItem(
            icon: new Icon(Icons.dashboard),
            label: S.of(context).dashboard),
        BottomNavigationBarItem(
            icon: new Icon(Icons.notifications),
            label: S.of(context).notification),
        BottomNavigationBarItem(
            icon: new Icon(PlatformIcons(context).settings),
            label: S.of(context).settings),
      ],
      bodyBuilder: (context, index) => IndexedStack(
        index: index,
        children: [
          ExploreWebsitePage(),
          DiscuzPortalScreen(),
          HotThreadScreen(),
          NotificationScreen(),
          ConfigurationScreen(),
        ],
      ),

    );


  }

  @override
  void setState(fn) {
    if(this.mounted) {
      super.setState(fn);
    }
  }

}