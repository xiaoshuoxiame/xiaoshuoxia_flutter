import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:discuz_flutter/JsonResult/LoginResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/DBHelper.dart';
import 'package:discuz_flutter/utility/GlobalTheme.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/widget/ErrorCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:form_validator/form_validator.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class LoginPage extends StatelessWidget {
  late final Discuz discuz;

  LoginPage({required Key key, required this.discuz}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).signInTitle(discuz.siteName)),

        ),
        body: LoginForumFieldStatefulWidget(discuz));
  }
}

class LoginForumFieldStatefulWidget extends StatefulWidget {
  late final Discuz discuz;

  LoginForumFieldStatefulWidget(@required this.discuz){}
  @override
  _LoginFormFieldState createState() {
    // TODO: implement createState
    return _LoginFormFieldState(discuz);
  }
}

class _LoginFormFieldState
    extends State<LoginForumFieldStatefulWidget> {
  late final Discuz discuz;

  final _formKey = GlobalKey<FormState>();
  String error = "";
  ButtonState _loginState = ButtonState.idle;
  final TextEditingController _accountController = new TextEditingController();
  final TextEditingController _passwdController = new TextEditingController();

  _LoginFormFieldState(@required this.discuz){}

  void _verifyAccountAndPassword() async{
    // create a dio
    var dio =  Dio();
    PersistCookieJar cookieJar = await NetworkUtils.getTemporaryCookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    String account = _accountController.text;
    String password = _passwdController.text;

    log("Recv url " + discuz.baseURL);
    // check the availability
    final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
    setState(() {
      _loginState = ButtonState.loading;
    });

    // client.sendLoginRequestInString(account, password).then((value) {
    //   log(value);
    //   var res = LoginResult.fromJson(jsonDecode(value));
    //   log(res.toString());
    //
    // });

    client.sendLoginRequest(account,password).then((value) async {
      setState(() {

        error = "";
      });
      // check if the
      log("Recv a result ${value}");
      // if user is validated
      User user = value.loginVariables.getUser(discuz);
      if(value.errorResult!.key == "login_succeed"){
        // save it in database
        setState(() {
          _loginState = ButtonState.success;
        });
        try{
          final db = await DBHelper.getAppDb();
          final dao = db.userDao;
          // search in database first
          User? userInDataBase = await dao.findUsersByDiscuzIdAndUid(discuz.id!, user.uid);
          if(userInDataBase != null){
            user.id = userInDataBase.id;
          }

          int primaryKey = await dao.insert(user);

          // save it in cookiejar
          List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(discuz.baseURL));
          PersistCookieJar savedCookieJar = await NetworkUtils.getPersistentCookieJarByUserId(primaryKey);
          log("cookies ${cookies}");
          savedCookieJar.saveFromResponse(Uri.parse(discuz.baseURL), cookies);
          // pop the activity
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(S.of(context).signInSuccessTitle(user.username, discuz.siteName))));
          Navigator.pop(context);
        }
        catch(e,s){
          log("${e},${s}");
        }
      }
      else{
        setState(() {
          error = value.errorResult!.content;
          _loginState = ButtonState.fail;
        });
      }

    })
        .catchError((onError) {
      setState(() {
        error = onError.toString();
        _loginState = ButtonState.fail;
      });


      switch (onError.runtimeType) {

        case DioError:
          {
            error = onError.message;

            break;
          }
        default:
          {
            setState(() {
              error = onError.toString();
            });
          }
      }
    })
    ;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title and page
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 16.0),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: discuz.getDiscuzAvatarURL(),
                      progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => ListTile(
                        title: Text(discuz.siteName),
                        subtitle: Text(discuz.baseURL),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            discuz.siteName.length != 0
                                ? discuz.siteName[0].toUpperCase()
                                : S.of(context).anonymous,
                            style: TextStyle(color: Colors.white,fontSize: 18),
                          ),
                        ),
                      )
                    )
                  )),
              // input fields
              new TextFormField(
                controller: _accountController,
                decoration: new InputDecoration(

                  labelText: S.of(context).account,
                  hintText: S.of(context).account,
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: ValidationBuilder().required().build()
              ),
              new TextFormField(
                controller: _passwdController,
                decoration: new InputDecoration(

                  labelText: S.of(context).password,
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                obscureText: true,
                validator: ValidationBuilder().required().build()
              ),
              if (error.isNotEmpty)
                Column(
                  children: [
                    ErrorCard(S.of(context).error, error,(){
                      _verifyAccountAndPassword();
                    }),
                  ],
                ),

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 4.0),
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ProgressButton.icon(
                            maxWidth: 230.0,
                            iconedButtons: {
                              ButtonState.idle:
                              IconedButton(
                                  text: S.of(context).loginTitle,
                                  icon: Icon(Icons.login,color: Colors.white),
                                  color: Theme.of(context).primaryColor),
                              ButtonState.loading:
                              IconedButton(
                                  text: S.of(context).progressButtonLogining,
                                  color: Theme.of(context).primaryColorDark),
                              ButtonState.fail:
                              IconedButton(
                                  text: S.of(context).progressButtonLoginFailed,
                                  icon: Icon(Icons.cancel,color: Colors.white),
                                  color: Colors.red.shade300),
                              ButtonState.success:
                              IconedButton(
                                  text: S.of(context).progressButtonLoginSuccess,
                                  icon: Icon(Icons.check_circle,color: Colors.white,),
                                  color: Colors.green.shade400)
                            },
                            onPressed: (){
                              _verifyAccountAndPassword();
                            },
                            state: _loginState
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          
                            onPressed: (){

                        }, 
                            child: Text(S.of(context).forgetPassword,style: TextStyle(color:Colors.black54),),
                        ),
                      ),
                      Row(
                          children: <Widget>[
                            Expanded(
                                child: Divider()
                            ),

                            Text(S.of(context).or,style: TextStyle(color: Colors.black26),),

                            Expanded(
                                child: Divider()
                            ),
                          ]
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 0),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.open_in_browser),
                          label: Text(S.of(context).signInViaBrowser),
                            onPressed: (){

                            }, ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                            icon: Icon(Icons.app_registration),
                            label: Text(S.of(context).signUp),
                            onPressed: (){

                            }),
                      )

                    ],
                  ),
                ),
              ),

            ],
          ),
        ));
  }
}
