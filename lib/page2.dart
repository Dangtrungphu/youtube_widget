import 'package:flutter/material.dart';
import 'package:youtube_widget/youtube_player_flutter/index.dart';

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: InkWell(
              child: Container(
                height: 80,
                width: 200,
                color: Colors.blue,
                child: Center(child: Text('Open "Old Town Road"')),
              ),
              onTap: () {
                ActionYoutubeController().openPopup('r7qovpFAGrQ');
              },
            )),
            Center(
                child: InkWell(
              child: Container(
                height: 80,
                width: 200,
                color: Colors.blue,
                child: Center(child: Text('Open "Một triệu like"')),
              ),
              onTap: () {
                ActionYoutubeController().openPopup('oigiXW6XyCQ');
              },
            )),
            Container(
              margin: EdgeInsets.only(top: 30),
                child: InkWell(
              child: Container(
                height: 80,
                width: 200,
                color: Colors.green,
                child: Center(child: Text(' <-- Back')),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
