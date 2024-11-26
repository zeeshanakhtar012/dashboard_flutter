import 'package:admin/controllers/controller_user.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';

class Header extends StatelessWidget {
  Header({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey; // Store the scaffoldKey

  final userController = Get.put(UserController());

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
        Obx(() {
          return userController.isLoading.value
              ? CircularProgressIndicator()
              : InkWell(
            onTap: () async {
              userController.generateCSVTemplate();
            },
            child: Container(
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
                  Icon(Icons.file_copy, color: Colors.white),
                  if (!Responsive.isMobile(context))
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text("Csv Template"),
                        ),
                        Icon(Icons.download, color: Colors.white),
                      ],
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
