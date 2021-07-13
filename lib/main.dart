import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/dialog/SwitchDiscuzDialog.dart';
import 'package:discuz_flutter/page/ManageAccountPage.dart';
import 'package:discuz_flutter/page/ManageDiscuzPage.dart';
import 'package:discuz_flutter/page/ManageTrustHostPage.dart';
import 'package:discuz_flutter/page/ViewHistoryPage.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/screen/DiscuzMessageScreen.dart';
import 'package:discuz_flutter/screen/HotThreadScreen.dart';
import 'package:discuz_flutter/screen/NotificationScreen.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/widget/UserAvatar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:discuz_flutter/page/AddDiscuzPage.dart';
import 'package:discuz_flutter/page/LoginPage.dart';
import 'package:discuz_flutter/screen/DiscuzPortalScreen.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'dao/DiscuzDao.dart';
import 'dao/UserDao.dart';
import 'entity/Discuz.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/SettingPage.dart';

import 'entity/User.dart';

String initialPlatform = "";

void main() async{
  // init google ads

  WidgetsFlutterBinding.ensureInitialized();
  log("initial for ads");
  MobileAds.instance.initialize();
  log("languages initialization");
  initialPlatform = await UserPreferencesUtils.getPlatformPreference();


  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeNotifierProvider()),
          ChangeNotifierProvider.value(value: DiscuzAndUserNotifier()),
          ChangeNotifierProvider.value(value: ReplyPostNotifierProvider())
        ],
        child: MyApp(),
      ));
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  String platformName = "";

  _loadThemeColor(context) async{

    String colorName = await UserPreferencesUtils.getThemeColor();
    platformName = await UserPreferencesUtils.getPlatformPreference();
    print("Get color name "+colorName+"platform name "+platformName);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setTheme(colorName);
    Provider.of<ThemeNotifierProvider>(context,listen: false).setPlatformName(platformName);
    // if(PlatformProvider.of(context)!=null){
    //   switch (platformName){
    //     case "":{
    //       PlatformProvider.of(context)!.changeToAutoDetectPlatform();
    //       break;
    //     }
    //     case "ios":{
    //       PlatformProvider.of(context)!.changeToCupertinoPlatform();
    //       break;
    //     }
    //     case "android":{
    //       PlatformProvider.of(context)!.changeToMaterialPlatform();
    //       break;
    //     }
    //   }
    // }
  }

  // _loadPlatformPreference(BuildContext context) async{
  //   platformName = await UserPreferencesUtils.getPlatformPreference();
  //   log("Platform provider ${PlatformProvider.of(context)}");
  //   if(PlatformProvider.of(context)!=null){
  //     switch (platformName){
  //       case "":{
  //         PlatformProvider.of(context)!.changeToAutoDetectPlatform();
  //         break;
  //       }
  //       case "ios":{
  //         PlatformProvider.of(context)!.changeToCupertinoPlatform();
  //         break;
  //       }
  //       case "android":{
  //         PlatformProvider.of(context)!.changeToMaterialPlatform();
  //         break;
  //       }
  //     }
  //   }
  // }

  TargetPlatform? getTargetPlatformByName(String name){
    switch (name){
      case "android": return TargetPlatform.android;
      case "ios": return TargetPlatform.iOS;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _loadThemeColor(context);
    return Consumer<ThemeNotifierProvider>(
      builder: (context, themeColorEntity, _){
        final materialTheme = ThemeData(
          //brightness: MediaQuery.platformBrightnessOf(context),
          cupertinoOverrideTheme: CupertinoThemeData(
            primaryColor: themeColorEntity.themeColor,
          ),
          primarySwatch: themeColorEntity.themeColor,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
              foregroundColor: MaterialStateProperty.all(themeColorEntity.themeColor),
            ),
          ),
        );

        // if (Platform.isAndroid) {
        //   print("Selected color ${themeColorEntity.themeColorName} ${themeColorEntity.themeColor}");
        //
        //   SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        //     statusBarColor: Colors.transparent,
        //     statusBarIconBrightness: Brightness.dark,
        //     statusBarBrightness: themeColorEntity.brightness,
        //     // systemNavigationBarColor: Color(themeColorEntity.themeColor.value),
        //     // systemNavigationBarIconBrightness: themeColorEntity.brightness
        //   );
        //   SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
        // }

        return Theme(
            data: materialTheme,
            child: PlatformProvider(
              initialPlatform: getTargetPlatformByName(initialPlatform),
              settings: PlatformSettingsData(
                  iosUsesMaterialWidgets: true,

              ),
              builder: (context){
                return  PlatformApp(
                  title: 'Flutter Demo',
                  // theme: ThemeData(
                  //     primaryColor: themeColorEntity.themeColor,
                  //     floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: themeColorEntity.themeColor),
                  //     brightness: Brightness.light
                  // ),
                  // darkTheme: ThemeData(
                  //     primaryColor: themeColorEntity.themeColor,
                  //     floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: themeColorEntity.themeColor),
                  //     brightness: Brightness.dark
                  // ),

                  material: (_,__)=> MaterialAppData(
                      theme: materialTheme,
                      darkTheme: ThemeData(
                          primaryColor: themeColorEntity.themeColor,
                          floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: themeColorEntity.themeColor),
                          brightness: Brightness.dark
                      )
                  ),
                  cupertino: (_,__) => CupertinoAppData(
                    theme: CupertinoThemeData(
                      primaryColor: themeColorEntity.themeColor,
                    ),

                  ),
                  // localization
                  localizationsDelegates: [
                    S.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  localeResolutionCallback: (locale, _){
                    if(locale!=null){
                      print("Locale ${locale.languageCode},${locale.scriptCode}, ${locale.countryCode}");
                      TimeAgo.setDefaultLocale(locale.languageCode);
                    }
                  },
                  builder: EasyLoading.init(),
                  home: MyHomePage(title: "谈坛"),
                );
              },
            )

        );
      },
    );

  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _showUserDetail = false;
  int _bottomNavigationbarIndex = 0;
  late List<Widget> bodies = [];
  late UserDao _userDao;
  late DiscuzDao _discuzDao;

  //
  List<Discuz> _allDiscuzs = [];
  Stream<List<Discuz>>? _discuzListStream;


  _MyHomePageState() {
    _queryDiscuzList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initDb();

  }

  void _initDb() async {
    final db = await DBHelper.getAppDb();
    _userDao = db.userDao;
    _discuzDao = db.discuzDao;
  }

  void _setFirstUserInDiscuz(int discuzId) async{
    List<User> userList = await _userDao.findAllUsersByDiscuzId(discuzId);
    if(userList.isNotEmpty && userList.length > 0){
      Provider.of<DiscuzAndUserNotifier>(context, listen: false).setUser(userList.first);
    }

  }

  void _triggerSwitchDiscuzDialog() async {
    _getDiscuzList();
    List<Widget> widgetList = [];
    for (int i = 0; i < _allDiscuzs.length; i++) {
      Discuz discuz = _allDiscuzs[i];
      Discuz? _selecteddiscuz =
          Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;

      widgetList.add(SimpleDialogItem(
        key: UniqueKey(),
        icon:
        (_selecteddiscuz != null && _selecteddiscuz.id == discuz.id) ? Icons.check_circle : Icons.amp_stories,
        color: (_selecteddiscuz != null && _selecteddiscuz.id == discuz.id) ? Colors.green : Colors.grey,
        text: discuz.siteName,
        onPressed: () {
          setState(() {
            Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                .initDiscuz(discuz);
            _setFirstUserInDiscuz(discuz.id!);
            Navigator.of(context).pop();
          });
        },
      ));
    }

    widgetList.add(SimpleDialogItem(
        key: UniqueKey(),
        icon: Icons.add_box_outlined,
        color: Colors.blueAccent,
        text: S.of(context).addNewDiscuz,
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              platformPageRoute(
                  context: context,
                  builder: (context) => AddDiscuzPage()));
        }));

    await showDialog<Null>(
        context: context, //BuildContext对象
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(S.of(context).chooseDiscuz), children: widgetList);
        });
  }

  void _getDiscuzList() async {
    final db = await DBHelper.getAppDb();
    final dao = db.discuzDao;

    _allDiscuzs = await dao.findAllDiscuzs();
  }

  Widget _buildFunctionNavWidgetList() {
    return ListView(
      children: [
        ListTile(
          title: Text(S.of(context).loginTitle),
          subtitle: Text(S.of(context).loginSubtitle),
          leading: Icon(PlatformIcons(context).personAdd),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
              await Navigator.push(context, platformPageRoute(context:context,builder: (context) => LoginPage(discuz, null)));
            }
          },
        ),
        ListTile(
          title: Text(S.of(context).manageAccount),
          leading: Icon(PlatformIcons(context).personOutline),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
              await Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                      builder: (context) => ManageAccountPage(
                        discuz,
                      )));
            }
          },
        ),
        ListTile(
          title: Text(S.of(context).manageDiscuz),
          leading: Icon(Icons.forum_outlined),
          onTap: () async {
            await Navigator.push(
                context,
                platformPageRoute(
                  context: context,
                    builder: (context) => ManageDiscuzPage()));
          },
        ),
        ListTile(
          title: Text(S.of(context).viewHistory),
          leading: Icon(PlatformIcons(context).time),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
            if(discuz != null){
              await Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                      builder: (context) => ViewHistoryPage(discuz)));
            }

          },
        ),
        ListTile(
          title: Text(S.of(context).trustHostTitle),
          leading: Icon(PlatformIcons(context).checkMarkCircledOutline),
          onTap: () async {
            await Navigator.push(context,platformPageRoute(context:context,builder: (context) => ManageTrustHostPage()));
          },
        ),
        ListTile(
          title: Text(S.of(context).settingTitle),
          leading: Icon(PlatformIcons(context).settingsSolid),
          onTap: () async {
            Discuz? discuz =
                Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                    .discuz;
            if (discuz != null) {
              await Navigator.push(context,
                  platformPageRoute(context:context,builder: (context) => SettingPage()));
            }
          },
        )
      ],
    );
  }

  void _toggleNavigationStatus(){
    setState(() {
      _showUserDetail = !_showUserDetail;
    });
  }

  Widget _buildUserNavigationWidgetList() {
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (discuz != null) {
      log("Get discuz id ${discuz.id}");
      return StreamBuilder(
        stream: _userDao.findAllUsersStreamByDiscuzId(discuz.id!),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.data == null) {
            return ListView(
              children: [
                ListTile(
                    onTap: () {
                      Provider.of<DiscuzAndUserNotifier>(context, listen: false)
                          .setUser(null);
                      _toggleNavigationStatus();
                    },
                    title: Text(S.of(context).incognitoTitle),
                    subtitle: Text(S.of(context).incognitoTitle),
                    leading: Icon(Icons.person_pin)),
              ],
            );
          } else {
            List<User> userList = snapshot.data!;
            return ListView.builder(
                itemCount: userList.length + 1,
                itemBuilder: (context, position) {

                  if (position != userList.length) {
                    User user = userList[position];
                    return ListTile(
                      onTap: (){
                        Provider.of<DiscuzAndUserNotifier>(context,
                            listen: false)
                            .setUser(user);
                        _toggleNavigationStatus();
                      },
                      title: Text(user.username),
                      subtitle: Text(S.of(context).userIdTitle(user.uid)),
                      leading: Container(
                        // width: 16.0,
                        // height: 16.0,
                        child: CircleAvatar(
                          backgroundColor: CustomizeColor.getColorBackgroundById(user.uid),
                          child: Text(
                            user.username.length != 0
                                ? user.username[0].toUpperCase()
                                : S.of(context).anonymous,
                            style: TextStyle(color: Colors.white,fontSize: 18),
                          ),
                        ),
                      )
                    );
                  } else {
                    return ListTile(
                        onTap: () {
                          Provider.of<DiscuzAndUserNotifier>(context,
                                  listen: false)
                              .setUser(null);
                          _toggleNavigationStatus();
                        },
                        title: Text(S.of(context).incognitoTitle),
                        subtitle: Text(S.of(context).incognitoTitle),
                        leading: Icon(Icons.person_pin));
                  }
                });
          }
        },
      );
    } else {
      return Container();
    }
  }

  void _queryDiscuzList() async {
    final db = await DBHelper.getAppDb();
    final dao = db.discuzDao;

    this._discuzListStream = dao.findAllDiscuzStream();
    _allDiscuzs = await dao.findAllDiscuzs();
    log("recv discuz list ${_allDiscuzs.length}");
    if(_allDiscuzs.isNotEmpty){
      setState(() {
        // set
        Provider.of<DiscuzAndUserNotifier>(context, listen: false)
            .initDiscuz(_allDiscuzs.first);
        _setFirstUserInDiscuz(_allDiscuzs.first.id!);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<DiscuzAndUserNotifier>(
          builder: (context, value, child){
            if(value.discuz == null){
              return Text(S.of(context).appName);
            }
            else{
              return Column(
                children: [
                  Text(value.discuz!.siteName),
                  if(value.user == null)
                    Text(S.of(context).incognitoTitle,style: TextStyle(fontSize: 12)),
                  if(value.user!= null)
                    Text("${value.user!.username} (${value.user!.uid})",style: TextStyle(fontSize: 12),)
                ],
              );
            }

          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
          child: Column(
        children: [
          Consumer<DiscuzAndUserNotifier>(builder: (context, value, child) {
            if (value.discuz == null || value.user == null) {
              return UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountEmail: Text(S.of(context).incognitoSubtitle),
                accountName: Text(S.of(context).incognitoTitle),
                currentAccountPicture: Icon(Icons.person_pin,color: Colors.white,),
                onDetailsPressed: () {
                  setState(() {
                    _showUserDetail = !_showUserDetail;
                  });
                },
              );
            } else {
              return UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountEmail: Text(value.user!.uid.toString()),
                accountName: Text(value.user!.username),
                currentAccountPicture: UserAvatar(value.discuz!,value.user!),
                onDetailsPressed: () {
                  setState(() {
                    _showUserDetail = !_showUserDetail;
                  });
                },
              );
            }
          }),
          Expanded(
              child: _showUserDetail
                  ? _buildUserNavigationWidgetList()
                  : _buildFunctionNavWidgetList())
        ],
      )),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: _bottomNavigationbarIndex,
        items: [
          BottomNavigationBarItem(
              icon: new Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: S.of(context).index),
          BottomNavigationBarItem(
              icon: new Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: S.of(context).dashboard),
          BottomNavigationBarItem(
              icon: new Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: S.of(context).notification),
          BottomNavigationBarItem(
              icon: new Icon(Icons.stars_outlined),
              activeIcon: Icon(Icons.stars),
              label: S.of(context).favorites),
          BottomNavigationBarItem(
              icon: new Icon(Icons.message_outlined),
              activeIcon: Icon(Icons.message_rounded),
              label: S.of(context).chatMessage),
        ],
        onTap: (index) {
          setState(() {
            _bottomNavigationbarIndex = index;
          });
        },
      ),
      body: [DiscuzPortalScreen(),HotThreadScreen(),NotificationScreen(),
        NotificationScreen(),DiscuzMessageScreen()
      ][_bottomNavigationbarIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerSwitchDiscuzDialog,
        tooltip: S.of(context).addNewDiscuz,
        child: Icon(Icons.account_tree),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
