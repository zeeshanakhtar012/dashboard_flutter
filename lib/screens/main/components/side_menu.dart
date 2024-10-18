import 'package:admin/controllers/controller_admin.dart';
import 'package:admin/screens/screen_add_retailers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../screen_add_users.dart';
import '../../screen_profile.dart';
import '../../screen_retailers_details.dart';
import '../../screen_user_list.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AdminController controller = Get.put(AdminController());
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset(
                    height: 100,
                    width: 100,
                    "assets/icons/jazz_icon.png"),
                Text("Jazz", style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),)
              ],
            ),
          ),
          DrawerListTile(
            title: "Add Retailer",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              Get.to(ScreenAddRetailers());
            },
          ),
          DrawerListTile(
            title: "Users Details",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {
             Get.to(UserListScreen());
            },
          ),
          DrawerListTile(
            title: "Add Users",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {
              Get.to(ScreenAddUsers(isUpdate: false,));
            },
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              Get.to(ScreenProfile());
            },
          ),
          DrawerListTile(
            title: "Logout",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () async{
              await controller.adminLogout();
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading:SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
