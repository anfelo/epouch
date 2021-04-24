import 'package:flutter/material.dart';
import 'package:epouch_mobile/shared/shared.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/services.dart';
import '../helpers/helpers.dart';
import '../screens/screens.dart';

class AccountsScreen extends StatelessWidget {
  final Organization org;

  AccountsScreen({this.org});

  Future<Account> _createAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return CreateAccountDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          Document<Organization>(path: 'organizations/${org.id}').streamData(),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.hasData) {
          Organization org = snap.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(org.name),
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
            body: org.accounts.length == 0
                ? EmptyPage()
                : GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20.0),
                    crossAxisSpacing: 10.0,
                    crossAxisCount: 2,
                    children: org.accounts.values.map((accountData) {
                      Account account = Account.fromMap(accountData);
                      return AccountItem(account: account);
                    }).toList(),
                  ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                FontAwesomeIcons.plus,
                color: Colors.white,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                // Add your onPressed code here!
                Account newAccount = await _createAlertDialog(context);
                if (newAccount != null) {
                  _updateOrg(newAccount);
                  _addInitialCashflow(newAccount);
                }
              },
            ),
            bottomNavigationBar: AppBottomNav(),
          );
        } else {
          _createOrgCollection();
          return LoadingScreen();
        }
      },
    );
  }

  Future<void> _createOrgCollection() {
    return Global.orgsRef.upsertOne(
      ({
        'uid': org.uid,
        'id': org.id,
        'name': org.name,
      }),
    );
  }

  Future<void> _updateOrg(Account account) {
    return Global.orgsRef.upsertOne(
      ({
        'id': org.id,
        'accounts': {
          '${org.id}_${account.id}': {
            'id': '${org.id}_${account.id}',
            'name': account.name,
            'accountType': account.accountType,
            'balance': account.balance,
          }
        },
      }),
    );
  }

  Future<void> _addInitialCashflow(Account account) {
    return Global.cashflowsRef.addData(
      ({
        'accountId': '${org.id}_${account.id}',
        'cashAmount': account.balance,
        'cashflowType': account.balance < 0 ? 'Expense' : 'Income',
        'category': 'apertura-cuenta',
        'entryDate': DateTime.now(),
      }),
    );
  }
}

class AccountItem extends StatelessWidget {
  final Account account;

  const AccountItem({Key key, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        color: account.accountType == 'Debit'
            ? Color.fromRGBO(53, 222, 117, 1)
            : Colors.orangeAccent,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    AccountDetailScreen(account: account),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Chip(
                label: Text(account.accountType),
                backgroundColor: account.accountType == 'Debit'
                    ? Color.fromRGBO(22, 190, 40, 1)
                    : Colors.deepOrange,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        account.name,
                        style:
                            TextStyle(height: 1.5, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '\$ ${Global.currFormater.format(account.balance)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: account.balance < 0
                              ? Colors.deepOrange
                              : Theme.of(context).textTheme.body2.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateAccountDialog extends StatefulWidget {
  @override
  CreateAccountDialogState createState() => CreateAccountDialogState();
}

class CreateAccountDialogState extends State<CreateAccountDialog> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _balanceController = TextEditingController();
  String _typeController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Account:'),
      content: ListView(
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Account Name',
            ),
          ),
          TextField(
            controller: _balanceController,
            decoration: InputDecoration(
              labelText: 'Balance',
            ),
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<String>(
            value: _typeController,
            items: ['Debit', 'Credit']
                .map((label) => DropdownMenuItem(
                      child: Text(label.toString()),
                      value: label,
                    ))
                .toList(),
            hint: Text('Account Type'),
            onChanged: (value) {
              setState(() {
                _typeController = value;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        MaterialButton(
          elevation: 5.0,
          child: Text('Submit'),
          onPressed: () {
            Account newAccount = Account(
              id: createId(_nameController.text.toString()),
              name: _nameController.text.toString(),
              balance: int.parse(_balanceController.text),
              accountType: _typeController,
            );
            Navigator.of(context).pop(newAccount);
          },
        ),
      ],
    );
  }
}
