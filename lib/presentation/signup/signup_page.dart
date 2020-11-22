import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/common/will_pop_scope.dart';
import 'package:recipe/presentation/signin/signin_page.dart';
import 'package:recipe/presentation/signup/signup_model.dart';
import 'package:recipe/presentation/top/top_page.dart';

class SignUpPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopCallback,
      child: ChangeNotifierProvider<SignUpModel>(
          create: (_) => SignUpModel()..init(),
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: AppBar(),
            ),
            body: Consumer<SignUpModel>(
              builder: (context, model, child) {
                return Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 96,
                                    child:
                                        Image.asset('lib/assets/icon_1024.png'),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              TextFormField(
                                controller: mailController,
                                onChanged: (text) {
                                  model.changeMail(text);
                                },
                                maxLines: 1,
                                decoration: InputDecoration(
                                  errorText: model.errorMail == ''
                                      ? null
                                      : model.errorMail,
                                  labelText: 'メールアドレス',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                controller: passwordController,
                                onChanged: (text) {
                                  model.changePassword(text);
                                },
                                obscureText: true,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  errorText: model.errorPassword == ''
                                      ? null
                                      : model.errorPassword,
                                  labelText: 'パスワード',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                controller: confirmController,
                                onChanged: (text) {
                                  model.changeConfirm(text);
                                },
                                obscureText: true,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  labelText: 'パスワード（確認用）',
                                  errorText: model.errorConfirm == ''
                                      ? null
                                      : model.errorConfirm,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: RaisedButton(
                                  child: Text('新規登録'),
                                  color: Color(0xFFF39800),
                                  textColor: Colors.white,
                                  onPressed: model.isMailValid &&
                                          model.isPasswordValid &&
                                          model.isConfirmValid
                                      ? () async {
                                          model.startLoading();
                                          try {
                                            await model.signUp();
                                            await Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TopPage(),
                                              ),
                                            );
                                            model.endLoading();
                                          } catch (e) {
                                            showTextDialog(context, e);
                                            model.endLoading();
                                          }
                                        }
                                      : null,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              FlatButton(
                                child: Text(
                                  'ログインはこちら',
                                ),
                                textColor: Color(0xFFF39800),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignInPage(),
                                    ),
                                  );
                                },
                              ),
                              model.isGuestAllowed
                                  ? FlatButton(
                                      child: Text(
                                        'ゲストとして利用',
                                      ),
                                      textColor: Colors.grey,
                                      onPressed: () async {
                                        model.startLoading();
                                        try {
                                          await model.signInAnonymously();
                                          model.endLoading();
                                          await Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TopPage(),
                                            ),
                                          );
                                        } catch (e) {
                                          showTextDialog(context, e.toString());
                                          model.endLoading();
                                        }
                                      },
                                    )
                                  : SizedBox(),
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
                  ],
                );
              },
            ),
          )),
    );
  }
}
