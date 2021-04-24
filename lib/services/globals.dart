import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/intl.dart';
import './services.dart';

/// Static global state. Immutable services that do not care about build context.
class Global {
  // App Data
  static final String title = 'Epouch';

  // Services
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final currFormater = NumberFormat('#,##0', 'en_US');
  static final dateFormater = DateFormat.yMMMMd("en_US");

  // Data Models
  static final Map models = {
    Finances: (data) => Finances.fromMap(data),
    Organization: (data) => Organization.fromMap(data),
    Account: (data) => Account.fromMap(data),
    Cashflow: (data) => Cashflow.fromMap(data),
    CashflowCategory: (data) => CashflowCategory.fromMap(data),
  };

  // Firestore References for Writes
  static final UserData<Finances> financesRef =
      UserData<Finances>(collection: 'finances');
  static final FilteredCollection<Organization> orgsRef =
      FilteredCollection<Organization>(
    path: 'organizations',
    filter: {'field': 'uid'},
  );
  static final Collection<CashflowCategory> cashflowCatRef =
      Collection<CashflowCategory>(path: 'cashflow-categories');
  static final Collection<Cashflow> cashflowsRef =
      Collection<Cashflow>(path: 'cashflows');
}
