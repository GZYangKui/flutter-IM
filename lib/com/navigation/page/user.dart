import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/com/navigation/page/subpage/about_program.dart';
import 'package:flutter_app/com/navigation/page/subpage/application_min.dart';
import 'package:flutter_app/com/navigation/page/subpage/application_setting.dart';
import 'package:flutter_app/com/navigation/page/subpage/contacts.dart';
import 'package:flutter_app/com/navigation/page/subpage/message.dart';
import 'package:flutter_app/com/navigation/page/subpage/search.dart';
import 'package:flutter_app/com/navigation/page/login.dart';
import 'package:flutter_app/com/navigation/netwok/socket_handler.dart'
    as handler;
import 'package:flutter_app/com/navigation/page/subpage/system_inform.dart';
import 'package:flutter_app/com/navigation/page/subpage/user_info.dart';
import 'package:flutter_app/com/navigation/utils/utils.dart';
import 'package:flutter_app/com/navigation/utils/application.dart'
    as application;

class UserCenter extends StatefulWidget {
  @override
  UserCenterState createState() => UserCenterState();
}

class UserCenterState extends State<UserCenter>
    with SingleTickerProviderStateMixin {
  static final List<StatefulWidget> _tabs = [
    Message(),
    Contacts(),
    MinApplication()
  ];
  TabController _tabController;
  int _currentIndex = 0;
  final List<String> _titles = ["消息", "联系人", "小应用"];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          primaryColor: application.settings["primaryColor"] == null
              ? Colors.lightBlue
              : Color(int.parse(application.settings["primaryColor"]))),
      child: WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: new Text(_titles[_currentIndex]),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Search()));
                },
              ),
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SystemInform())),
              ),
            ],
          ),
          drawer: Drawer(
            child: DrawerItems(),
          ),
          body: TabBarView(
            children: _tabs,
            controller: _tabController,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.message), title: Text("消息")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.perm_contact_calendar), title: Text("联系人")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.streetview), title: Text("小应用")),
            ],
            onTap: (index) {
              this.setState(() {
                _currentIndex = index;
              });
              _tabController.animateTo(index);
            },
            currentIndex: _currentIndex,
          ),
        ),
        onWillPop: () {
          SystemNavigator.pop();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    handler.currentState = this;
    _tabController =
        TabController(initialIndex: 0, length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      this.setState(() {
        this._currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}

class DrawerItems extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DrawerItemsState();
}

class DrawerItemsState extends State<DrawerItems>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: UserAccountsDrawerHeader(
                            accountName: Text(handler.userId),
                            accountEmail: const Text("752544765@qqcom"),
                            currentAccountPicture: GestureDetector(
                              child: const CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/images/head.png"),
                              ),
                              onTapDown: (e) {
                                Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            UserInfo(handler.userId),
                                      ),
                                    );
                              },
                            ),
                            otherAccountsPictures: <Widget>[],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        FadeTransition(
          opacity: _drawerContentsOpacity,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.settings),
                title: Text(
                  "设置",
                  style: TextStyle(fontSize: 20.0),
                ),
                onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => ApplicationSetting(),
                      ),
                    ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "关于",
                  style: TextStyle(fontSize: 20.0),
                ),
                onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => About(),
                      ),
                    ),
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text(
                  "分享",
                  style: TextStyle(fontSize: 20.0),
                ),
                onTap: () => showToast("该功能正在开发中,敬请期待!"),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text(
                  "注销",
                  style: TextStyle(fontSize: 20.0),
                ),
                onTap: () => _logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
            title: Text("消息"),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text("你确定要退出当前账号?")],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text("取消"),
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.red),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(
                    width: 10.0,
                    height: 0.0,
                  ),
                  RaisedButton(
                    child: Text("确定"),
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.red),
                    ),
                    onPressed: () {
                      handler.dispose();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => Login()));
                    },
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
