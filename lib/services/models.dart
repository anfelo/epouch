//// Embedded Maps

class Finances {
  String uid;
  dynamic organizations;

  Finances({this.uid, this.organizations});

  factory Finances.fromMap(Map data) {
    return Finances(
      uid: data['uid'],
      organizations: data['organizations'],
    );
  }
}

class Organization {
  String uid;
  String id;
  String name;
  Map<dynamic, dynamic> accounts;

  Organization({this.uid, this.id, this.name, this.accounts});

  factory Organization.fromMap(Map data) {
    return Organization(
      uid: data['uid'],
      id: data['id'],
      name: data['name'],
      accounts: data['accounts'] ?? {},
    );
  }
}

class Account {
  String id;
  String name;
  String accountType;
  int balance;

  Account({this.id, this.name, this.accountType, this.balance});

  factory Account.fromMap(Map data) {
    return Account(
      id: data['id'],
      name: data['name'],
      accountType: data['accountType'],
      balance: data['balance'],
    );
  }
}

class Cashflow {
  String accountId;
  int cashAmount;
  String cashflowType;
  String category;
  DateTime entryDate;

  Cashflow({
    this.accountId,
    this.cashAmount,
    this.cashflowType,
    this.category,
    this.entryDate,
  });

  factory Cashflow.fromMap(Map data) {
    return Cashflow(
      accountId: data['accountId'],
      cashAmount: int.parse(data['cashAmount'].toString()),
      cashflowType: data['cashflowType'],
      category: data['category'],
      entryDate:
          DateTime.fromMillisecondsSinceEpoch(data['entryDate'].seconds * 1000),
    );
  }
}

class CashflowCategory {
  String id;
  String text;

  CashflowCategory({this.id, this.text});

  factory CashflowCategory.fromMap(Map data) {
    return CashflowCategory(
      id: data['id'],
      text: data['text'],
    );
  }
}
