import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/com/navigation/component/search_item.dart';
import 'package:flutter_app/com/navigation/utils/constant.dart' as constants;
import 'package:flutter_app/com/navigation/netwok/socket_handler.dart'
    as handler;

class Search extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchState();
}

class SearchState extends State<Search> with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    handler.currentState = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text("添加"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin:
                EdgeInsets.only(top: 10.0, left: 3.0, right: 3.0, bottom: 10.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(211, 211, 211, 0.8),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.search),
                            Expanded(
                              child: Text(
                                "搜索用户名",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTapDown: (event) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => SearchDialog()));
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showMenu(),
          ),
        ],
      ),
    );
  }

  Widget _showMenu() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: Row(
              children: <Widget>[
                Icon(Icons.phone_iphone),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "手机联系人",
                        style: TextStyle(fontSize: 22.0),
                      ),
                      Text("添加或邀请通讯录中的好友"),
                    ],
                  ),
                ),
              ],
            ),
            onTapDown: (e) {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: Row(
              children: <Widget>[
                Icon(Icons.swap_calls),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "扫码",
                        style: TextStyle(fontSize: 22.0),
                      ),
                      Text("扫描二维码名片"),
                    ],
                  ),
                ),
              ],
            ),
            onTapDown: (e) {},
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class SearchDialog extends StatefulWidget {
  @override
  SearchDialogState createState() => SearchDialogState();
}

class SearchDialogState extends State<SearchDialog> {
  List<String> list = [];
  String _keyword = "";
  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: TextField(
          style: TextStyle(fontSize: 20.0),
          decoration: InputDecoration(hintText: "搜索用户名"),
          onSubmitted: (value) {
            _keyword = value;
            _search();
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.all(0.0),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) => UserItem(list[index]),
        itemCount: list.length,
      ),
    );
  }

  void _search() {
    if (_keyword != null && _keyword.trim() != "") {
      list.clear();
      var message = {
        constants.type: constants.search,
        constants.subtype: constants.info,
        constants.id: handler.userName,
        constants.password: handler.password,
        constants.keyword: _keyword,
        constants.version: constants.currentVersion
      };
      var httpClient = HttpClient();
      httpClient
          .put(constants.server, constants.httpPort,
              "/${constants.search}/${constants.info}")
          .then((request) {
        request.write(json.encode(message) + constants.end);
        return request.close();
      }).then((response) {
        response.transform(utf8.decoder).listen((data) {
          var _result = json.decode(data);
          if (_result["user"] != null) {
            list.clear();
            list.add(_result["user"]["id"]);
          } else {
            key.currentState.showSnackBar(SnackBar(content: Text("该用户不存在")));
          }
          this.setState(() {});
        });
      });
      _keyword = "";
    }
  }
}
