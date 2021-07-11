import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class ChooseThemeColorPage extends StatefulWidget {
  @override
  _ChooseThemeColorState createState() => _ChooseThemeColorState();
}

class _ChooseThemeColorState extends State<ChooseThemeColorPage> {

  String _selectedColorName = "";

  @override
  Widget build(BuildContext context) {

    _selectedColorName = Provider.of<ThemeNotifierProvider>(context,listen: false).themeColorName;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).chooseThemeTitle),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
              title: S.of(context).colorGrey,
              trailing: trailingWidget("grey"),
              onPressed: (BuildContext context) {
                changeColor("grey");
              },
            ),
            SettingsTile(
              title: S.of(context).colorBlue,
              trailing: trailingWidget("blue"),
              onPressed: (BuildContext context) {
                changeColor("blue");
              },
            ),
            SettingsTile(
              title: S.of(context).colorBlueAccent,
              trailing: trailingWidget("blueAccent"),
              onPressed: (BuildContext context) {
                changeColor("blueAccent");
              },
            ),
            SettingsTile(
              title: S.of(context).colorCyan,
              trailing: trailingWidget("cyan"),
              onPressed: (BuildContext context) {
                changeColor("cyan");
              },
            ),
            SettingsTile(
              title: S.of(context).colorDeepPurple,
              trailing: trailingWidget("deepPurple"),
              onPressed: (BuildContext context) {
                changeColor("deepPurple");
              },
            ),
            SettingsTile(
              title: S.of(context).colorDeepPurpleAccent,
              trailing: trailingWidget("deepPurpleAccent"),
              onPressed: (BuildContext context) {
                changeColor("deepPurpleAccent");
              },
            ),
            SettingsTile(
              title: S.of(context).colorDeepOrange,
              trailing: trailingWidget("deepOrange"),
              onPressed: (BuildContext context) {
                changeColor("deepOrange");
              },
            ),
            SettingsTile(
              title: S.of(context).colorGreen,
              trailing: trailingWidget("green"),
              onPressed: (BuildContext context) {
                changeColor("green");
              },
            ),
            SettingsTile(
              title: S.of(context).colorIndigo,
              trailing: trailingWidget("indigo"),
              onPressed: (BuildContext context) {
                changeColor("indigo");
              },
            ),
            SettingsTile(
              title: S.of(context).colorIndigoAccent,
              trailing: trailingWidget("indigoAccent"),
              onPressed: (BuildContext context) {
                changeColor("indigoAccent");
              },
            ),
            SettingsTile(
              title: S.of(context).colorOrange,
              trailing: trailingWidget("orange"),
              onPressed: (BuildContext context) {
                changeColor("orange");
              },
            ),
            SettingsTile(
              title: S.of(context).colorPurple,
              trailing: trailingWidget("purple"),
              onPressed: (BuildContext context) {
                changeColor("purple");
              },
            ),
            SettingsTile(
              title: S.of(context).colorPink,
              trailing: trailingWidget("pink"),
              onPressed: (BuildContext context) {
                changeColor("pink");
              },
            ),
            SettingsTile(
              title: S.of(context).colorRed,
              trailing: trailingWidget("red"),
              onPressed: (BuildContext context) {
                changeColor("red");
              },
            ),
            SettingsTile(
              title: S.of(context).colorTeal,
              trailing: trailingWidget("teal"),
              onPressed: (BuildContext context) {
                changeColor("teal");
              },
            ),
            SettingsTile(
              title: S.of(context).colorBlack,
              trailing: trailingWidget("black"),
              onPressed: (BuildContext context) {
                changeColor("black");
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(String colorName) {
    return ( _selectedColorName == colorName)
        ? Icon(Icons.check, color: Theme.of(context).primaryColor)
        : Icon(null);
  }

  void changeColor(String colorName) {
    setState(() {
      _selectedColorName = colorName;
    });
    print("change theme color to $colorName");

    Provider.of<ThemeNotifierProvider>(context,listen: false).setTheme(colorName);
    UserPreferencesUtils.putThemeColor(colorName);
  }
}