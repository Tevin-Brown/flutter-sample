import 'package:flutter/material.dart';

class AppListScreen extends StatelessWidget {
  final List<String> apps;
  final ValueChanged<String> onTapped;
  AppListScreen({
    @required this.apps,
    @required this.onTapped,
  });
  @override
  Widget build(BuildContext context) {
    final tiles = apps.map((app) => ListTile(
          title: Text(app),
          onTap: () => onTapped(app),
        ));
    final divided =
        ListTile.divideTiles(tiles: tiles, context: context).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose an App'),
      ),
      body: ListView(
        children: divided,
      ),
    );
  }
}

class AppDetailsScreen extends StatelessWidget {
  final String appname;
  AppDetailsScreen({
    @required this.appname,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(appname),
        ),
        body: Text(appname));
  }
}
