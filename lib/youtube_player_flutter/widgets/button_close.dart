import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonClose extends StatelessWidget {
  final Function onTap;
  const ButtonClose({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
          padding: EdgeInsets.only(
            top: ScreenUtil().setWidth(10),
            left: ScreenUtil().setWidth(13),
            bottom: ScreenUtil().setWidth(10),
            right: ScreenUtil().setWidth(10),
          ),
          child: Image.asset(
            'assets/close.png',
            width: ScreenUtil().setWidth(17),
            height: ScreenUtil().setWidth(17),
            color: Colors.white,
          )
          ),
    );
  }
}
