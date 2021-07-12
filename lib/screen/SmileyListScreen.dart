import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef SmileyPressedFunc = void Function(Smiley);

class SmileyListScreen extends StatelessWidget{
  SmileyPressedFunc onSmileyPressed;

  SmileyListScreen(this.onSmileyPressed);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SmileyListStatefulWidget(onSmileyPressed);
  }

}

class SmileyListStatefulWidget extends StatefulWidget{
  SmileyPressedFunc smileyValueGetter;

  SmileyListStatefulWidget(this.smileyValueGetter);

  @override
  State<SmileyListStatefulWidget> createState() {
    // TODO: implement createState
    return SmileyListState(this.smileyValueGetter);
  }

}

class SmileyListState extends State<SmileyListStatefulWidget>{
  SmileyPressedFunc smileyValueGetter;

  SmileyListState(this.smileyValueGetter);

  SmileyResult? result;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSmilesInfo();
  }

  void _loadSmilesInfo() async{
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (discuz == null){
      return;
    }
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    print("load smiley");
    client.smileyResult().then((value){
      print("load result ${value}");
      if(value.variables!=null){
        print("load smiley ${value.variables.smilies}");
      }
      setState(() {
        result = value;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Discuz? discuz = Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if(discuz == null){
      return NullDiscuzScreen();
    }
    else{
      if(result == null || result!.variables == null){
        return BlankScreen();
      }
      else{
        List<Tab> smileyTab = [];
        List<List<Smiley>> smileyList = result!.variables.smilies;
        print("Smiley ${smileyList.length}");
        for (int i=0; i< smileyList.length; i++){
          smileyTab.add(Tab(text: (i+1).toString(),));
        }
        List<Widget> tabBarViewList = [];
        for(int i =0;i <smileyList.length;i++){
          List<Smiley> currentSmiley = smileyList[i];
          List<Widget> smileyImageList = [];
          
          for(int j = 0; j< currentSmiley.length; j++){
            smileyImageList.add(
              InkWell(
                onTap: (){
                  smileyValueGetter(currentSmiley[j]);
                },
                child: CachedNetworkImage(
                  imageUrl: discuz.baseURL+"/static/image/smiley/"+currentSmiley[j].relativePath,
                  progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.image_not_supported),
                  )
                ),

              );
          }
          
          tabBarViewList.add(
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 6,
                padding: EdgeInsets.all(4.0),
                children: smileyImageList,
              )
              );
        }
        print("SMiley ${smileyList.length}");
        return DefaultTabController(
            length: smileyTab.length,
            child: Column(
              children: [
                TabBar(tabs: smileyTab),
                SizedBox(
                    height: 100,
                    child: TabBarView(children: tabBarViewList))

              ],
            )
        );
      }

    }

  }


}
