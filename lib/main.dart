
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey globalKey=GlobalKey();
  var rng=new Random();

  Future getImage() async {
    var image;
    final picker = ImagePicker();
    try {
      image = await picker.getImage(source: ImageSource.gallery);
    } catch (platformException) {
      print("not allowing " + platformException);
    }
    setState(() {
      if (image != null) {
        //imageSelected = true;
        _image = File(image.path);
      } else {}
      _image = image;
    });
    new Directory('storage/emulated/0/' + 'MemeGenerator')
        .create(recursive: true);
  }

  String headerText="";
  String footerText="";

  File _image;
  File _imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: Container(
          child: Column(
            children:<Widget> [
              Image.asset("assets/smile.png",
              scale: 3.0,),
              SizedBox(height: 10.0,),
              //Image.asset("assets/memegenerator.png"),
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children:<Widget> [
                    _image!=null?Image.file(_image
                    ,height: 300,):
                    Container(
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 140,
                        child: Column(
                          children: <Widget>[
                            Text(headerText),
                            Spacer(),
                            Text(footerText),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                onChanged: (val){
                  headerText=val;
                },
                decoration: InputDecoration(
                  hintText: "Header Text",
                ),
              ),
              SizedBox(height: 12,),
              TextField(
                onChanged: (val){
                  footerText=val;
                },
                decoration: InputDecoration(
                  hintText: "Footer Text",
                ),
              ),
              SizedBox(height: 12,),
              RaisedButton(
                  onPressed: (){
                    //TODO
                    takeScreenshot();
                  },
                child: Text("save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  takeScreenshot() async {
    RenderRepaintBoundary boundary =
    globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    File imgFile = new File('$directory/screenshot${rng.nextInt(200)}.png');
    setState(() {
      _imageFile = imgFile;
    });
    _savefile(_imageFile);
    //saveFileLocal();
    imgFile.writeAsBytes(pngBytes);

  }
  _savefile(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }

  _askPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.photos]);
  }
  }




