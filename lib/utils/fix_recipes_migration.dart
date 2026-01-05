import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/services/spoonacular_service.dart';

/// Migration utility to fix recipes missing ingredients/instructions
/// Run this once to update all existing recipes in Firestore
class FixRecipesMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SpoonacularService _apiService = SpoonacularService();

  // List of fake/test API IDs that should be skipped
  static const List<int> _fakeApiIds = [12345, 99999, 11111];

  /// Fix all recipes in household_recipes collection
  Future<void> fixHouseholdRecipes() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return;
      }

      // Get household ID
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final householdId = userDoc.data()?['current_household_id'];

      if (householdId == null) {
        debugPrint('❌ No household found');
        return;
      }

      debugPrint('');
      debugPrint('🔧 ========== FIXING HOUSEHOLD RECIPES ==========');
      debugPrint('   Household ID: $householdId');

      // Get all recipes
      final recipesSnapshot = await _firestore
          .collection('households')
          .doc(householdId)
          .collection('household_recipes')
          .get();

      debugPrint('   Found ${recipesSnapshot.docs.length} recipes');
      debugPrint('');

      int fixedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      for (var doc in recipesSnapshot.docs) {
        try {
          final data = doc.data();
          final recipeId = doc.id;
          final title = data['title'] ?? 'Unknown';
          final apiRecipeId = data['api_recipe_id'] as int?;

          final hasIngredients = data['ingredients'] != null &&
              (data['ingredients'] as List).isNotEmpty;
          final hasInstructions = data['instructions'] != null &&
              (data['instructions'] as String).isNotEmpty;

          if (hasIngredients && hasInstructions) {
            debugPrint(
                '✅ [$recipeId] "$title" - Already has full data, skipping');
            skippedCount++;
            continue;
          }

          if (apiRecipeId == null) {
            debugPrint(
                '⚠️ [$recipeId] "$title" - No API ID, cannot fetch data');
            errorCount++;
            continue;
          }

          // Skip fake/test API IDs
          if (_fakeApiIds.contains(apiRecipeId)) {
            debugPrint(
                '⏭️ [$recipeId] "$title" - Fake/test API ID ($apiRecipeId), skipping');
            skippedCount++;
            continue;
          }

          debugPrint('');
          debugPrint(
              '🔧 [$recipeId] "$title" - Missing data, fetching from API...');
          debugPrint('   - Has ingredients: $hasIngredients');
          debugPrint('   - Has instructions: $hasInstructions');
          debugPrint('   - API Recipe ID: $apiRecipeId');

          // Fetch full data from API
          final fullData = await _apiService.getRecipeInformation(apiRecipeId);

          if (fullData == null) {
            debugPrint('   ❌ Failed to fetch from API');
            errorCount++;
            continue;
          }

          // Parse ingredients
          List<dynamic> fullIngredients = [];
          if (fullData['extendedIngredients'] != null) {
            final List<dynamic> rawIngs = fullData['extendedIngredients'];
            fullIngredients = rawIngs.map((ing) {
              return {
                'name': ing['name'] ?? '',
                'amount': (ing['amount'] as num?)?.toDouble() ?? 0.0,
                'unit': ing['unit'] ?? '',
                'original': ing['original'] ?? '',
              };
            }).toList();
          }

          // Parse instructions
          String fullInstructions = '';
          if (fullData['analyzedInstructions'] != null &&
              (fullData['analyzedInstructions'] as List).isNotEmpty) {
            final List steps = fullData['analyzedInstructions'][0]['steps'];
            fullInstructions =
                steps.map<String>((step) => step['step'].toString()).join('\n');
            debugPrint(
                '   ✅ Parsed ${steps.length} instruction steps from analyzedInstructions');
          } else if (fullData['instructions'] != null) {
            fullInstructions = fullData['instructions'].toString();
            debugPrint(
                '   ✅ Got raw instructions: ${fullInstructions.length} chars');
          } else {
            debugPrint('   ⚠️ No instructions found in API response!');
          }

          debugPrint(
              '   📝 Final instructions length: ${fullInstructions.length} chars');

          // Update recipe
          await doc.reference.update({
            'ingredients': fullIngredients,
            'instructions': fullInstructions,
            'updated_at': FieldValue.serverTimestamp(),
          });

          debugPrint('   ✅ Updated with ${fullIngredients.length} ingredients');
          debugPrint(
              '   ✅ Updated instructions (${fullInstructions.length} chars)');
          fixedCount++;

          // Add small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint('   ❌ Error: $e');
          errorCount++;
        }
      }

      debugPrint('');
      debugPrint('🎉 ========== MIGRATION COMPLETE ==========');
      debugPrint('   ✅ Fixed: $fixedCount recipes');
      debugPrint('   ⏭️  Skipped: $skippedCount recipes (already complete)');
      debugPrint('   ❌ Errors: $errorCount recipes');
      debugPrint('==========================================');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ Migration error: $e');
    }
  }

  /// Fix all recipes in favorite_recipes collection
  Future<void> fixFavoriteRecipes() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        return;
      }

      // Get household ID
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final householdId = userDoc.data()?['current_household_id'];

      if (householdId == null) {
        debugPrint('❌ No household found');
        return;
      }

      debugPrint('');
      debugPrint('🔧 ========== FIXING FAVORITE RECIPES ==========');
      debugPrint('   Household ID: $householdId');

      // Get all favorite recipes
      final recipesSnapshot = await _firestore
          .collection('households')
          .doc(householdId)
          .collection('favorite_recipes')
          .get();

      debugPrint('   Found ${recipesSnapshot.docs.length} favorite recipes');
      debugPrint('');

      int fixedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      for (var doc in recipesSnapshot.docs) {
        try {
          final data = doc.data();
          final recipeId = doc.id;
          final title = data['title'] ?? 'Unknown';
          final apiRecipeId = data['api_recipe_id'] as int?;

          final hasIngredients = data['ingredients'] != null &&
              (data['ingredients'] as List).isNotEmpty;
          final hasInstructions = data['instructions'] != null &&
              (data['instructions'] as String).isNotEmpty;

          if (hasIngredients && hasInstructions) {
            debugPrint(
                '✅ [$recipeId] "$title" - Already has full data, skipping');
            skippedCount++;
            continue;
          }

          if (apiRecipeId == null) {
            debugPrint(
                '⚠️ [$recipeId] "$title" - No API ID, cannot fetch data');
            errorCount++;
            continue;
          }

          // Skip fake/test API IDs
          if (_fakeApiIds.contains(apiRecipeId)) {
            debugPrint(
                '⏭️ [$recipeId] "$title" - Fake/test API ID ($apiRecipeId), skipping');
            skippedCount++;
            continue;
          }

          debugPrint('');
          debugPrint(
              '🔧 [$recipeId] "$title" - Missing data, fetching from API...');
          debugPrint('   - Has ingredients: $hasIngredients');
          debugPrint('   - Has instructions: $hasInstructions');
          debugPrint('   - API Recipe ID: $apiRecipeId');

          // Fetch full data from API
          final fullData = await _apiService.getRecipeInformation(apiRecipeId);

          if (fullData == null) {
            debugPrint('   ❌ Failed to fetch from API');
            errorCount++;
            continue;
          }

          // Parse ingredients
          List<dynamic> fullIngredients = [];
          if (fullData['extendedIngredients'] != null) {
            final List<dynamic> rawIngs = fullData['extendedIngredients'];
            fullIngredients = rawIngs.map((ing) {
              return {
                'name': ing['name'] ?? '',
                'amount': (ing['amount'] as num?)?.toDouble() ?? 0.0,
                'unit': ing['unit'] ?? '',
                'original': ing['original'] ?? '',
              };
            }).toList();
          }

          // Parse instructions
          String fullInstructions = '';
          if (fullData['analyzedInstructions'] != null &&
              (fullData['analyzedInstructions'] as List).isNotEmpty) {
            final List steps = fullData['analyzedInstructions'][0]['steps'];
            fullInstructions =
                steps.map<String>((step) => step['step'].toString()).join('\n');
            debugPrint(
                '   ✅ Parsed ${steps.length} instruction steps from analyzedInstructions');
          } else if (fullData['instructions'] != null) {
            fullInstructions = fullData['instructions'].toString();
            debugPrint(
                '   ✅ Got raw instructions: ${fullInstructions.length} chars');
          } else {
            debugPrint('   ⚠️ No instructions found in API response!');
          }

          debugPrint(
              '   📝 Final instructions length: ${fullInstructions.length} chars');

          // Update recipe
          await doc.reference.update({
            'ingredients': fullIngredients,
            'instructions': fullInstructions,
            'updated_at': FieldValue.serverTimestamp(),
          });

          debugPrint('   ✅ Updated with ${fullIngredients.length} ingredients');
          debugPrint(
              '   ✅ Updated instructions (${fullInstructions.length} chars)');
          fixedCount++;

          // Add small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint('   ❌ Error: $e');
          errorCount++;
        }
      }

      debugPrint('');
      debugPrint('🎉 ========== MIGRATION COMPLETE ==========');
      debugPrint('   ✅ Fixed: $fixedCount recipes');
      debugPrint('   ⏭️  Skipped: $skippedCount recipes (already complete)');
      debugPrint('   ❌ Errors: $errorCount recipes');
      debugPrint('==========================================');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ Migration error: $e');
    }
  }

  /// Run both migrations
  Future<void> fixAllRecipes() async {
    debugPrint('');
    debugPrint('🚀 ========== STARTING RECIPE MIGRATION ==========');
    debugPrint('');

    await fixHouseholdRecipes();
    await fixFavoriteRecipes();

    debugPrint('');
    debugPrint('🎉 ========== ALL MIGRATIONS COMPLETE ==========');
    debugPrint('');
  }
}
