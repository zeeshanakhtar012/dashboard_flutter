import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../screen_add_users.dart';
import '../../screen_profile.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            title: "Download",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Users",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ScreenAddUsers()));
            },
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ScreenProfile()));
            },
          ),
          DrawerListTile(
            title: "Logout",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
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
