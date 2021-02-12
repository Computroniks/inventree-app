import 'package:InvenTree/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:InvenTree/barcode.dart';
import 'package:InvenTree/api.dart';

import 'package:InvenTree/settings/login.dart';

import 'package:InvenTree/widget/category_display.dart';
import 'package:InvenTree/widget/company_list.dart';
import 'package:InvenTree/widget/location_display.dart';
import 'package:InvenTree/widget/search.dart';
import 'package:InvenTree/widget/spinner.dart';
import 'package:InvenTree/widget/drawer.dart';

class InvenTreeHomePage extends StatefulWidget {
  InvenTreeHomePage({Key key}) : super(key: key);

  @override
  _InvenTreeHomePageState createState() => _InvenTreeHomePageState();
}

class _InvenTreeHomePageState extends State<InvenTreeHomePage> {

  final GlobalKey<_InvenTreeHomePageState> _homeKey = GlobalKey<_InvenTreeHomePageState>();

  _InvenTreeHomePageState() : super() {

    // Initially load the profile and attempt server connection
    _loadProfile();
  }

  // Selected user profile
  UserProfile _profile;

  BuildContext _context;

  void _search() {
    if (!InvenTreeAPI().checkConnection(context)) return;

    showSearch(
        context: context,
        delegate: PartSearchDelegate()
    );
  }

  void _scan(BuildContext context) {
    if (!InvenTreeAPI().checkConnection(context)) return;

    scanQrCode(context);
  }

  void _parts(BuildContext context) {
    if (!InvenTreeAPI().checkConnection(context)) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDisplayWidget(null)));
  }

  void _stock(BuildContext context) {
    if (!InvenTreeAPI().checkConnection(context)) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) => LocationDisplayWidget(null)));
  }

  void _suppliers() {
    if (!InvenTreeAPI().checkConnection(context)) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) => SupplierListWidget()));
  }

  void _manufacturers() {
    if (!InvenTreeAPI().checkConnection(context)) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) => ManufacturerListWidget()));
  }

  void _customers() {
    if (!InvenTreeAPI().checkConnection(context)) return;

    Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerListWidget()));
  }

  void _selectProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InvenTreeLoginSettingsWidget())
    ).then((context) {
      // Once we return
      _loadProfile();
    });
  }

  void _unsupported() {
    showDialog(
        context:  context,
        child: new SimpleDialog(
          title: new Text("Unsupported"),
          children: <Widget>[
            ListTile(
              title: Text("This feature is not yet supported"),
              subtitle: Text("It will be supported in an upcoming release"),
            )
          ],
        )
    );
  }


  void _loadProfile() async {

    _profile = await UserProfileDBManager().getSelectedProfile();

    // A valid profile was loaded!
    if (_profile != null) {
      if (!InvenTreeAPI().isConnected() && !InvenTreeAPI().isConnecting()) {

        // Attempt server connection
        InvenTreeAPI().connectToServer(_homeKey.currentContext).then((result) {
          setState(() {});
        });
      }
    }

    setState(() {});
  }

  ListTile _serverTile() {

    // No profile selected
    // Tap to select / create a profile
    if (_profile == null) {
      return ListTile(
        title: Text("No Profile Selected"),
        subtitle: Text("Tap to create or select a profile"),
        leading: FaIcon(FontAwesomeIcons.server),
        trailing: FaIcon(
          FontAwesomeIcons.user,
          color: Color.fromRGBO(250, 50, 50, 1),
        ),
        onTap: () {
          _selectProfile();
        },
      );
    }

    // Profile is selected ...
    if (InvenTreeAPI().isConnecting()) {
      return ListTile(
        title: Text("Connecting to server..."),
        subtitle: Text("${InvenTreeAPI().baseUrl}"),
        leading: FaIcon(FontAwesomeIcons.server),
        trailing: Spinner(
          icon: FontAwesomeIcons.spinner,
          color: Color.fromRGBO(50, 50, 250, 1),
        ),
        onTap: () {
          _selectProfile();
        }
      );
    } else if (InvenTreeAPI().isConnected()) {
      return ListTile(
        title: Text("Connected to server"),
        subtitle: Text("${InvenTreeAPI().baseUrl}"),
        leading: FaIcon(FontAwesomeIcons.server),
        trailing: FaIcon(
          FontAwesomeIcons.checkCircle,
          color: Color.fromRGBO(50, 250, 50, 1)
        ),
        onTap: () {
          _selectProfile();
        },
      );
    } else {
      return ListTile(
        title: Text("Could not connect to server"),
        subtitle: Text("${_profile.server}"),
        leading: FaIcon(FontAwesomeIcons.server),
        trailing: FaIcon(
          FontAwesomeIcons.timesCircle,
          color: Color.fromRGBO(250, 50, 50, 1),
        ),
        onTap: () {
          _selectProfile();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    _context = context;

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: _homeKey,
      appBar: AppBar(
        title: Text(I18N.of(context).appTitle),
        actions: <Widget>[
          IconButton(
            icon: FaIcon(FontAwesomeIcons.search),
            tooltip: I18N.of(context).search,
            onPressed: _search,
          ),
        ],
      ),
      drawer: new InvenTreeDrawer(context),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (<Widget>[
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                /*
                Column(
                  children: <Widget>[

                   IconButton(
                     icon: new FaIcon(FontAwesomeIcons.search),
                     tooltip: 'Search',
                     onPressed: _search,
                   ),
                   Text("Search"),
                  ],
                ),
                */
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: new FaIcon(FontAwesomeIcons.barcode),
                      tooltip: I18N.of(context).scanBarcode,
                      onPressed: () { _scan(context); },
                    ),
                    Text(I18N.of(context).scanBarcode),
                  ],
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: new FaIcon(FontAwesomeIcons.shapes),
                      tooltip: I18N.of(context).parts,
                      onPressed: () { _parts(context); },
                    ),
                    Text(I18N.of(context).parts),
                  ],
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: new FaIcon(FontAwesomeIcons.boxes),
                      tooltip: I18N.of(context).stock,
                      onPressed: () { _stock(context); },
                    ),
                    Text(I18N.of(context).stock),
                  ],
                ),
              ],
            ),
            Spacer(),
            // TODO - Re-add these when the features actually do something..
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: new FaIcon(FontAwesomeIcons.building),
                      tooltip: "Suppliers",
                        onPressed: _suppliers,
                    ),
                    Text("Suppliers"),
                  ],
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.industry),
                      tooltip: "Manufacturers",
                      onPressed: _manufacturers,
                    ),
                    Text("Manufacturers")
                  ],
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.userTie),
                      tooltip: "Customers",
                      onPressed: _customers,
                    ),
                    Text("Customers"),
                  ]
                )
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: new FaIcon(FontAwesomeIcons.tools),
                      tooltip: "Build",
                      onPressed: _unsupported,
                    ),
                    Text("Build"),
                  ],
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: new FaIcon(FontAwesomeIcons.shoppingCart),
                      tooltip: "Order",
                      onPressed: _unsupported,
                    ),
                    Text("Order"),
                  ]
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: new FaIcon(FontAwesomeIcons.truck),
                      tooltip: "Ship",
                      onPressed: _unsupported,
                    ),
                    Text("Ship"),
                  ]
                )
              ],
            ),
            Spacer(),
            */
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: _serverTile(),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
