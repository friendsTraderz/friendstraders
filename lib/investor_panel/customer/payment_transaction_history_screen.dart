import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../investor_panel/customer/installment_transaction_widget.dart';
import '../../investor_panel/view_model/viewmodel_customers.dart';



class PaymentTransactionHistoryScreen extends StatefulWidget {
  const PaymentTransactionHistoryScreen(
      {super.key, required this.index, required this.productIndex, required this.paymentIndex});

  final int productIndex;
  final int index;
  final int paymentIndex;
  @override
  State<PaymentTransactionHistoryScreen> createState() =>
      _PaymentTransactionHistoryScreenState();
}

class _PaymentTransactionHistoryScreenState
    extends State<PaymentTransactionHistoryScreen> {

  @override
  void initState() {
    Provider.of<CustomerViewInvestor>(context, listen: false).getInstallmentTransactionHistory(
        index: widget.index, productIndex: widget.productIndex, paymentIndex: widget.paymentIndex);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('Installment Transaction History',style: TextStyle(color: Color(0xFFE56E14),),),
      ),
      body: Padding(padding: const EdgeInsets.only(top: 5),
        child: ListView.builder(
          physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: Provider.of<CustomerViewInvestor>(context)
              .allCustomers[widget.index]
              .purchases[widget.productIndex]
              .paymentSchedule[widget.paymentIndex].transactionHistory
              .length,
          itemBuilder: (BuildContext context, int transactionIndex) {
            return InstallmentTransactionWidget(
                index: widget.index,
                productIndex: widget.productIndex,
                transactionIndex: transactionIndex, paymentIndex: widget.paymentIndex,);
          },
        ),
      ),
    );
  }
}