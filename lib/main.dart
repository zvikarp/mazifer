import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mazifer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        cursorColor: Colors.grey[800],
        fontFamily: 'Yanone',
        textTheme: TextTheme(
          body1: TextStyle(fontSize: 24),
          body2: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      home: Mazifer(),
    );
  }
}

class Mazifer extends StatefulWidget {
  _MaziferState createState() => _MaziferState();
}

class _MaziferState extends State<Mazifer> {
  List<Color> c = Colors.primaries;
  List<Color> cSelected = [Colors.red, Colors.indigo];
  PageController pageCtr = PageController();
  double height = 200;
  String text = "[flutter]";
  GlobalKey globalKey = GlobalKey();

  void _zoom(ScaleUpdateDetails event) {
    if ((event.scale * event.horizontalScale * event.verticalScale) == 1)
      return;
    setState(() {
      height = max(min((200 * event.scale), 400), 40);
    });
  }

  void nextCard() {
    pageCtr.nextPage(
        duration: Duration(milliseconds: 600), curve: Curves.easeIn);
  }

  Widget card(List<Widget> children) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 3)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget cSector(int color) {
    return Container(
      height: 56,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: c.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              setState(() => cSelected[color] = c[i]);
              nextCard();
            },
            child: Container(
              width: 40,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: (c[i] == cSelected[color]) ? Colors.black : c[i],
                  width: 3,
                ),
                color: c[i],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> setText() {
    return [
      Text("Entrer text to be mazified:"),
      TextField(
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
        textInputAction: TextInputAction.next,
        onEditingComplete: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          nextCard();
        },
        onChanged: (i) {
          setState(() => text = "[" +
              i.replaceAll(" ", "+").toLowerCase() +
              "]".replaceAll("[]", ""));
        },
      ),
    ];
  }

  List<Widget> cPicker(int step) {
    return [
      Text(step == 2 ? "Set Maze Color:" : "Set Background Color:"),
      cSector(step - 2),
    ];
  }

  List<Widget> buttonCard(int step) {
    return [
      FlatButton(
        onPressed: step == 0 ? nextCard : share,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              step == 0 ? "Get started" : "Share your maze",
              style: Theme.of(context).textTheme.body2,
            ),
            Icon(step == 0 ? Icons.navigate_next : Icons.share),
          ],
        ),
      ),
    ];
  }

  void share() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 5);
    ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await EsysFlutterShare.shareImage('maze.png', bytes, '');
  }

  Widget maze() {
    return Expanded(
      child: GestureDetector(
        onScaleUpdate: _zoom,
        child: RepaintBoundary(
          key: globalKey,
          child: Container(
            padding: EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
              color: cSelected[1],
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 3)
              ],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: CustomPaint(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: text.length,
                itemBuilder: (context, index) {
                  return SvgPicture.asset(
                      'assets/images/' + text[index] + '.svg',
                      height: height,
                      color: cSelected[0]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: Text("Mazifer",
                      style: Theme.of(context).textTheme.body2)),
            ),
            maze(),
          ],
        ),
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, -1 * MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          color: cSelected[1],
          height: 130,
          child: PageView(
            controller: pageCtr,
            children: [
              buttonCard(0),
              setText(),
              cPicker(2),
              cPicker(3),
              buttonCard(4),
            ].map((content) => card(content)).toList(),
          ),
        ),
      ),
    );
  }
}
