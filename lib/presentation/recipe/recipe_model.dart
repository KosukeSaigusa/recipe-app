import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe/domain/recipe.dart';

class RecipeModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String userId;
  String recipeDocumentId;
  String recipeOwnerId;
  String name = '';
  String imageURL = '';
  String content = '';
  String createdAt = '';
  bool isPublic = false;
  bool isMyRecipe;
  Recipe recipe;

  RecipeModel(recipeDocumentId, recipeOwnerId) {
    this.recipeDocumentId = recipeDocumentId;
    this.recipeOwnerId = recipeOwnerId;
    this.userId = _auth.currentUser.uid;
    this.isMyRecipe = recipeOwnerId == this.userId;
    this.fetchRecipe();
  }

  Future fetchRecipe() async {
    startLoading();
    DocumentSnapshot doc;
    if (isMyRecipe == true) {
      this.isMyRecipe = true;

      /// レシピのドキュメント ID が "public_" から始まる場合は、
      /// それに対応する「わたしのレシピ」を取得する
      if (this.recipeDocumentId.startsWith('public_')) {
        doc = await FirebaseFirestore.instance
            .collection('users/${this.userId}/recipes')
            .doc(this.recipeDocumentId.replaceFirst('public_', ''))
            .get();
      } else {
        doc = await FirebaseFirestore.instance
            .collection('users/${this.userId}/recipes')
            .doc(this.recipeDocumentId)
            .get();
      }
    } else {
      this.isMyRecipe = false;
      doc = await FirebaseFirestore.instance
          .collection('public_recipes')
          .doc(this.recipeDocumentId)
          .get();
    }

    this.recipe = Recipe(doc);
    this.recipe.isMyRecipe = this.isMyRecipe;
    this.name = recipe.name;
    this.imageURL = recipe.imageURL;
    this.content = recipe.content;
    this.createdAt = recipe.createdAt.toString();
    this.isPublic = recipe.isPublic;

    endLoading();
    notifyListeners();
  }

  void startLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = false;
    notifyListeners();
  }
}
