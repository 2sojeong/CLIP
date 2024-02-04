import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Future<Map<String, dynamic>> getDailyQuestList() async {
//   try {
//     DocumentSnapshot dailySnapshot = await _firestore.collection('questList').doc('daily').get();
//     Map<String, dynamic> questList = {};

//     for (var entry in dailySnapshot.data().entries) {
//       questList[entry.key] = entry.value;
//     }

//     return questList;
//   } catch (e) {
//     print('Error getting daily quest list: $e');
//     return {};
//   }
// }

Future<Map<String, dynamic>> getQuestInfo(
    String questName, String questType) async {
  try {
    DocumentSnapshot questSnapshot =
        await _firestore.collection('questList').doc(questType).get();
    Map<String, dynamic> questInfo =
        questSnapshot.data() as Map<String, dynamic>;

    // Check if the questInfo map is not null and contains the questName field
    if (questInfo != null && questInfo.containsKey(questName)) {
      // Retrieve the value of questName field
      dynamic questNameValue = questInfo[questName];

      // Optionally, you can create a new map with only the questName field
      Map<String, dynamic> result = {questName: questNameValue};

      return result;
    } else {
      print('Quest or field not found');
      return {};
    }
  } catch (e) {
    print('Error getting quest info: $e');
    return {};
  }
}

Future<List<Map<String, dynamic>>> getDailyQuestList() async {
  try {
    DocumentSnapshot questSnapshot =
        await _firestore.collection('questList').doc('daily').get();
    Map<String, dynamic> questList =
        questSnapshot.data() as Map<String, dynamic>;

    List<Map<String, dynamic>> result = [];

    // Convert the map entries to a list
    List<MapEntry<String, dynamic>> questEntries = questList.entries.toList();

    // Shuffle the list to get a random order
    questEntries.shuffle();

    // Take the first three entries (or less if there are fewer than three)
    List<MapEntry<String, dynamic>> selectedEntries =
        questEntries.take(3).toList();

    for (var entry in selectedEntries) {
      Map<String, dynamic> questInfo = {entry.key: entry.value};
      result.add(questInfo);
    }
    print(result);
    return result;
  } catch (e) {
    print('Error getting quest list: $e');
    return [];
  }
}
