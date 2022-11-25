import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateFirestore {
  double investorProfitPercentage;
  String vendorName;
  String productName;
  int productCost;
  int productSalePrice;
  String customerName;
  DateTime firstPaymnetDate;
  DateTime orderDate;
  double numberOfPayments;
  String investorName;
  int openingBalance;

  UpdateFirestore(
      {required this.openingBalance,
      required this.investorName,
      required this.investorProfitPercentage,
      required this.numberOfPayments,
      required this.orderDate,
      required this.productSalePrice,
      required this.vendorName,
      required this.customerName,
      required this.productCost,
      required this.productName,
      required this.firstPaymnetDate});

  Future<bool> addCustomerToExistingInvestor() async {
    int companyProfit = ((productSalePrice - productCost) -
            (productSalePrice - productCost) * (investorProfitPercentage / 100))
        .toInt();
    productCost = productCost + (companyProfit);

    final cloud = FirebaseFirestore.instance;
    cloud.collection('investorFinancials').doc('finance').update(
      {
        'outstanding_balance': FieldValue.increment(productSalePrice),
        'total_cost': FieldValue.increment(productCost - companyProfit),
        'cash_available': FieldValue.increment(-productCost + companyProfit),
        'total_profit': FieldValue.increment(productSalePrice - productCost),
      },
    );
    cloud.collection('financials').doc('finance').update(
      {
        'investor_profit': FieldValue.increment(companyProfit),
      },
    );

    DocumentReference vendorReference;

    vendorReference = await cloud.collection('investorVendors').add({
      'name': vendorName,
      'address': 'Address',
      'city': 'City',
      'image':
          'https://media.istockphoto.com/vectors/default-image-icon-vector-missing-picture-page-for-website-design-or-vector-id1357365823?k=20&m=1357365823&s=612x612&w=0&h=ZH0MQpeUoSHM3G2AWzc8KkGYRg4uP_kuu0Za8GFxdFc='
    });

    final vendorDocumentReference =
        await vendorReference.collection('products').add(
      {
        'name': productName,
        'price': productCost - companyProfit,
        'image':
            'https://webcolours.ca/wp-content/uploads/2020/10/webcolours-unknown.png'
      },
    );
    final productReference = await cloud.collection('products').add(
      {
        'name': productName,
        'price': productSalePrice,
        'reference': vendorDocumentReference
      },
    );
    final newCustomerReference =
        await cloud.collection('investorCustomers').add(
      {
        'name': customerName,
        'outstanding_balance': productSalePrice,
        'paid_amount': 0,
        'image': 'https://cdn-icons-png.flaticon.com/512/147/147144.png'
      },
    );
    final purchaseReference = await cloud
        .collection('investorCustomers')
        .doc(newCustomerReference.id)
        .collection('purchases')
        .add(
      {
        'product': productReference,
        'outstanding_balance': productSalePrice,
        'paid_amount': 0,
        'purchaseDate': Timestamp.fromDate(orderDate),
        'companyProfit': companyProfit,
      },
    );

    await cloud
        .collection('investors')
        .where('name', isEqualTo: investorName)
        .get()
        .then((value) {
      value.docs[0].reference.update({
        'currentBalance': FieldValue.increment(-productCost + companyProfit),
        'outstandingBalance': FieldValue.increment(productSalePrice)
      });
      value.docs[0].reference
          .collection('products')
          .add({'productReference': purchaseReference});

      purchaseReference.update({'investorReference': value.docs[0].reference});
    });

    final double productPayment = productSalePrice / numberOfPayments;
    final double lastPayment =
        productSalePrice - productPayment.toInt() * numberOfPayments;
    final double lastPayment2 = productPayment.toInt() + lastPayment;
    var timeNow = firstPaymnetDate;
    for (var i = 1; i < numberOfPayments + 1; i++) {
      await cloud
          .collection('investorCustomers')
          .doc(newCustomerReference.id)
          .collection('purchases')
          .doc(purchaseReference.id)
          .collection('payment_schedule')
          .add(
        {
          'amount': i < numberOfPayments
              ? productPayment.toInt()
              : lastPayment2.toInt(),
          'date': Timestamp.fromDate(
            DateTime.utc(timeNow.year, timeNow.month, timeNow.day),
          ),
          'isPaid': false,
          'remainingAmount': i < numberOfPayments
              ? productPayment.toInt()
              : lastPayment2.toInt(),
        },
      );
      timeNow = timeNow.add(const Duration(days: 30));
    }

    return true;
  }

  Future<bool> addCustomerToNewVendor() async {
    final cloud = FirebaseFirestore.instance;
    int companyProfit = ((productSalePrice - productCost) -
            (productSalePrice - productCost) * (investorProfitPercentage / 100))
        .toInt();
    productCost = productCost + (companyProfit);
    cloud.collection('investorFinancials').doc('finance').update(
      {
        'outstanding_balance': FieldValue.increment(productSalePrice),
        'total_cost': FieldValue.increment(productCost - companyProfit),
        'cash_available':
            FieldValue.increment(openingBalance - productCost + companyProfit),
        'total_profit': FieldValue.increment(productSalePrice - productCost),
      },
    );
    cloud.collection('financials').doc('finance').update(
      {'investor_profit': FieldValue.increment(companyProfit)},
    );

    DocumentReference vendorReference;

    vendorReference = await cloud.collection('investorVendors').add({
      'name': vendorName,
      'address': 'Address',
      'city': 'City',
      'image':
          'https://media.istockphoto.com/vectors/default-image-icon-vector-missing-picture-page-for-website-design-or-vector-id1357365823?k=20&m=1357365823&s=612x612&w=0&h=ZH0MQpeUoSHM3G2AWzc8KkGYRg4uP_kuu0Za8GFxdFc='
    });
    DocumentReference vendorDocumentReference =
        await vendorReference.collection('products').add(
      {
        'name': productName,
        'price': productCost - companyProfit,
        'image':
            'https://webcolours.ca/wp-content/uploads/2020/10/webcolours-unknown.png'
      },
    );
    final productReference = await cloud.collection('products').add(
      {
        'name': productName,
        'price': productSalePrice,
        'reference': vendorDocumentReference
      },
    );
    final newCustomerReference =
        await cloud.collection('investorCustomers').add(
      {
        'name': customerName,
        'outstanding_balance': productSalePrice,
        'paid_amount': 0,
        'image': 'https://cdn-icons-png.flaticon.com/512/147/147144.png'
      },
    );
    final purchaseReference = await cloud
        .collection('investorCustomers')
        .doc(newCustomerReference.id)
        .collection('purchases')
        .add(
      {
        'product': productReference,
        'outstanding_balance': productSalePrice,
        'paid_amount': 0,
        'purchaseDate': Timestamp.fromDate(orderDate),
        'companyProfit': companyProfit,
      },
    );

    DocumentReference investorReference =
        await cloud.collection('investors').add({
      'name': vendorName,
      'openingBalance': openingBalance,
      'currentBalance': openingBalance - productCost + companyProfit,
      'outstandingBalance': productSalePrice,
      'amountPaid': 0,
      'company_profit': 0
    });
    investorReference
        .collection('products')
        .add({'productReference': purchaseReference});

    purchaseReference.update({'investorReference': investorReference});

    final double productPayment = productSalePrice / numberOfPayments;
    final double lastPayment =
        productSalePrice - productPayment.toInt() * numberOfPayments;
    final double lastPayment2 = productPayment.toInt() + lastPayment;

    var timeNow = firstPaymnetDate;
    for (var i = 1; i < numberOfPayments + 1; i++) {
      await cloud
          .collection('investorCustomers')
          .doc(newCustomerReference.id)
          .collection('purchases')
          .doc(purchaseReference.id)
          .collection('payment_schedule')
          .add(
        {
          'amount': i < numberOfPayments
              ? productPayment.toInt()
              : lastPayment2.toInt(),
          'date': Timestamp.fromDate(
            DateTime.utc(timeNow.year, timeNow.month, timeNow.day),
          ),
          'isPaid': false,
          'remainingAmount': i < numberOfPayments
              ? productPayment.toInt()
              : lastPayment2.toInt(),
        },
      );
      timeNow = timeNow.add(const Duration(days: 30));
    }

    return true;
  }

  Future<bool> addProduct() async {
    print('1');
    final cloud = FirebaseFirestore.instance;

    int companyProfit = ((productSalePrice - productCost) -
            (productSalePrice - productCost) * (investorProfitPercentage / 100))
        .toInt();
    productCost = productCost + (companyProfit);

    cloud.collection('investorFinancials').doc('finance').update(
        {'cash_available': FieldValue.increment(-productCost + companyProfit)});

    cloud.collection('financials').doc('finance').update(
      {'investor_profit': FieldValue.increment(companyProfit)},
    );

    DocumentReference vendorReference;

    vendorReference = await cloud.collection('investorVendors').add({
      'name': vendorName,
      'address': 'Address',
      'city': 'City',
      'image':
          'https://media.istockphoto.com/vectors/default-image-icon-vector-missing-picture-page-for-website-design-or-vector-id1357365823?k=20&m=1357365823&s=612x612&w=0&h=ZH0MQpeUoSHM3G2AWzc8KkGYRg4uP_kuu0Za8GFxdFc='
    });
    print('2');
    final vendorDocumentReference =
        await vendorReference.collection('products').add(
      {
        'name': productName,
        'price': productCost - companyProfit,
        'image':
            'https://webcolours.ca/wp-content/uploads/2020/10/webcolours-unknown.png'
      },
    );
    final productReference = await cloud.collection('products').add(
      {
        'name': productName,
        'price': productSalePrice,
        'reference': vendorDocumentReference
      },
    );
    print('3');
    await cloud
        .collection('investorCustomers')
        .where('name', isEqualTo: customerName)
        .get()
        .then((value) async {
      cloud.collection('investorFinancials').doc('finance').update(
        {
          'outstanding_balance': FieldValue.increment(productSalePrice),
          'total_cost': FieldValue.increment(productCost - companyProfit),
          'total_profit': FieldValue.increment(productSalePrice - productCost),
        },
      );
      print('4');
      value.docs[0].reference.update(
        {
          'outstanding_balance': FieldValue.increment(productSalePrice),
        },
      );
      print('5');
      final purchaseReference = await cloud
          .collection('investorCustomers')
          .doc(value.docs[0].id)
          .collection('purchases')
          .add(
        {
          'product': productReference,
          'outstanding_balance': productSalePrice,
          'paid_amount': 0,
          'purchaseDate': Timestamp.fromDate(orderDate),
          'companyProfit': companyProfit,
        },
      );
      print('6');
      print(investorName);
      print('6');
      await cloud
          .collection('investors')
          .where('name', isEqualTo: investorName)
          .get()
          .then((value) {
        value.docs[0].reference.update({
          'currentBalance': FieldValue.increment(-productCost + companyProfit),
          'outstandingBalance': FieldValue.increment(productSalePrice)
        });
        value.docs[0].reference
            .collection('products')
            .add({'productReference': purchaseReference});

        purchaseReference
            .update({'investorReference': value.docs[0].reference});
      });

      final double productPayment = productSalePrice / numberOfPayments;
      final double lastPayment =
          productSalePrice - productPayment.toInt() * numberOfPayments;
      final double lastPayment2 = productPayment.toInt() + lastPayment;
      var timeNow = firstPaymnetDate;
      for (var i = 1; i < numberOfPayments + 1; i++) {
        await cloud
            .collection('investorCustomers')
            .doc(value.docs[0].id)
            .collection('purchases')
            .doc(purchaseReference.id)
            .collection('payment_schedule')
            .add(
          {
            'amount': i < numberOfPayments
                ? productPayment.toInt()
                : lastPayment2.toInt(),
            'date': Timestamp.fromDate(
              DateTime.utc(timeNow.year, timeNow.month, timeNow.day),
            ),
            'isPaid': false,
            'remainingAmount': i < numberOfPayments
                ? productPayment.toInt()
                : lastPayment2.toInt(),
          },
        );
        timeNow = timeNow.add(const Duration(days: 30));
      }
    });

    return true;
  }

  Future<bool> addProductToNewVendor() async {
    final cloud = FirebaseFirestore.instance;
    int companyProfit = ((productSalePrice - productCost) -
            (productSalePrice - productCost) * (investorProfitPercentage / 100))
        .toInt();
    productCost = productCost + (companyProfit);

    cloud.collection('investorFinancials').doc('finance').update(
        {'cash_available': FieldValue.increment(-productCost + companyProfit)});

    cloud.collection('financials').doc('finance').update(
      {'investor_profit': FieldValue.increment(companyProfit)},
    );

    DocumentReference vendorReference;

    vendorReference = await cloud.collection('investorVendors').add({
      'name': vendorName,
      'address': 'Address',
      'city': 'City',
      'image':
          'https://media.istockphoto.com/vectors/default-image-icon-vector-missing-picture-page-for-website-design-or-vector-id1357365823?k=20&m=1357365823&s=612x612&w=0&h=ZH0MQpeUoSHM3G2AWzc8KkGYRg4uP_kuu0Za8GFxdFc='
    });
    DocumentReference vendorDocumentReference =
        await vendorReference.collection('products').add(
      {
        'name': productName,
        'price': productCost - companyProfit,
        'image':
            'https://webcolours.ca/wp-content/uploads/2020/10/webcolours-unknown.png'
      },
    );
    final productReference = await cloud.collection('products').add(
      {
        'name': productName,
        'price': productSalePrice,
        'reference': vendorDocumentReference
      },
    );

    await cloud
        .collection('investorCustomers')
        .where('name', isEqualTo: customerName)
        .get()
        .then((value) async {
      cloud.collection('investorFinancials').doc('finance').update(
        {
          'outstanding_balance': FieldValue.increment(productSalePrice),
          'total_cost': FieldValue.increment(productCost - companyProfit),
          'total_profit': FieldValue.increment(productSalePrice - productCost),
        },
      );

      value.docs[0].reference.update(
        {
          'outstanding_balance': FieldValue.increment(productSalePrice),
        },
      );
      final purchaseReference = await cloud
          .collection('investorCustomers')
          .doc(value.docs[0].id)
          .collection('purchases')
          .add(
        {
          'product': productReference,
          'outstanding_balance': productSalePrice,
          'paid_amount': 0,
          'purchaseDate': Timestamp.fromDate(orderDate),
          'companyProfit': companyProfit,
        },
      );

      DocumentReference investorReference =
          await cloud.collection('investors').add({
        'name': vendorName,
        'openingBalance': openingBalance,
        'currentBalance': openingBalance - productCost + companyProfit,
        'outstandingBalance': productSalePrice,
        'amountPaid': 0,
        'company_profit': 0
      });
      investorReference
          .collection('products')
          .add({'productReference': purchaseReference});
      purchaseReference.update({'investorReference': investorReference});

      final double productPayment = productSalePrice / numberOfPayments;
      final double lastPayment =
          productSalePrice - productPayment.toInt() * numberOfPayments;
      final double lastPayment2 = productPayment.toInt() + lastPayment;
      var timeNow = firstPaymnetDate;
      for (var i = 1; i < numberOfPayments + 1; i++) {
        await cloud
            .collection('investorCustomers')
            .doc(value.docs[0].id)
            .collection('purchases')
            .doc(purchaseReference.id)
            .collection('payment_schedule')
            .add(
          {
            'amount': i < numberOfPayments
                ? productPayment.toInt()
                : lastPayment2.toInt(),
            'date': Timestamp.fromDate(
              DateTime.utc(timeNow.year, timeNow.month, timeNow.day),
            ),
            'isPaid': false,
            'remainingAmount': i < numberOfPayments
                ? productPayment.toInt()
                : lastPayment2.toInt(),
          },
        );
        timeNow = timeNow.add(const Duration(days: 30));
      }
    });

    return true;
  }
}