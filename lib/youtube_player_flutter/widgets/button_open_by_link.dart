import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ButtonOpenByLink extends StatefulWidget {
  final String url;
  const ButtonOpenByLink({Key? key, required this.url}) : super(key: key);

  @override
  State<ButtonOpenByLink> createState() => _ButtonOpenByLinkState();
}

class _ButtonOpenByLinkState extends State<ButtonOpenByLink> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _launchURL();
      },
      child: Container(
          padding: EdgeInsets.only(
            top: ScreenUtil().setWidth(10),
            left: ScreenUtil().setWidth(10),
            bottom: ScreenUtil().setWidth(10),
            right: ScreenUtil().setWidth(13),
          ),
          child: Image.asset(
            'assets/open_in_new.png',
            width: ScreenUtil().setWidth(17),
            height: ScreenUtil().setWidth(17),
            color: Colors.white,
          )
          ),
    );
  }

  _launchURL() async {
    if (Platform.isIOS) {
      if (await canLaunchUrlString(
          'youtube://https://www.youtube.com/watch?v=${widget.url}')) {
        await launchUrlString(
            'youtube://https://www.youtube.com/watch?v=${widget.url}',
            mode: LaunchMode.externalApplication);
      } else {
        if (await canLaunchUrlString(
            'https://www.youtube.com/watch?v=${widget.url}')) {
          await launchUrlString('https://www.youtube.com/watch?v=${widget.url}',
              mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch https://www.youtube.com/watch?v=${widget.url}';
        }
      }
    } else {
      var url = 'https://www.youtube.com/watch?v=${widget.url}';
      if (await canLaunchUrlString(url)) {
        await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
