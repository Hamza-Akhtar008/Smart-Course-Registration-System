import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SideMenuStudent extends StatelessWidget {
  const SideMenuStudent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/background.png",color: Colors.white,),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () { Navigator.pushNamed(context, '/dashboardstudent');},
          ),
          DrawerListTile(
            title: "UploadTranscript",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.pushNamed(context, '/upload_transcript');
            },
          ),

          DrawerListTile(
            title: "Course Registeration",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.pushNamed(context, '/course_registration');
            },
          ),
          DrawerListTile(
            title: "Check Application Status",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.pushNamed(context, '/check_status');
            },


          ),
          DrawerListTile(
            title: "Request Meeting",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.pushNamed(context, '/request_meeting');
            },
          ),
          DrawerListTile(
            title: "Calculate CGPA",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.pushNamed(context, '/calculate');
            },
          ),
          DrawerListTile(
            title: "Log out ",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pushNamed(context, '/');
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
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
