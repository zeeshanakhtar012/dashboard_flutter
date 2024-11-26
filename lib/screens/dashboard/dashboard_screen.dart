import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/controller_user.dart';
import '../main/components/side_menu.dart';
import '../screen_retailer_details.dart';
import 'components/header.dart';
import 'components/users_details.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserController controller = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data on initialization
  }

  void _fetchData() {
    controller.fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _fetchData();
        return true;
      },
      child: SafeArea(
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
                const SizedBox(height: 20),
                ScreenRetailersDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
