import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spent_type.dart';
import '../models/payment_source.dart';
import 'auth_provider.dart';

// Provider for active spent types (categories)
final activeSpentTypesProvider = StreamProvider<List<SpentType>>((ref) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('spentTypes')
      .where('isActive', isEqualTo: true)
      .orderBy('order')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => SpentType.fromFirestore(doc))
            .toList();
      });
});

// Provider for active payment sources
final activePaymentSourcesProvider = StreamProvider<List<PaymentSource>>((ref) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('paymentSources')
      .where('isActive', isEqualTo: true)
      .orderBy('order')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => PaymentSource.fromFirestore(doc))
            .toList();
      });
});
