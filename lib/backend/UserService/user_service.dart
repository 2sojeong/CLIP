import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/service/user_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

// Future<int> googleSingIn() async {
//   User currentUser;

//   final GoogleSignInAccount? account = await _googleSignIn.signIn();
//   final GoogleSignInAuthentication googleAuth = await account!.authentication;

//   final AuthCredential credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth.accessToken,
//     idToken: googleAuth.idToken,
//   );

//   UserCredential authResult = await _auth.signInWithCredential(credential);
//   User user = authResult.user!;
//   print(user.uid);

//   if (await userExistsInDB(user.uid)) {
//     //바로 메인으로 넘어가야함
//     return 1;
//   } else {
//     if (await createNewUserDocument(user.uid)) {
//       //닉네임, 주소 입력 페이지로 넘어가야함
//       return 2;
//     } else {
//       return 3;
//     }
//   }
// }

Future<bool> userExistsInDB(String uid) async {
  try {
    print('DB check: $uid');
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
    DocumentSnapshot documentSnapshot = await usersCollection.doc(uid).get();
    print(documentSnapshot.exists);
    return documentSnapshot.exists;
  } catch (e) {
    print('Error checking user existence: $e');
    return false;
  }
}

Future<bool> createNewUserDocument(String uid, String date) async {
  try {
    print('Creating new user document: $uid');
    // CollectionReference usersCollection =
    //     FirebaseFirestore.instance.collection('Users');
    // await usersCollection.doc(uid);

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .set({'address': 'address', 'friend': [], 'level': 1, 'nickname': 'nickname', 'point': 0, 'totalQuest': 0, 'profileUrl': 'profileUrl'});

    FirebaseFirestore.instance.collection('Users').doc(uid).collection('grass').doc(date).set({
      'cover': 0,
      'daily': [],
      'main': [],
    });
    return true;
  } catch (e) {
    print('Error creating new user document: $e');
    return false;
  }
}

// Future<bool> enterMemberInfo()

Future<String> googleSignOut() async {
  await _auth.signOut();
  await _googleSignIn.signOut();

  // setState(() {
  //   email = "";
  //   url = "";
  //   name = "";
  // });

  return 'logout';
}

//파라미터에 String url 추가
Future<bool> getUserInfo(String nickname, String uid, String address, String profileUrl) async {
  try {
    await _firestore.collection('Users').doc(uid).update({
      'nickname': nickname,
      'address': address,
      'profileUrl': profileUrl,
      // Any other fields you want to update can be added here
    });
    reloadData();
    return true;
  } catch (e) {
    print('Error updating user info: $e');
    return false;
  }
}

Future<Map<String, List<String>>> getUserGrassInfo(String uid, String date) async {
  DocumentSnapshot documentSnapshot = await _firestore.collection('Users').doc(uid).collection('grass').doc(date).get();

  List<String> daily = documentSnapshot['daily'];
  print('daily: $daily');

  List<String> main = documentSnapshot['main'];
  print('main: $main');

  Map<String, List<String>> grassInfo = {
    'daily': daily,
    'main': main,
  };

  return grassInfo;
}

// Future<String> getUserGrassList(String uid, String month) async {
//   try {
//     DateTime monthDateTime = DateTime.parse('$month-01');

//     //이 기간 동안 문서 다 가져와야함
//     DateTime startDate = monthDateTime;
//     DateTime endDate = monthDateTime.add(Duration(days: 31));

//     CollectionReference grassCollection =
//         _firestore.collection('Users').doc(uid).collection('grass');
//     QuerySnapshot querySnapshot = await grassCollection.get();

//     for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
//       String documentName = documentSnapshot.id;
//       print('Document Name: $documentName');

//       List<String> daily = documentSnapshot['daily'];
//       List<String> main = documentSnapshot['main'];
//       print('daily: $daily');
//       print('main: $main');
//     }

//     return 'Successfully retrieved grass list for $month';
//   } catch (e) {
//     print('Error getting user grass list: $e');
//     return 'Error retrieving grass list';
//   }
// }

Future<int> getUserGrassList(String uid, String date) async {
  List<String>? daily;
  List<String>? main;
  try {
    // DateTime timestampDateTime = DateTime.parse(date);

    // String month = timestampDateTime.month.toString().padLeft(2, '0');
    // String year = timestampDateTime.year.toString();

    // DateTime startDate = DateTime(int.parse(year), int.parse(month), 1);
    // DateTime endDate = DateTime(int.parse(year), int.parse(month) + 1, 1);

    CollectionReference grassCollection = _firestore.collection('Users').doc(uid).collection('grass');
    QuerySnapshot querySnapshot = await grassCollection.where('date').get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      daily = List<String>.from(documentSnapshot['daily']);
      main = List<String>.from(documentSnapshot['main']);
    }

    int dailyCount = daily?.length ?? 0;
    int mainCount = main?.length ?? 0;

    return dailyCount + mainCount;
  } catch (e) {
    print('Error getting user grass list: $e');
    return 0;
  }
}

Future<int> getUserPoint(String uid) async {
  try {
    DocumentSnapshot documentSnapshot = await _firestore.collection('Users').doc(uid).get();
    int point = documentSnapshot['point'];
    return point;
  } catch (e) {
    print('Error getting user point: $e');
    return 0;
  }
}

Future<Map<String, dynamic>> getUserAllInfo(String uid) async {
  try {
    print("getUserAllInfo");
    print(uid);
    DocumentSnapshot documentSnapshot = await _firestore.collection('Users').doc(uid).get();
    List<String> friend = (documentSnapshot.data() != null && documentSnapshot['friend'] != null) ? List<String>.from(documentSnapshot['friend']) : [];
    int level = documentSnapshot['level'];
    String nickname = documentSnapshot['nickname'];
    int point = documentSnapshot['point'];
    int totalQuest = documentSnapshot['totalQuest'];
    String profileUrl = documentSnapshot['profileUrl'];
    String address = documentSnapshot['address'];
    int totalLank = documentSnapshot['totalLank'];
    int weeklyLank = documentSnapshot['weeklyLank'];

    Map<String, dynamic> userInfo = {
      'friend': friend,
      'level': level,
      'nickname': nickname,
      'point': point,
      'totalQuest': totalQuest,
      'profileUrl': profileUrl,
      'address': address,
      'totalLank': totalLank,
      'weeklyLank': weeklyLank,
    };

    print(userInfo);
    return userInfo;
  } catch (e) {
    print('Error getting user all info: $e');
    return {};
  }
}

Future<String> updateUserPoint(String uid, int point) async {
  try {
    await _firestore.collection('Users').doc(uid).update({'point': point});
    return 'Successfully updated user point';
  } catch (e) {
    print('Error updating user point: $e');
    return 'Error updating user point';
  }
}

Future<String> updateUserLevel(String uid, int level) async {
  try {
    await _firestore.collection('Users').doc(uid).update({'level': level});
    return 'Successfully updated user level';
  } catch (e) {
    print('Error updating user level: $e');
    return 'Error updating user level';
  }
}

Future<String> updateUserTotalQuest(String uid) async {
  try {
    DocumentSnapshot userSnapshot = await _firestore.collection('Users').doc(uid).get();
    int currentTotalQuest = userSnapshot['totalQuest'] ?? 0;

    int newTotalQuest = currentTotalQuest + 1;

    await _firestore.collection('Users').doc(uid).update({'totalQuest': newTotalQuest});

    print(newTotalQuest);
    return 'Successfully updated user total quest';
  } catch (e) {
    print('Error updating user total quest: $e');
    return 'Error updating user total quest';
  }
}

Future<String> updateUserProfileUrl(String uid, String profileUrl) async {
  try {
    await _firestore.collection('Users').doc(uid).update({'profileUrl': profileUrl});
    return 'Successfully updated user profile url';
  } catch (e) {
    print('Error updating user profile url: $e');
    return 'Error updating user profile url';
  }
}

Future<String> updateUserGrass(String uid, String date, String type, String name) async {
  try {
    DocumentReference documentReference = _firestore.collection('Users').doc(uid).collection('grass').doc(date);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey(type)) {
        await documentReference.update({
          type: FieldValue.arrayUnion([name])
        });
      }
    } else {
      await documentReference.set({
        'cover': 0,
        type: [name]
      });
    }
    return 'Successfully updated user grass';
  } catch (e) {
    print('Error updating user grass: $e');
    return 'Error updating user grass';
  }
}

Future<List<Map<String, dynamic>>> getUserQuestList(String uid, String date) async {
  try {
    DocumentSnapshot questSnapshot = await _firestore.collection('Users').doc(uid).collection('grass').doc(date).get();
    Map<String, dynamic> questList = questSnapshot.data() as Map<String, dynamic>;

    List<Map<String, dynamic>> result = [];

    List<MapEntry<String, dynamic>> questEntries = questList.entries.toList();

    for (var entry in questEntries) {
      if (entry.key == 'main' || entry.key == 'daily') {
        Map<String, dynamic> questInfo = {entry.key: entry.value};
        result.add(questInfo);
      }
    }
    print('특정 날짜에 유저한 퀘스트 내역');
    print(result);
    return result;
  } catch (e) {
    print('Error getting quest list: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getUserQuestData(String uid) async {
  try {
    QuerySnapshot questSnapshot = await _firestore.collection('Users').doc(uid).collection('grass').get();
    List<Map<String, dynamic>> result = [];
    for (var doc in questSnapshot.docs) {
      Map<String, dynamic> questInfo = {
        'date': doc.id,
      };
      result.add(questInfo);
    }

    return result;
  } catch (e) {
    print('Error getting quest list: $e');
    return [];
  }
}
