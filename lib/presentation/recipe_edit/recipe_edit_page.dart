import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe/common/text_dialog.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/presentation/recipe_edit/recipe_edit_model.dart';
import 'package:recipe/presentation/top/top_page.dart';

class RecipeEditPage extends StatelessWidget {
  RecipeEditPage(this.recipe);
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeEditModel>(
      create: (_) => RecipeEditModel(this.recipe),
      child: Consumer<RecipeEditModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(36.0),
              child: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                centerTitle: true,
                title: Text(
                  'レシピの編集',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: <Widget>[
                  model.isLoading
                      ? SizedBox()
                      : model.currentRecipe.isMyRecipe
                          ? IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 20.0,
                              ),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text('レシピを削除しますか？'),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('OK'),
                                          onPressed: () async {
                                            await model.deleteRecipe();
                                            await Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TopPage(),
                                                ),
                                                (_) => false);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            )
                          : SizedBox(),
                ],
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      right: 16.0,
                      bottom: 48.0,
                      left: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        model.currentRecipe.isPublic
                            ? Container(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  color: Color(0xFFF39800),
                                  child: Text(
                                    '公開中',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(4.0),
                                color: Colors.grey,
                                child: Text(
                                  '非公開',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: 16,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '1. レシピ名',
                              ),
                              TextSpan(
                                text: '（必須）',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          initialValue: model.editedRecipe.name,
                          textInputAction: TextInputAction.done,
                          onChanged: (text) {
                            model.changeRecipeName(text);
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: 'レシピ名',
                            border: OutlineInputBorder(),
                            errorText:
                                model.errorName == '' ? null : model.errorName,
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '2. 写真',
                              ),
                              TextSpan(
                                text: '（タップして変更可能）',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 150,
                          child: InkWell(
                            onTap: () async {
                              await model.showImagePicker();
                            },
                            child: SizedBox(
                              width: 200,
                              height: 150,
                              child: model.isLoading
                                  ? Container(
                                      color: Color(0xFFDADADA),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Loading...',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : model?.imageFile == null
                                      ? model.currentRecipe.imageURL == null ||
                                              model.currentRecipe.imageURL
                                                  .isEmpty
                                          ? SizedBox(
                                              width: 200,
                                              height: 150,
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    color: Color(0xFFDADADA),
                                                  ),
                                                  Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .add_photo_alternate,
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          'タップして画像を追加',
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  '${model.currentRecipe.imageURL}',
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: Color(0xFFDADADA),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'Loading...',
                                                      style: TextStyle(
                                                        fontSize: 12.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      //Icon(Icons.error),
                                                      Container(
                                                color: Color(0xFFDADADA),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons.error_outline,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                      : Image.file(
                                          model?.imageFile,
                                        ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(text: '3. 作り方・材料'),
                              TextSpan(
                                text: '（必須）',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          initialValue: model.editedRecipe.content,
                          onChanged: (text) {
                            model.changeRecipeContent(text);
                          },
                          minLines: 12,
                          maxLines: 20,
                          decoration: InputDecoration(
                            labelText: 'レシピの内容（作り方・材料）',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                            errorText: model.errorContent == ''
                                ? null
                                : model.errorContent,
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          '4. 参考にしたレシピ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          initialValue: model.editedRecipe.reference,
                          onChanged: (text) {
                            model.changeRecipeReference(text);
                          },
                          minLines: 3,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: '参考にしたレシピのURLや書籍名を記入',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        model.currentRecipe.isPublic

                            /// 元々公開されていたレシピの場合
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '5. 確認',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        activeColor: Color(0xFFF39800),
                                        checkColor: Colors.white,
                                        value: model.agreed,
                                        onChanged: (val) {
                                          model.tapAgreeCheckBox(val);
                                        },
                                      ),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '公開するレシピの',
                                              ),
                                              TextSpan(
                                                text: 'ガイドライン',
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'を読んで同意しました。',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )

                            /// 元々公開されていなかったレシピの場合
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '5. 公開',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        activeColor: Color(0xFFF39800),
                                        checkColor: Colors.white,
                                        value: model.agreed,
                                        onChanged: (val) {
                                          model.tapAgreeCheckBox(val);
                                        },
                                      ),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '公開するレシピの',
                                              ),
                                              TextSpan(
                                                text: 'ガイドライン',
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'を読んで同意しました。',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                        SizedBox(
                          height: 16.0,
                        ),

                        /// 元々公開されていたレシピの場合
                        model.currentRecipe.isPublic
                            ? Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: RaisedButton(
                                      child: Text(
                                        'レシピを更新する',
                                      ),
                                      color: Color(0xFFF39800),
                                      textColor: Colors.white,
                                      onPressed: model.isEdited &&
                                              model.agreed &&
                                              model.isNameValid &&
                                              model.isContentValid &&
                                              model.isReferenceValid
                                          ? () async {
                                              /// 公開で更新
                                              model.editedRecipe.isPublic =
                                                  true;
                                              await updateRecipe(
                                                  model, context);
                                            }
                                          : null,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: RaisedButton(
                                      child: Text(
                                        '公開を取り下げて更新する',
                                      ),
                                      color: Colors.grey,
                                      textColor: Colors.white,
                                      onPressed: model.isNameValid &&
                                              model.isContentValid &&
                                              model.isReferenceValid
                                          ? () async {
                                              /// 非公開で更新
                                              model.editedRecipe.isPublic =
                                                  false;
                                              await updateRecipe(
                                                  model, context);
                                            }
                                          : null,
                                    ),
                                  ),
                                ],
                              )

                            /// 元々公開されていなかったレシピの場合
                            : Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: RaisedButton(
                                      child: Text(
                                        'みんなのレシピに公開する',
                                      ),
                                      color: Color(0xFFF39800),
                                      textColor: Colors.white,
                                      onPressed: model.agreed &&
                                              model.isNameValid &&
                                              model.isContentValid &&
                                              model.isReferenceValid
                                          ? () async {
                                              /// 公開で更新
                                              model.editedRecipe.isPublic =
                                                  true;
                                              await updateRecipe(
                                                  model, context);
                                            }
                                          : null,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: RaisedButton(
                                      child: Text(
                                        'レシピを更新する',
                                      ),
                                      color: Colors.grey,
                                      textColor: Colors.white,
                                      onPressed: model.isEdited &&
                                              model.isNameValid &&
                                              model.isContentValid &&
                                              model.isReferenceValid
                                          ? () async {
                                              /// 非公開で更新
                                              model.editedRecipe.isPublic =
                                                  false;
                                              await updateRecipe(
                                                  model, context);
                                            }
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                      ],
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
                                      child: Text('レシピを更新しています...'),
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
            ),
          );
        },
      ),
    );
  }
}

Future updateRecipe(RecipeEditModel model, BuildContext context) async {
  model.startSubmitting();
  try {
    await model.updateRecipe();
    model.endSubmitting();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('レシピを更新しました。'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopPage(),
                    ),
                    (_) => false);
              },
            ),
          ],
        );
      },
    );
    Navigator.of(context).pop();
  } catch (e) {
    model.endSubmitting();
    showTextDialog(context, e.toString());
  }
}
