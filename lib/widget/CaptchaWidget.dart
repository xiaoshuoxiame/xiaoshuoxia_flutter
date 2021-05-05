

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:discuz_flutter/JsonResult/CaptchaResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class CaptchaWidget extends StatelessWidget{

  Discuz _discuz;
  User? _user;
  String captchaType;
  Dio? dio;

  CaptchaWidget(this.dio,this._discuz, this._user, this.captchaType,{this.captchaController});

  CaptchaController? captchaController;

  @override
  Widget build(BuildContext context) {
    return CaptchaStatefulWidget(this.dio, _discuz, _user, captchaType,captchaController);
  }
}


class CaptchaStatefulWidget extends StatefulWidget{
  Discuz _discuz;
  User? _user;
  String captchaType;

  CaptchaController? captchaController;

  CaptchaStatefulWidget(this.dio,this._discuz, this._user, this.captchaType, this.captchaController);
  Dio? dio;

  @override
  State<StatefulWidget> createState() {
    return CaptchaState(dio, _discuz, _user, captchaType, captchaController);
  }


}

class CaptchaState extends State<CaptchaStatefulWidget>{
  Discuz _discuz;
  User? _user;
  String captchaType;
  late MobileApiClient _client;
  Dio? _dio;
  CaptchaController? captchaController;
  
  CaptchaVariable? captchaVariable;
  Uint8List? imageByte;

  TextEditingController _textEditingController = new TextEditingController();



  CaptchaState(this._dio,this._discuz, this._user, this.captchaType, this.captchaController);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initNetwork();
  }

  String _getCaptchaUrl(){
    return "${_discuz.baseURL}/api/mobile/index.php?module=seccode&sechash=${captchaVariable!.secHash}&version=4&type=$captchaType";
  }
  
  _initNetwork() async{
    if(_dio == null){
      print("load cookie for user ${_user!.username}");
      _dio = await NetworkUtils.getDioWithPersistCookieJar(_user);
    }


    _client = MobileApiClient(_dio!, baseUrl: _discuz.baseURL);
    _loadCaptchaInfo();
    _bindNotifier();
  }

  _bindNotifier(){
    _textEditingController.addListener(() {
      String verification = _textEditingController.text;
      if(captchaController!= null && captchaController!.value != null){
        captchaController!.value = CaptchaFields(captchaController!.value!.captchaFormHash, captchaController!.value!.fieldType, verification);
        captchaController!.notifyListeners();
      }
    });
    if(captchaController!= null){
      captchaController!.addListener(() {
        CaptchaFields? captchaFields = captchaController!.value;
        if (captchaFields == null){
          // trigger change if captcha fields is null
          _loadCaptchaInfo();
        }
      });
    }



  }
  
  _loadCaptchaInfo(){
    _client.captchaResult(this.captchaType).then((value) async {
      print(value.variables.secCodeURL);
      // the captcha html
      setState(() {
        captchaVariable = value.variables;
      });
      // refresh controller parameters
      if(captchaController != null){
        captchaController!.value = CaptchaFields(value.variables.secHash, captchaType, _textEditingController.text);
      }


      Response<ResponseBody> rs;
      rs = await _dio!.get<ResponseBody>(_getCaptchaUrl(),options: Options(
        responseType: ResponseType.stream,
        headers: {
          "Referer": value.variables.secCodeURL
        }
      ));
      if(rs.data!=null){
        rs.data!.stream.listen((event) {
          setState(() {
            imageByte = event;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(captchaVariable == null){
      // an empty container
      return Container(width: 0,height: 0,);
    }
    else{
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.bubble_chart),
                    hintText: S.of(context).captchaRequired
                ),
              )
          ),
          SizedBox(width: 8.0,),
          if(imageByte != null)
          GestureDetector(
            child: Image.memory(imageByte!),
            onTap: (){
              _loadCaptchaInfo();
            },
          )


        ],
      );
    }
    
  }



}


class CaptchaFields{
  String captchaFormHash = "";
  String fieldType = "";
  String verification = "";
  CaptchaFields(this.captchaFormHash, this.fieldType, this.verification);
}

class CaptchaController extends ValueNotifier<CaptchaFields?>{
  CaptchaController(CaptchaFields value) : super(value);

  @override
  set value(CaptchaFields? newValue) {
    // TODO: implement value
    super.value = newValue;
  }

  void reloadCaptcha(){
    super.value = null;
  }

}