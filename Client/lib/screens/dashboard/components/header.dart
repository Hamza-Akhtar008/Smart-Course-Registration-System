import 'package:shared_preferences/shared_preferences.dart';

import '/controllers/MenuAppController.dart';
import '/responsive.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../constants.dart';
class Header extends StatelessWidget {
  final String Parameter;
  Header({ required this.Parameter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu,color: Colors.black,),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(

            this.Parameter,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black),
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
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
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: FutureBuilder<String>(
                future: _loadUserId(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data ?? '');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<String> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    return "USER :  ${prefs.getString('userid')?.toUpperCase()}" ?? '';
  }
}