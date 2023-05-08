import 'package:flutter/material.dart';
import 'package:youtube_widget/page2.dart';
import 'package:youtube_widget/youtube_player_flutter/index.dart';

class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    var items = List<dynamic>.generate(
        1000,
        (i) => i % 2 == 0 && i % 6 != 0
            ? MessageItem('Một triệu like $i', '')
            : i % 2 == 0 && i % 6 == 0
                ? HeadingItem('Old Town Road $i')
                : i % 3 == 0
                    ? HeadingItem('Background trắng $i')
                    : MessageItem('Video dọc $i', ''));

    return Scaffold(
      body: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Page2(),
                ),
              );
            },
            child: Container(
              height: 50,
              width: 150,
              margin: const EdgeInsets.only(bottom: 20, top: 20),
              color: Colors.redAccent,
              child: const Center(
                  child: Text(
                'Open page 2',
                style: TextStyle(
                  color: Colors.white,
                ),
              )),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: item.buildTitle(context),
                subtitle: item.buildSubtitle(context),
                onTap: () {
                  var url = index % 2 == 0 && index % 6 != 0
                      ? 'oigiXW6XyCQ'
                      : index % 2 == 0 && index % 6 == 0
                          ? 'r7qovpFAGrQ'
                          : index % 3 == 0
                              ? 'ZwHhc-WGkFE'
                              : '61lOEvHLWkw';
                  ActionYoutubeController()
                      .openPopup(url, isVideoVertical: url == '61lOEvHLWkw');
                },
              );
            },
          ))
        ],
      ),
    );
  }
}

abstract class ListItem {
  Widget buildTitle(BuildContext context);

  Widget buildSubtitle(BuildContext context);
}

class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}
