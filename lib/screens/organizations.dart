import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/shared.dart';
import '../services/services.dart';
import '../screens/screens.dart';
import '../helpers/helpers.dart';

class OrganizationsScreen extends StatelessWidget {
  Future<String> _createAlertDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Organization Name:'),
          content: TextField(
            controller: controller,
            maxLength: 30,
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 5.0,
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(controller.text.toString());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Global.financesRef.documentStream,
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.hasData) {
          Finances finances = snap.data;
          List<Organization> orgs =
              (finances.organizations as List ?? []).map((orgData) {
            Organization org = Organization.fromMap(orgData);
            org.uid = finances.uid;
            return org;
          }).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Manage Organizations'),
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
            body: orgs.length == 0
                ? EmptyPage()
                : GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20.0),
                    crossAxisSpacing: 10.0,
                    crossAxisCount: 2,
                    children:
                        orgs.map((org) => OrganizationItem(org: org)).toList(),
                  ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                FontAwesomeIcons.plus,
                color: Colors.white,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                // Add your onPressed code here!
                String orgName = await _createAlertDialog(context);
                if (orgName != null && orgName != '') {
                  // Add new organization
                  Organization org = Organization(
                    uid: finances.uid,
                    id: createId(orgName),
                    name: orgName,
                    accounts: {},
                  );
                  _updateUserFinances(org);
                }
              },
            ),
            bottomNavigationBar: AppBottomNav(),
          );
        } else {
          return LoadingScreen();
        }
      },
    );
  }

  Future<void> _updateUserFinances(Organization org) {
    return Global.financesRef.upsert(
      ({
        'organizations': FieldValue.arrayUnion([
          {
            'id': '${org.uid}_${org.id}',
            'name': org.name,
          },
        ]),
      }),
    );
  }
}

class OrganizationItem extends StatelessWidget {
  final Organization org;
  const OrganizationItem({Key key, this.org}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => AccountsScreen(org: org),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   'assets/covers/${topic.img}',
              //   fit: BoxFit.contain,
              // ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        org.name,
                        style:
                            TextStyle(height: 1.5, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                  // Text(topic.description)
                ],
              ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
