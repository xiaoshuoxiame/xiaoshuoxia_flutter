import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/page/ChooseInterfaceBrightnessPage.dart';
import 'package:discuz_flutter/page/ChoosePlatformPage.dart';
import 'package:discuz_flutter/page/ChooseTypeSettingScalePage.dart';
import 'package:discuz_flutter/page/SelectSignatureStylePage.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ChooseThemeColorPage.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  bool recordHistory = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreference();
  }

  void getPreference() async {
    recordHistory = await UserPreferencesUtils.getRecordHistoryEnabled();
    setState(() {
      recordHistory = recordHistory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(S.of(context).settingTitle)),
      iosContentPadding: true,
      body: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {

    return Consumer<ThemeNotifierProvider>(builder: (context, themeEntity, _) {

      return Consumer<TypeSettingNotifierProvider>(builder: (context, typeSetting, _) {
        return SettingsList(
          sections: [
            SettingsSection(
              title: Text(S.of(context).common),
              tiles: [
                SettingsTile.switchTile(
                  title: Text(S.of(context).recordHistoryTitle),
                  description: Text(recordHistory
                      ? S.of(context).recordHistoryOnDescription
                      : S.of(context).recordHistoryOffDescription),
                  leading: Icon(PlatformIcons(context).bookmarkOutline),
                  //switchValue: recordHistory,
                  activeSwitchColor: Theme.of(context).primaryColor,
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    print("set record history ${value} ");
                    UserPreferencesUtils.putRecordHistoryEnabled(value);
                    setState(() {
                      recordHistory = value;
                    });
                  }, initialValue: recordHistory,
                ),
              ],
            ),
            SettingsSection(
              title: Text(S.of(context).displaySettingTitle),
              tiles: [
                SettingsTile(
                  title: Text(S.of(context).chooseThemeTitle),
                  trailing: Text(themeEntity.getColorName(context)),
                  leading: Icon(Icons.color_lens_outlined),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseThemeColorPage(),
                      context: context,
                    ));
                  },
                ),
                SettingsTile(
                  title: Text(S.of(context).appearanceOptimizedPlatform),
                  trailing: Text(themeEntity.getPlatformLocaleName(context)),
                  leading: Icon(PlatformIcons(context).home),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChoosePlatformPage(),
                      context: context,
                    ));
                  },
                ),
                SettingsTile.switchTile(
                  title: Text(S.of(context).useMaterial3Title),
                  description: themeEntity.useMaterial3
                      ? Text(S.of(context).useMaterial3YesSubtitle)
                      : Text(S.of(context).useMaterial3NoSubtitle),
                  leading: Icon(Icons.style_outlined),
                  activeSwitchColor: Theme.of(context).primaryColor,
                  onToggle: (bool value) {
                    VibrationUtils.vibrateWithSwitchIfPossible();
                    UserPreferencesUtils.putMaterial3PropertyPreference(value);
                    Provider.of<ThemeNotifierProvider>(context,listen: false).setMaterial3(value);
                  }, initialValue: themeEntity.useMaterial3,
                ),
                SettingsTile(
                  title: Text(S.of(context).interfaceBrightness),
                  trailing: Text(themeEntity.getBrightnessName(context)),
                  leading: Icon(PlatformIcons(context).brightness),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseInterfaceBrightnessPage(),
                      context: context,
                    ));
                  },
                ),
                SettingsTile(
                  title: Text(S.of(context).typeSetting),
                  trailing: Text(S.of(context).fontSizeScaleParameterUnit(typeSetting.scalingParameter.toStringAsFixed(3))),
                  leading: Icon(Icons.format_size_outlined),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => ChooseTypeSettingScalePage(),
                      context: context,
                    ));
                  },
                )


              ],
            ),
            SettingsSection(
              title: Text(S.of(context).post),
              tiles: [
                SettingsTile(
                  title: Text(S.of(context).signatureStyle),
                  leading: Icon(PlatformIcons(context).pen),
                  onPressed: (context) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    Navigator.of(context).push(platformPageRoute(
                      builder: (_) => Provider<SignaturePreferenceNotifier>(
                        create: (_) => SignaturePreferenceNotifier(),
                        child: SelectSignatureStylePage(),
                      ),
                      context: context,
                    ));
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Text(S.of(context).legalInformation),
              tiles: [
                SettingsTile(
                  title: Text(S.of(context).termsOfService),
                  leading: Icon(PlatformIcons(context).tagOutline),
                  onPressed: (_) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _launchURL("https://discuzhub.kidozh.com/term_of_use/");
                  },
                ),
                SettingsTile(
                  title: Text(S.of(context).privacyPolicy),
                  leading: Icon(PlatformIcons(context).tagOutline),
                  onPressed: (_) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _launchURL("https://discuzhub.kidozh.com/privacy_policy/");
                  },
                ),
                SettingsTile(
                  title: Text(S.of(context).openSourceLicence),
                  leading: Icon(PlatformIcons(context).tagOutline),
                  onPressed: (_) {
                    VibrationUtils.vibrateWithClickIfPossible();
                    _launchURL(
                        "https://discuzhub.kidozh.com/open_source_licence/");
                  },
                ),
              ],
            ),
            CustomSettingsSection(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22, bottom: 8),
                    child: Icon(
                      Icons.flutter_dash_rounded,
                      size: 54,
                    ),
                  ),
                  Text(
                    S.of(context).buildDescription,
                    style: TextStyle(color: Color(0xFF777777)),
                  ),
                ],
              ),
            ),
          ],
        );
      });

    });
  }

  double paragraphFontSize = 12.0;

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
