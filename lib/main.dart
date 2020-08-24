import 'dart:io';
import 'package:flutter/material.dart';

import './widgets/new_transaction_form.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';
import './helpers/database_helper.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        textTheme: TextTheme(
          headline6: TextStyle(
            fontFamily: "Quicksand",
            fontWeight: FontWeight.w300,
          ),
        ),
        primarySwatch: Colors.teal,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    DateTime lastDayOfPrevWeek = DateTime.now().subtract(Duration(days: 6));
    lastDayOfPrevWeek = DateTime(
        lastDayOfPrevWeek.year, lastDayOfPrevWeek.month, lastDayOfPrevWeek.day);
    return _userTransactions.where((element) {
      return element.txnDateTime.isAfter(
        lastDayOfPrevWeek,
      );
    }).toList();
  }

  _MyHomePageState() {
    _updateUserTransactionsList();
  }

  void _updateUserTransactionsList() {
    Future<List<Transaction>> res =
        DatabaseHelper.instance.getAllTransactions();

    res.then((txnList) {
      setState(() {
        _userTransactions = txnList;
      });
    });
  }

  void _showChartHandler(bool show) {
    setState(() {
      _showChart = show;
    });
  }

  Future<void> _addNewTransaction(
      String title, double amount, DateTime chosenDate) async {
    final newTxn = Transaction(
      DateTime.now().millisecondsSinceEpoch.toString(),
      title,
      amount,
      chosenDate,
    );
    int res = await DatabaseHelper.instance.insert(newTxn);

    if (res != 0) {
      _updateUserTransactionsList();
    }
  }

  void _startAddNewTransaction(BuildContext context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0),
            ),
          ),
          child: NewTransactionForm(_addNewTransaction),
        );
      },
    );
  }

  Future<void> _deleteTransaction(String id) async {
    int res =
        await DatabaseHelper.instance.deleteTransactionById(int.tryParse(id));
    if (res != 0) {
      _updateUserTransactionsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppBar myAppBar = AppBar(
      title: Text(
        'Personal Expenses',
        style: TextStyle(
          fontFamily: "Quicksand",
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
          tooltip: "Add New Transaction",
        ),
      ],
    );
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    final bool isLandscape =
        mediaQueryData.orientation == Orientation.landscape;

    final double availableHeight = mediaQueryData.size.height -
        myAppBar.preferredSize.height -
        mediaQueryData.padding.top -
        mediaQueryData.padding.bottom;

    final double availableWidth = mediaQueryData.size.width -
        mediaQueryData.padding.left -
        mediaQueryData.padding.right;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: myAppBar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Show Chart",
                    style: TextStyle(
                      fontFamily: "Rubik",
                      fontSize: 16.0,
                      color: Colors.grey[500],
                    ),
                  ),
                  Switch.adaptive(
                    activeColor: Colors.amber[700],
                    value: _showChart,
                    onChanged: (value) => _showChartHandler(value),
                  ),
                ],
              ),
            if (isLandscape)
              _showChart
                  ? myChartContainer(
                      height: availableHeight * 0.8,
                      width: 0.6 * availableWidth)
                  : myTransactionListContainer(
                      height: availableHeight * 0.8,
                      width: 0.6 * availableWidth),
            if (!isLandscape)
              myChartContainer(
                  height: availableHeight * 0.3, width: availableWidth),
            if (!isLandscape)
              myTransactionListContainer(
                  height: availableHeight * 0.7, width: availableWidth),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
              child: Icon(Icons.add),
              tooltip: "Add New Transaction",
              onPressed: () => _startAddNewTransaction(context),
            ),
    );
  }

  Widget myChartContainer({double height, double width}) {
    return Container(
      height: height,
      width: width,
      child: Chart(_recentTransactions),
    );
  }

  Widget myTransactionListContainer({double height, double width}) {
    return Container(
      height: height,
      width: width,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
  }
}
