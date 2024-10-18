
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../main/components/side_menu.dart';
import '../screen_retailer_details.dart';
import 'components/header.dart';
import 'components/users_details.dart';

class DashboardScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: SideMenu(),
        body: SingleChildScrollView(
          primary: false,
          padding: EdgeInsets.all(defaultPadding),
          child: ListView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Header(scaffoldKey: _scaffoldKey),
              SizedBox(height: defaultPadding),
              UserDetailsTable(),
              const SizedBox(
                height: 20,
              ),
              ScreenRetailersDetails(),
            ],
          ),
        ),
      ),
    );
  }
}
