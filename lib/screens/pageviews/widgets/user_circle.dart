import 'package:flutter/material.dart';
import 'package:flutter_chat_app/provider/user_provider.dart';
import 'package:flutter_chat_app/screens/pageviews/widgets/user_details_container.dart';
import 'package:flutter_chat_app/utils/universal_variables.dart';
import 'package:flutter_chat_app/utils/utilities.dart';
import 'package:provider/provider.dart';

class UserCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: UniversalVariables.blackColor,
        builder: (context) => UserDetailsContainer(),
        isScrollControlled: true,
      ),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: UniversalVariables.separatorColor,
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                Utils.getInitials(userProvider.getUser.name),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: UniversalVariables.lightBlueColor,
                  fontSize: 13,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: UniversalVariables.blackColor, width: 2),
                    color: UniversalVariables.onlineDotColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
