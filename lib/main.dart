import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mazifer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        cursorColor: Colors.grey[800],
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
  ];
  List<Color> selectedColors = [
    Color(0xffff5733),
    Color(0xff005792),
  ];
  final PageController pageCtr = PageController();
  double height = 200;
  String text = "";
  GlobalKey globalKey = GlobalKey();

  void _rebuildMaze(String input) {
    String temp = input.replaceAll(" ", "+").toLowerCase();
    setState(() {
      text = temp == "" ? "" : "[" + temp + "]";
    });
  }

  void _zoom(ScaleUpdateDetails event) {
    if ((event.scale * event.horizontalScale * event.verticalScale) == 1)
      return;
    setState(() {
      height = max(min((200 * event.scale), 400), 40);
    });
  }

  void nextCard() {
    pageCtr.nextPage(
        duration: new Duration(milliseconds: 600), curve: Curves.easeIn);
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

  Widget colorSector(int color) {
    return Container(
      height: 46.0,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedColors[color] = colors[i];
              });
              nextCard();
            },
            child: Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: (colors[i] == selectedColors[color])
                      ? Colors.black
                      : colors[i],
                  width: 3,
                ),
                color: colors[i],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> welcome() {
    return [
      FlatButton(
        onPressed: nextCard,
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
        autofocus: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        style: Theme.of(context).textTheme.body2,
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(24),
          WhitelistingTextInputFormatter(RegExp("[a-z A-Z]")),
        ],
        onSubmitted: (s) {
          pageCtr.nextPage(
              duration: new Duration(milliseconds: 600), curve: Curves.easeIn);
        },
      ),
    ];
  }

  List<Widget> setMzColor() {
    return [
      Text("Set Maze Color:"),
      colorSector(0),
    ];
  }

  List<Widget> setBgColor() {
    return [
      Text("Set Background Color:"),
      colorSector(1),
    ];
  }

  List<Widget> share() {
    return [
      FlatButton(
        onPressed: () async {
          RenderRepaintBoundary boundary =
              globalKey.currentContext.findRenderObject();
          ui.Image image = await boundary.toImage(pixelRatio: 5.0);
          ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await EsysFlutterShare.shareImage(
              'myImageTest.png', bytes, 'my image title');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Share your maze!",
              style: Theme.of(context).textTheme.body2,
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedColors[1],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              card([
                Text(
                  "Mayifer",
                  style: Theme.of(context).textTheme.body2,
                ),
              ]),
              Expanded(
                child: GestureDetector(
                  onScaleUpdate: _zoom,
                  child: RepaintBoundary(
                    key: globalKey,
                    child: Container(
                      color: selectedColors[1],
                      child: CustomPaint(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: text.length,
                          itemBuilder: (context, index) {
                            return SvgPicture.asset(
                                'assets/images/' + text[index] + '.svg',
                                height: height,
                                color: selectedColors[0]);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
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
              controller: pageCtr,
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
