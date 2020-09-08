import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_chat_app/enum/user_state.dart';
import 'package:flutter_chat_app/provider/user_provider.dart';
import 'package:flutter_chat_app/resources/firebase_repository.dart';
import 'package:flutter_chat_app/screens/callscreens/pickup/pickup_layout.dart';
import 'package:flutter_chat_app/screens/pageviews/chat_list_screen.dart';
import 'package:flutter_chat_app/screens/pageviews/group_chat_list_screen.dart';
import 'package:flutter_chat_app/utils/universal_variables.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  FirebaseRepository _repository = FirebaseRepository();
  PageController pageController;
  int _page = 0;

  UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      _repository.setUserState(
          userId: userProvider.getUser.uid, userState: UserState.Online);
    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    String currentUserId =
        (userProvider != null && userProvider.getUser != null)
            ? userProvider.getUser.uid
            : "";

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _repository.setUserState(
                userId: currentUserId,
                userState: UserState.Online,
              )
            : print("resumed state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _repository.setUserState(
                userId: currentUserId,
                userState: UserState.Offline,
              )
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _repository.setUserState(
                userId: currentUserId,
                userState: UserState.Waiting,
              )
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _repository.setUserState(
                userId: currentUserId,
                userState: UserState.Offline,
              )
            : print("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    double _labelFontSize = 10;

    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        body: PageView(
          children: <Widget>[
            Container(
              child: ChatListScreen(),
            ),
            Container(
              child: GroupChatListScreen(),
            ),
            Center(child: Text("Contact Screen")),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: UniversalVariables.blackColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat,
                      color: (_page == 0)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor),
                  title: Text(
                    "Konuşmalar",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 0)
                            ? UniversalVariables.lightBlueColor
                            : UniversalVariables.greyColor),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group,
                      color: (_page == 1)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor),
                  title: Text(
                    "Gruplar",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 1)
                            ? UniversalVariables.lightBlueColor
                            : UniversalVariables.greyColor),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.contact_phone,
                      color: (_page == 2)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor),
                  title: Text(
                    "Kişiler",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 2)
                            ? UniversalVariables.lightBlueColor
                            : UniversalVariables.greyColor),
                  ),
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
      ),
    );
  }
}
