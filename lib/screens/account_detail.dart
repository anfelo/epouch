import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../shared/shared.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;

  AccountDetailScreen({this.account});

  @override
  _AccountDetailScreenState createState() =>
      _AccountDetailScreenState(account: account);
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  final Account account;
  int _balance;

  _AccountDetailScreenState({this.account}) {
    _balance = account.balance;
  }

  Future<Cashflow> _createAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return CreateCashflowDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FilteredCollection<Cashflow>(
        path: 'cashflows',
        filter: {
          'field': 'accountId',
          'value': account.id,
          'orderBy': 'entryDate',
          'limit': 20,
        },
      ).streamData(),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.hasData) {
          List<Cashflow> cashflows = snap.data;
          cashflows.sort((a, b) => b.entryDate.compareTo(a.entryDate));
          cashflows.add(Cashflow(
            accountId: '',
            cashAmount: 0,
            cashflowType: '',
            entryDate: DateTime.now(),
            category: 'Fin de la lista!',
          ));
          return Scaffold(
            appBar: AppBar(
              title: Text(account.name),
              backgroundColor: Theme.of(context).primaryColor,
              actions: [
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.userCircle,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                )
              ],
            ),
            body: cashflows.length == 0
                ? EmptyPage()
                : ListView(
                    children: cashflows
                        .map((cashflow) => CashflowItem(cashflow: cashflow))
                        .toList(),
                  ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                FontAwesomeIcons.plus,
                color: Colors.white,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                // // Add your onPressed code here!
                Cashflow newCashflow = await _createAlertDialog(context);
                if (newCashflow != null) {
                  newCashflow.accountId = account.id;
                  _updateCashflows(newCashflow);
                  _updateAccount(newCashflow);
                  setState(() {
                    _balance = _calculateNewBalance(_balance, newCashflow);
                  });
                }
              },
            ),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '\$ ${Global.currFormater.format(_balance)}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ],
                ),
              ),
              color: _balance < 0
                  ? Colors.deepOrange
                  : Color.fromRGBO(53, 222, 117, 1),
              elevation: 10,
            ),
          );
        } else {
          return LoadingScreen();
        }
      },
    );
  }

  Future<void> _updateCashflows(Cashflow cashflow) {
    return Global.cashflowsRef.addData(
      ({
        'accountId': cashflow.accountId,
        'cashAmount': cashflow.cashAmount,
        'cashflowType': cashflow.cashflowType,
        'category': cashflow.category,
        'entryDate': cashflow.entryDate,
      }),
    );
  }

  Future<void> _updateAccount(Cashflow cashflow) {
    var idParts = account.id.split('_');
    idParts.removeLast();
    String orgId = idParts.join('_');
    return Global.orgsRef.upsertOne(
      ({
        'id': orgId,
        'accounts': {
          '${account.id}': {
            'id': account.id,
            'name': account.name,
            'accountType': account.accountType,
            'balance': _calculateNewBalance(_balance, cashflow),
          }
        },
      }),
    );
  }

  int _calculateNewBalance(int balance, Cashflow cashflow) {
    return balance +
        (cashflow.cashflowType == 'Expense'
            ? -1 * cashflow.cashAmount
            : cashflow.cashAmount);
  }
}

class CashflowItem extends StatelessWidget {
  final Cashflow cashflow;

  const CashflowItem({Key key, this.cashflow}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<CashflowCategory> cats = Provider.of<List<CashflowCategory>>(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        child: ListTile(
          leading: cashflow.accountId == ''
              ? Text('')
              : Icon(
                  cashflow.cashflowType == 'Expense'
                      ? FontAwesomeIcons.arrowAltCircleDown
                      : FontAwesomeIcons.arrowAltCircleUp,
                  color: cashflow.cashflowType == 'Expense'
                      ? Colors.deepOrange
                      : Color.fromRGBO(53, 222, 117, 1),
                ),
          title: cashflow.accountId == ''
              ? Text(cashflow.category)
              : Text(
                  cats.where((cat) => cat.id == cashflow.category).first.text),
          subtitle: cashflow.accountId == ''
              ? Text('')
              : Text(Global.dateFormater.format(cashflow.entryDate)),
          trailing: cashflow.accountId == ''
              ? Text('')
              : Text('\$ ${Global.currFormater.format(cashflow.cashAmount)}'),
        ),
      ),
      color: ThemeData.dark().primaryColor,
    );
  }
}

class CreateCashflowDialog extends StatefulWidget {
  @override
  CreateCashflowDialogState createState() => CreateCashflowDialogState();
}

class CreateCashflowDialogState extends State<CreateCashflowDialog> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime _dateTimeState;
  String _categoryController;
  String _cashflowTypeController;

  @override
  Widget build(BuildContext context) {
    List<CashflowCategory> cats = Provider.of<List<CashflowCategory>>(context);
    if (cats != null || cats.length != 0) {
      return AlertDialog(
        title: Text('New Cashflow:'),
        content: ListView(
          children: <Widget>[
            Text('Cash Amount'),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.dollarSign),
              ),
              keyboardType: TextInputType.number,
            ),
            Padding(padding: new EdgeInsets.all(8.0)),
            Text('Date'),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.calendarDay),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                DateTime selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2018),
                  lastDate: DateTime(2030),
                  builder: (BuildContext context, Widget child) {
                    return Theme(
                      data: ThemeData.dark(),
                      child: child,
                    );
                  },
                );

                setState(() {
                  _dateTimeState = selectedDate;
                  _dateController.text =
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _categoryController,
              items: cats
                  .map((cat) => DropdownMenuItem(
                        child: Text(cat.text.toString()),
                        value: cat.id,
                      ))
                  .toList(),
              hint: Text('Category'),
              onChanged: (value) {
                setState(() {
                  _categoryController = value;
                });
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: new EdgeInsets.all(8.0)),
                Text('Type'),
                ListTile(
                  title: const Text('Income'),
                  leading: Radio(
                    value: 'Income',
                    groupValue: _cashflowTypeController,
                    onChanged: (value) {
                      setState(() {
                        _cashflowTypeController = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Expense'),
                  leading: Radio(
                    value: 'Expense',
                    groupValue: _cashflowTypeController,
                    onChanged: (value) {
                      setState(() {
                        _cashflowTypeController = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text('Submit'),
            onPressed: () {
              Cashflow newCashflow = Cashflow(
                cashAmount: int.parse(_amountController.text.toString()),
                category: _categoryController,
                cashflowType: _cashflowTypeController,
                entryDate: _dateTimeState,
              );
              Navigator.of(context).pop(newCashflow);
            },
          ),
        ],
      );
    } else {
      return LoadingScreen();
    }
  }
}
