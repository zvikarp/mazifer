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
primarySwatch: Colors.indigo,
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
PageController pageCtr = PageController();
GlobalKey key = GlobalKey();
TextEditingController txtCtr = TextEditingController();
List<Color> selected;
double height;
String txt;
bool done;

@override
void initState() {
super.initState();
setup();
}

void zoom(ScaleUpdateDetails e) {
if ((e.scale * e.horizontalScale * e.verticalScale) == 1) return;
setState(() => height = max(
min((200 * e.scale), MediaQuery.of(context).size.height - 200), 40));
}

void nextCard() {
pageCtr.nextPage(
duration: Duration(milliseconds: 600), curve: Curves.easeIn);
}

void setup() {
setState(() {
selected = [Colors.red, Colors.indigo];
txtCtr.text = "m";
height = 200;
txt = "[m]";
done = false;
});
}

Widget card(List<Widget> children) {
return Container(
margin: EdgeInsets.all(16),
padding: EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(30),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: children,
),
);
}

Widget cSector(int step) {
return Container(
height: 56,
child: ListView.builder(
scrollDirection: Axis.horizontal,
itemCount: c.length,
itemBuilder: (context, i) {
return GestureDetector(
onTap: () {
setState(() => selected[step] = c[i]);
nextCard();
},
child: Container(
width: 40,
margin: EdgeInsets.all(8),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(30),
border: Border.all(
color: (c[i] == selected[step]) ? Colors.black : c[i],
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
controller: txtCtr,
autofocus: true,
textAlign: TextAlign.center,
decoration: InputDecoration(
border: InputBorder.none,
),
style: Theme.of(context).textTheme.body2,
inputFormatters: <TextInputFormatter>[
LengthLimitingTextInputFormatter(10),
WhitelistingTextInputFormatter(RegExp("[a-z A-Z]")),
],
textInputAction: TextInputAction.next,
onEditingComplete: () {
SystemChannels.textInput.invokeMethod('TextInput.hide');
nextCard();
},
onChanged: (i) {
setState(() => txt = "[" +
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

List<Widget> button(int step) {
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
setState(() {
height = 100;
done = true;
});
RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
ui.Image img = await boundary.toImage(pixelRatio: 3);
ByteData bytes = await img.toByteData(format: ui.ImageByteFormat.png);
EsysFlutterShare.shareImage('m.png', bytes, '');
}

Widget maze() {
return Center(
child: GestureDetector(
onScaleUpdate: zoom,
child: SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: RepaintBoundary(
key: key,
child: Container(
color: selected[1],
padding: EdgeInsets.all(16),
child: CustomPaint(
child: Row(
children: txt
.split("")
.map(
(t) => SvgPicture.asset(
'assets/images/' + t + '.svg',
height: height,
color: selected[0],
),
)
.toList(),
),
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
resizeToAvoidBottomPadding: false,
backgroundColor: selected[1],
body: maze(),
bottomNavigationBar: Transform.translate(
offset: Offset(0, -1 * MediaQuery.of(context).viewInsets.bottom),
child: Container(
height: 130,
child: PageView(
controller: pageCtr,
children: [
button(0),
setText(),
cPicker(2),
cPicker(3),
button(4),
].map((item) => card(item)).toList(),
),
),
),
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
floatingActionButton: done
? FloatingActionButton(
onPressed: () {
pageCtr.jumpTo(0);
setup();
},
child: Icon(Icons.replay, color: Colors.black),
backgroundColor: Colors.white,
)
: null,
);
}
}
