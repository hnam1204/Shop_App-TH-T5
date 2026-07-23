import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/week8_firestore_constants.dart';

Future<int> nextWeek8Id(
  Transaction transaction,
  FirebaseFirestore firestore,
  String counterName,
) async {
  final reference = firestore
      .collection(Week8FirestoreConstants.counters)
      .doc(counterName);
  final snapshot = await transaction.get(reference);
  final value = snapshot.data()?['nextId'];
  final id = value is num ? value.toInt() : 1;
  transaction.set(reference, {'nextId': id + 1});
  return id;
}
