## Module đang có

- Load video từ Youtube theo URL hoặc ID

- Cố định màn hình theo chiều dọc (*Không cho xoay ngang*)

- Có thể xem video full theo chiều dọc

- Mở video hiện tại sang app Youtube

- Có thể kéo video trên màn hình ở tất cả các page (*Neo cố định ở: Top, bottom*)

## Luồng chính
- Sẽ mở trước iframe với ID mặc định và ẩn nó đi (*để trách việc tải iframe lúc đầu làm chậm thời gian hiện video*)

- Khi load video thì chỉ hiện popup lên và load theo url

**=> Giúp cho việc mở video mượt và nhanh hơn.**
***
## Hướng dẫn sử dụng

### *Bắt đầu*

- Copy 2 file hình trong thư mục **assets** vào project gốc và khai báo nó ở  file **pubspec.yaml**

- Cài thêm các package sau:

        flutter_inappwebview: ^5.4.3+7

        flutter_screenutil: ^5.5.3+2

        url_launcher: ^6.1.5

        get: ^4.6.5

***

### *Sử dụng*

- Sử dụng moudle vào project chính

*main.dart*

<pre>import 'youtube_player_flutter/index.dart';</pre>

``` Dart
    return MaterialApp(
    title: title,
    builder: (context, child) {
        child = youtubeCustomBuilder(context, child); <-- HERE
        return child; <-- HERE
    },
    home: Scaffold(
        appBar: AppBar(
        title: const Text(title),
        ),
        body: const Page1(),
    ),
);  
```

- Các Action:

  - **openPopup**: Dùng để mở popup video

     ```Dart
     ActionYoutubeController().openPopup('url hoặc id_video', isVideoVertical: true/false );
    ```  

    - *isVideoVertical*: Mở video full theo chiều dọc


  - **closePopup**: Dùng để đóng popup video

    ```Dart
     ActionYoutubeController().closePopup();
    ```  

- Ví dụ:

``` Dart
    ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
            title: item.buildTitle(context),
            subtitle: item.buildSubtitle(context),
            onTap: () {
                ActionYoutubeController().openPopup('61lOEvHLWkw', isVideoVertical: true);
                },
            );
        },
    )
```

- Ghi chú các file

  - **raw_youtube_player.dart**: Chứa iframe Youtube, thực hiện việc tải video, lắng nghe các hành động từ **flutter** và thực hiện thông qua **javascript**

  - **youtube_player.dart**: Bao gồm iframe video và player chứa các action cho người dùng (*Nút tắt, timeline,....*)

  - **draggable_widget.dart**: Dùng để thực hiện việc kéo video trên màn hình, cố định ở *top* và *bottom*

  - **touch_shutter.dart**: Ẩn hiện các action khi chạm vào video. Thời gian ẩn sau khi nhấn là **3 giây**

### Nguồn

- <https://pub.dev/packages/youtube_player_flutter>

- <https://pub.dev/packages/youtube_player_iframe>

- <https://pub.dev/packages/draggable_widget>
