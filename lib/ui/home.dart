import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quake_app/const/constants.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var futureBuilder = _generateQuakesFutureBuilder();
    return Scaffold(
      appBar: AppBar(
        title: Text("Quakes"),
      ),
      body: futureBuilder
    );
  }


  FutureBuilder _generateQuakesFutureBuilder() {
    return new FutureBuilder(
        future: _getQuakes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: Text("loading..."));
            default:
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                return _createQuakesList(context, snapshot);
              }
          }
        });
  }

  Future<Map> _getQuakes() async {
    final http.Response response = await http.get(API_QUAKES);
    return json.decode(response.body);
  }

  Widget _createQuakesList(BuildContext context, AsyncSnapshot snapshot) {
    final Map values = snapshot.data;
    final List features = values['features'];
    final List<Item> items = List();

    initializeDateFormatting("en_US");
    for (int i = 0; i < features.length; i++) {
      var item = Item();
      var prop = features[i]['properties'];
      item.mag = double.parse(prop['mag'].toString());
      item.place = prop['place'];

      final DateTime time = DateTime.fromMillisecondsSinceEpoch(int.parse(prop['time'].toString()));

      var formatter = DateFormat("MMMM d, yyyy ", "en_US");
      var jmFormatter = DateFormat.jm("en_US");
      item.time  = formatter.format(time) + jmFormatter.format(time);
      item.title = prop['title'];
      items.add(item);
    }
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int position) {
          return Column(
            children: <Widget>[
              Divider(height: 5.5,),
              ListTile(
                title: Text("${items[position].time}",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 17.9,
                    fontWeight: FontWeight.w500,
                  ),),
                subtitle: Text("${items[position].place}",
                  style: TextStyle(
                    fontSize: 14.9,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),),
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text("${items[position].mag.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16.4,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),),
                ),
                onTap: () => _showOnTapMessage(context, items[position].title)
                ,
              ),
            ],
          );
        });
  }

  void _showOnTapMessage(BuildContext context, String message) {
    var alert = AlertDialog(
      title: Text("Quakes"),
      content: Text(message),
      actions: <Widget>[
        FlatButton(child: Text("OK"), onPressed: () {
          Navigator.pop(context);
        },)
      ],
    );
    showDialog(context: context, builder: (context) => alert);
  }


}

class Item {
  double mag;
  String place;
  String time;
  String title;
}

