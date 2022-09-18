import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentSchedule {
  int amount;
  Timestamp date;
  bool isPaid;
  DocumentReference purchaseReference;
  String paymentReference;
  String customerdocID;

  PaymentSchedule(
      {required this.paymentReference,
      required this.purchaseReference,
      required this.amount,
      required this.date,
      required this.isPaid,
      required this.customerdocID});

  Future<void> updateFirestore() async {
    purchaseReference
        .collection('payment_schedule')
        .doc(paymentReference)
        .update({'date': date, 'isPaid': isPaid});
  }

  void updateBalance() {
    final cloud = FirebaseFirestore.instance;

    purchaseReference.update(
      {
        'outstanding_balance': isPaid
            ? FieldValue.increment(-amount)
            : FieldValue.increment(amount),
        'paid_amount': isPaid
            ? FieldValue.increment(amount)
            : FieldValue.increment(-amount),

      },
    );

    cloud.collection('customers').doc(customerdocID).update(
      {
        'outstanding_balance': isPaid
            ? FieldValue.increment(-amount)
            : FieldValue.increment(amount),
        'paid_amount': isPaid
            ? FieldValue.increment(amount)
            : FieldValue.increment(-amount),
      },
    );
  }
}
