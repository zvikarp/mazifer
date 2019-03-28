import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mazifer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          body1: TextStyle(
            fontFamily: 'Roboto Mono',
            fontSize: 18,
          ),
          body2: TextStyle(
            fontFamily: 'Roboto Mono',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      home: Mazifer(),
    );
  }
}

class Mazifer extends StatefulWidget {
  Mazifer({Key key}) : super(key: key);

  @override
  _MaziferState createState() => _MaziferState();
}

class _MaziferState extends State<Mazifer> {
  final List<Color> colors = [
    Color(0xff000000),
    Color(0xffff5733),
    Color(0xffc70039),
    Color(0xff005792),
    Color(0xff74b49b),
    Color(0xff4a4a48),
    Color(0xffffffff),
  ];
  final PageController ctr = PageController();
  Color bgColor = Color(0xff4a4a48);
  Color mzColor = Color(0xff005792);
  double height = 200;

  String text = "[io]";

  void _rebuildMaze(String input) {
    setState(() {
      text = "[" + input.replaceAll(" ", "+").toLowerCase() + "]";
    });
  }

  void _changeColor(Color color) {
    setState(() => bgColor = color);
  }

  void _zoom(ScaleUpdateDetails event) {
    if ((event.scale * event.horizontalScale * event.verticalScale) == 1)
      return;
    setState(() {
      height = max(min((200 * event.scale), 400), 40);
    });
  }

  Widget card(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget colorSector() {
    return Container(
      height: 42.0,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, i) {
          return Container(
            width: 30,
            height: 30,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: colors[i],
            ),
          );
        },
      ),
    );
  }

  List<Widget> welcome() {
    return [
      FlatButton(
        onPressed: () {
          ctr.nextPage(
              duration: new Duration(milliseconds: 600), curve: Curves.easeIn);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Get started",
              style: Theme.of(context).textTheme.body2,
            ),
            Icon(Icons.navigate_next),
          ],
        ),
      ),
    ];
  }

  List<Widget> setText() {
    return [
      Text("Entrer text to be mazified:"),
      TextField(
        onChanged: _rebuildMaze,
        onSubmitted: (s) {
          ctr.nextPage(
              duration: new Duration(milliseconds: 600), curve: Curves.easeIn);
        },
      ),
    ];
  }

  List<Widget> setMzColor() {
    return [
      Text("Set Maze Color:"),
      colorSector(),
    ];
  }

  List<Widget> setBgColor() {
    return [
      Text("Set Background Color:"),
      colorSector(),
    ];
  }

  List<Widget> share() {
    return [
      Text("Share Your Maze!"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 32,
                  color: mzColor,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onScaleUpdate: _zoom,
                  child: CustomPaint(
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: text.length,
                      itemBuilder: (context, index) {
                        return SvgPicture.asset(
                          'assets/images/' + text[index] + '.svg',
                          height: height,
                          color: mzColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
              RaisedButton(
                child: Text("to image"),
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Transform.translate(
          offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 120,
            child: PageView(
              controller: ctr,
              children: <Widget>[
                card(welcome()),
                card(setText()),
                card(setMzColor()),
                card(setBgColor()),
                card(share()),
              ],
            ),
          )),
    );
  }
}
