import 'package:flutter/material.dart';
import 'package:youtube_widget/page1.dart';

import 'youtube_player_flutter/index.dart';

void main() {
  return runApp(
    MyApp(    ),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    const title = 'Mixed List';
    final youtubeCustomBuilder = YoutubeCustomInit();

    return MaterialApp(
      title: title,
      builder: (context, child) {
        child = youtubeCustomBuilder(context, child);
        return child;
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: const Page1(),
      ),
    );
  }
}

