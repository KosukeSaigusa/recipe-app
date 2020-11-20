import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:recipe/presentation/contact/contact_page.dart';
import 'package:recipe/presentation/display_name_update/display_name_update_page.dart';
import 'package:recipe/presentation/email_update/email_update_page.dart';
import 'package:recipe/presentation/link_anonymous_user/link_anonymous_user_page.dart';
import 'package:recipe/presentation/my_account/my_account_model.dart';
import 'package:recipe/presentation/password_update/password_update_page.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class MyAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // デバイスの画面サイズを取得
    final Size _size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<MyAccountModel>(
      create: (_) => MyAccountModel(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36.0),
          child: AppBar(
            title: Text(
              'メニュー',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: Consumer<MyAccountModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // 右スワイプ
                    if (details.delta.dx > 20) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.only(
                                    right: 16.0,
                                  ),
                                  width: double.infinity,
                                  height: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color(0xFFF39800),
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              model.showImagePicker();
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: model.imageFile == null
                                                  ? model.iconURL == null ||
                                                          model.iconURL.isEmpty
                                                      ? SizedBox(
                                                          width: 100,
                                                          height: 100,
                                                          child: Center(
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 50,
                                                            ),
                                                          ),
                                                        )
                                                      : CachedNetworkImage(
                                                          imageUrl:
                                                              '${model.iconURL}',
                                                          placeholder:
                                                              (context, url) =>
                                                                  Container(
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 50,
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(
                                                            Icons.person,
                                                            size: 50,
                                                          ),
                                                        )
                                                  : Image.file(model.imageFile),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24.0,
                                      ),
                                      Container(
                                        width: _size.width * 0.55 - 24.0,
                                        height: 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'メールアドレス：',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            model.mail == null
                                                ? Text('未登録（ゲスト）')
                                                : Text(
                                                    '${model.mail}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                            SizedBox(
                                              height: 4.0,
                                            ),
                                            Text(
                                              '表示名：',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            model.mail == null
                                                ? Text('未登録のユーザー')
                                                : model.displayName == null
                                                    ? SizedBox()
                                                    : Text(
                                                        '${model.displayName}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 16.0,
                                ),
                                model.mail == null
                                    ? FlatButton(
                                        textColor: Color(0xFFF39800),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LinkAnonymousUserPage(),
                                            ),
                                          );
                                          await model.fetchMyAccount();
                                        },
                                        child: Text('登録して利用する'),
                                      )
                                    : SizedBox(),
                                model.mail != null
                                    ? FlatButton(
                                        textColor: Color(0xFFF39800),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EmailUpdatePage(),
                                              fullscreenDialog: true,
                                            ),
                                          );
                                        },
                                        child: Text('メールアドレスの変更'),
                                      )
                                    : SizedBox(),
                                model.mail != null
                                    ? FlatButton(
                                        textColor: Color(0xFFF39800),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DisplayNameUpdatePage(),
                                              fullscreenDialog: true,
                                            ),
                                          );
                                        },
                                        child: Text('表示名の変更'),
                                      )
                                    : SizedBox(),
                                model.mail != null
                                    ? FlatButton(
                                        textColor: Color(0xFFF39800),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PasswordUpdatePage(),
                                              fullscreenDialog: true,
                                            ),
                                          );
                                        },
                                        child: Text('パスワードの変更'),
                                      )
                                    : SizedBox(),
                                model.mail != null
                                    ? FlatButton(
                                        textColor: Color(0xFFF39800),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ContactPage(),
                                              fullscreenDialog: true,
                                            ),
                                          );
                                        },
                                        child: Text('お問い合わせ'),
                                      )
                                    : SizedBox(),
                                model.mail != null
                                    ? FlatButton(
                                        textColor: Colors.grey,
                                        onPressed: () async {
                                          await model.signOut();
                                          await Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInPage(),
                                            ),
                                            (_) => false,
                                          );
                                        },
                                        child: Text('ログアウト'),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Version: ${model.version}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                model.isLoading
                    ? Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(),
                model.isSubmitting
                    ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.grey.withOpacity(0.7),
                        child: Center(
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 200,
                                  height: 150,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      child: Text('画像を変更しています...'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            );
          },
        ),
      ),
    );
  }
}
