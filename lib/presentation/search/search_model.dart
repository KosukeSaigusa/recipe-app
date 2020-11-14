import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/common/text_process.dart';
import 'package:recipe/domain/recipe.dart';
import 'package:recipe/domain/recipe_tab.dart';
import 'package:recipe/presentation/signin/signin_page.dart';

class SearchModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  MyRecipeTab myRecipeTab;
  PublicRecipeTab publicRecipeTab;
  String userId;
  int loadLimit;
  bool canReload;

  SearchModel() {
    this.myRecipeTab = MyRecipeTab();
    this.publicRecipeTab = PublicRecipeTab();
    this._auth = FirebaseAuth.instance;
    this.userId = '';
    this.loadLimit = 10;
    this.canReload = true;
  }

  Future<void> fetchRecipes(context) async {
    startMyTabLoading();
    startPublicTabLoading();
    if (_auth.currentUser == null) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(),
        ),
      );
    } else {
      this.userId = _auth.currentUser.uid;
    }
    await loadMyRecipes();
    await loadPublicRecipes();
    notifyListeners();
  }

  Future<void> loadMyRecipes() async {
    startMyTabLoading();

    /// わたしのレシピ
    QuerySnapshot _mySnap = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('updatedAt', descending: true)
        .limit(this.loadLimit)
        .get();

    /// 取得するレシピが1件以上あるか確認
    if (_mySnap.docs.length == 0) {
      /// 1件も存在しない場合
      this.myRecipeTab.existsRecipe = false;
      this.myRecipeTab.canLoadMore = false;
      this.myRecipeTab.recipes = [];
    } else if (_mySnap.docs.length < this.loadLimit) {
      /// 1件以上10件未満存在する場合
      this.myRecipeTab.existsRecipe = true;
      this.myRecipeTab.canLoadMore = false;
      this.myRecipeTab.lastVisible = _mySnap.docs[_mySnap.docs.length - 1];
      final _myRecipes = _mySnap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.recipes = _myRecipes;
    } else {
      /// 10件以上存在する場合
      this.myRecipeTab.existsRecipe = true;
      this.myRecipeTab.canLoadMore = true;
      this.myRecipeTab.lastVisible = _mySnap.docs[_mySnap.docs.length - 1];
      final _myRecipes = _mySnap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.recipes = _myRecipes;
    }

    endMyTabLoading();
    notifyListeners();
  }

  Future<void> loadPublicRecipes() async {
    startPublicTabLoading();

    QuerySnapshot _publicSnap = await FirebaseFirestore.instance
        .collection('public_recipes')
        .where('isPublic', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .limit(this.loadLimit)
        .get();

    /// 取得するレシピが1件以上あるか確認
    if (_publicSnap.docs.length == 0) {
      /// 1件も存在しない場合
      this.publicRecipeTab.existsRecipe = false;
      this.publicRecipeTab.canLoadMore = false;
      this.publicRecipeTab.recipes = [];
    } else if (_publicSnap.docs.length < this.loadLimit) {
      /// 1件以上10件未満存在する場合
      this.publicRecipeTab.existsRecipe = true;
      this.publicRecipeTab.canLoadMore = false;
      this.publicRecipeTab.lastVisible =
          _publicSnap.docs[_publicSnap.docs.length - 1];
      final _publicRecipes =
          _publicSnap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.recipes = _publicRecipes;
    } else {
      /// 10件以上存在する場合
      this.publicRecipeTab.existsRecipe = true;
      this.publicRecipeTab.canLoadMore = true;
      this.publicRecipeTab.lastVisible =
          _publicSnap.docs[_publicSnap.docs.length - 1];
      final _publicRecipes =
          _publicSnap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.recipes = _publicRecipes;
    }

    endPublicTabLoading();
    notifyListeners();
  }

  /// わたしのレシピをさらに10件取得
  Future<void> loadMoreMyRecipes() async {
    startLoadingMoreMyRecipe();

    QuerySnapshot _snap = await FirebaseFirestore.instance
        .collection('users/${this.userId}/recipes')
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(this.myRecipeTab.lastVisible)
        .limit(this.loadLimit)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.myRecipeTab.canLoadMore = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.myRecipeTab.canLoadMore = false;
      this.myRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.recipes.addAll(_moreRecipes);
    } else {
      this.myRecipeTab.canLoadMore = true;
      this.myRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.recipes.addAll(_moreRecipes);
    }

    endLoadingMoreMyRecipe();
    notifyListeners();
  }

  /// みんなのレシピをさらに10件取得
  Future loadMorePublicRecipes() async {
    startLoadingMorePublicRecipe();

    QuerySnapshot _snap = await FirebaseFirestore.instance
        .collection('public_recipes')
        .where('isPublic', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(this.publicRecipeTab.lastVisible)
        .limit(this.loadLimit)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.publicRecipeTab.canLoadMore = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.publicRecipeTab.canLoadMore = false;
      this.publicRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.recipes.addAll(_moreRecipes);
    } else {
      this.publicRecipeTab.canLoadMore = true;
      this.publicRecipeTab.lastVisible = _snap.docs[_snap.docs.length - 1];
      final _moreRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.recipes.addAll(_moreRecipes);
    }

    endLoadingMorePublicRecipe();
    notifyListeners();
  }

  Future filterMyRecipe(String input) async {
    /// ステイタスを検索中に更新
    startMyRecipeFiltering();

    /// 検索文字数が2文字に満たない場合は検索を行わず、検索結果のリストを空にする
    if (input.length < 2) {
      this.myRecipeTab.filteredRecipes = [];
      endMyRecipeFiltering();
      return;
    }

    /// 検索用フィールドに入力された文字列の前処理
    List<String> _words = input.trim().split(' ');

    /// 文字列のリストを渡して、bi-gram を実行
    List tokens = tokenize(_words);

    /// クエリの生成（bi-gram の結果のトークンマップを where 句に反映）
    Query _query =
        FirebaseFirestore.instance.collection('users/$userId/recipes');
    tokens.forEach((word) {
      _query =
          _query.where('tokenMap.$word', isEqualTo: true).limit(this.loadLimit);
    });

    /// 検索に用いたクエリをクラス変数に保存
    this.myRecipeTab.filterQuery = _query;

    QuerySnapshot _snap = await _query.get();

    /// 絞り込んだレシピが1件以上あるか確認
    if (_snap.docs.length == 0) {
      this.myRecipeTab.existsFilteredRecipe = false;
      this.myRecipeTab.canLoadMoreFiltered = false;
      this.myRecipeTab.filteredRecipes = [];
    } else if (_snap.docs.length < this.loadLimit) {
      this.myRecipeTab.existsFilteredRecipe = true;
      this.myRecipeTab.canLoadMoreFiltered = false;
      this.myRecipeTab.filteredLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.filteredRecipes = _filteredRecipes;
    } else {
      this.myRecipeTab.existsFilteredRecipe = true;
      this.myRecipeTab.canLoadMoreFiltered = true;
      this.myRecipeTab.filteredLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.filteredRecipes = _filteredRecipes;
    }

    /// ステイタスを検索終了に更新
    endMyRecipeFiltering();
    notifyListeners();
  }

  Future<void> filterPublicRecipe(String input) async {
    /// ステイタスを検索中に更新
    startPublicRecipeFiltering();

    /// 検索文字数が2文字に満たない場合は検索を行わず、検索結果のリストを空にする
    if (input.length < 2) {
      this.publicRecipeTab.filteredRecipes = [];
      endPublicRecipeFiltering();
      return;
    }

    /// 検索用フィールドに入力された文字列の前処理
    List<String> _words = input.trim().split(' ');

    /// 文字列のリストを渡して、bi-gram を実行
    List tokens = tokenize(_words);

    /// クエリの生成（bi-gram の結果のトークンマップを where 句に反映）
    Query _query = FirebaseFirestore.instance
        .collection('public_recipes')
        .where('isPublic', isEqualTo: true);
    tokens.forEach((word) {
      _query =
          _query.where('tokenMap.$word', isEqualTo: true).limit(this.loadLimit);
    });

    /// 検索に用いたクエリをクラス変数に保存
    this.publicRecipeTab.filterQuery = _query;

    QuerySnapshot _snap = await _query.get();

    /// 絞り込んだレシピが1件以上あるか確認
    if (_snap.docs.length == 0) {
      this.publicRecipeTab.existsFilteredRecipe = false;
      this.publicRecipeTab.canLoadMoreFiltered = false;
      this.publicRecipeTab.filteredRecipes = [];
    } else if (_snap.docs.length < this.loadLimit) {
      this.publicRecipeTab.existsFilteredRecipe = true;
      this.publicRecipeTab.canLoadMoreFiltered = false;
      this.publicRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.filteredRecipes = _filteredRecipes;
    } else {
      this.publicRecipeTab.existsFilteredRecipe = true;
      this.publicRecipeTab.canLoadMoreFiltered = true;
      this.publicRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.filteredRecipes = _filteredRecipes;
    }

    /// ステイタスを検索終了に更新
    endPublicRecipeFiltering();
    notifyListeners();
  }

  Future<void> loadMoreFilteredMyRecipes() async {
    startLoadingMoreMyRecipe();

    /// 前回の検索クエリを元にスナップショットを取得
    QuerySnapshot _snap = await this
        .myRecipeTab
        .filterQuery
        .startAfterDocument(this.myRecipeTab.filteredLastVisible)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.myRecipeTab.canLoadMoreFiltered = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.myRecipeTab.canLoadMoreFiltered = false;
      this.myRecipeTab.filteredLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    } else {
      this.myRecipeTab.canLoadMoreFiltered = true;
      this.myRecipeTab.filteredLastVisible = _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.myRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    }

    endLoadingMoreMyRecipe();
    notifyListeners();
  }

  Future<void> loadMoreFilteredPublicRecipes() async {
    startLoadingMorePublicRecipe();

    /// 前回の検索クエリを元にスナップショットを取得
    QuerySnapshot _snap = await this
        .publicRecipeTab
        .filterQuery
        .startAfterDocument(this.publicRecipeTab.filteredLastVisible)
        .get();

    /// 新たに取得するレシピが残っているか確認
    if (_snap.docs.length == 0) {
      this.publicRecipeTab.canLoadMoreFiltered = false;
    } else if (_snap.docs.length < this.loadLimit) {
      this.publicRecipeTab.canLoadMoreFiltered = false;
      this.publicRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    } else {
      this.publicRecipeTab.canLoadMoreFiltered = true;
      this.publicRecipeTab.filteredLastVisible =
          _snap.docs[_snap.docs.length - 1];
      final _filteredRecipes = _snap.docs.map((doc) => Recipe(doc)).toList();
      this.publicRecipeTab.filteredRecipes.addAll(_filteredRecipes);
    }

    endLoadingMorePublicRecipe();
    notifyListeners();
  }

  void startMyTabLoading() {
    this.myRecipeTab.isLoading = true;
    notifyListeners();
  }

  void endMyTabLoading() {
    this.myRecipeTab.isLoading = false;
    notifyListeners();
  }

  void startPublicTabLoading() {
    this.publicRecipeTab.isLoading = true;
    notifyListeners();
  }

  void endPublicTabLoading() {
    this.publicRecipeTab.isLoading = false;
    notifyListeners();
  }

  void startMyRecipeFiltering() {
    this.myRecipeTab.isFiltering = true;
    notifyListeners();
  }

  void startLoadingMoreMyRecipe() {
    this.myRecipeTab.isLoadingMore = true;
    notifyListeners();
  }

  void endLoadingMoreMyRecipe() {
    this.myRecipeTab.isLoadingMore = false;
    notifyListeners();
  }

  void startLoadingMorePublicRecipe() {
    this.publicRecipeTab.isLoadingMore = true;
    notifyListeners();
  }

  void endLoadingMorePublicRecipe() {
    this.publicRecipeTab.isLoadingMore = false;
    notifyListeners();
  }

  void endMyRecipeFiltering() {
    this.myRecipeTab.isFiltering = false;
    notifyListeners();
  }

  void startPublicRecipeFiltering() {
    this.publicRecipeTab.isFiltering = true;
    notifyListeners();
  }

  void endPublicRecipeFiltering() {
    this.publicRecipeTab.isFiltering = false;
    notifyListeners();
  }

  void changeMySearchWords(text) {
    if (text.length == 1) {
      this.myRecipeTab.errorText = '検索ワードは2文字以上で入力して下さい。';
    } else if (text.length > 50) {
      this.myRecipeTab.errorText = '検索ワードは50文字以内で入力して下さい。';
    } else {
      this.myRecipeTab.errorText = '';
    }
    notifyListeners();
  }

  void changePublicSearchWords(text) {
    if (text.length == 1) {
      this.publicRecipeTab.errorText = '検索ワードは2文字以上で入力して下さい。';
    } else if (text.length > 50) {
      this.publicRecipeTab.errorText = '検索ワードは50文字以内で入力して下さい。';
    } else {
      this.publicRecipeTab.errorText = '';
    }
    notifyListeners();
  }
}
