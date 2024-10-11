import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import '../../screen_profile.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey; // Store the scaffoldKey

  void controlMenu() {
    if (!scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.openDrawer(); // Open the drawer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: controlMenu, // Control drawer opening
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Jazz Power",
            style: titleFont,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ProfileCard()
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.file_copy, color: Colors.white,),
          if (!Responsive.isMobile(context))
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text("Download File"),
            ),
          IconButton(onPressed: (){}, icon: Icon(Icons.download,color: Colors.white,)),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
