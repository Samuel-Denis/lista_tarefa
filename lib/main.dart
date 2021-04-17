import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.deepPurple,
      primarySwatch: Colors.deepPurple,
    ),
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _todoController = TextEditingController();

  List _toDolist = [] ;

  Map<String, dynamic> _lastRemoved;
  int _lasRemodevPos;




  @override
  void initState() {
    super.initState();

    _readData().then((data){
      setState(() {
        _toDolist = json.decode(data);
      });
    });
  }

  void _addTodo(){
   setState(() {
     Map<String, dynamic> newTodo = Map();
     newTodo["title"] = _todoController.text ;
     _todoController.text = "";
     newTodo["ok"] = false ;
     _toDolist.add(newTodo);
     _saveData();
   });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDolist.sort((a, b){
        if(a["ok"] && !b["ok"]) return 1;
        else if (!a["ok"] && b["ok"]) return -1;
        else return 0;
    });
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefa", style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: false,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
               Expanded(
                 child:  TextField(
                   controller: _todoController,
                   decoration: InputDecoration(
                     labelText: "Nova Tarefa",
                     labelStyle: TextStyle(
                         color: Theme.of(context).primaryColor,
                     ),
                   ),
                 ),
               ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addTodo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child:  ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _toDolist.length,
                  itemBuilder: buildItem ),
            )
          ),
        ],
      ),
    );
  }

  Widget buildItem (context, index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDolist[index]["title"]),
        value: _toDolist[index]["ok"],
        secondary: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(_toDolist[index]["ok"]
              ? Icons.check : Icons.error, color: Colors.white,
          ),
        ),
        onChanged: (c) {
          setState(() {
            _toDolist[index]["ok"] = c ;
            _saveData();
          });
        },
      ),
      onDismissed: (direction){
       setState(() {
         _lastRemoved = Map.from(_toDolist[index]);
         _lasRemodevPos = index ;
         _toDolist.removeAt(index);

         _saveData();

         final snack = SnackBar(
           content: Text("Tarerefa ${_lastRemoved["title"]} removida"),
           action: SnackBarAction(
             label: "Desfazer",
             onPressed: (){
               setState(() {
                 _toDolist.insert(_lasRemodevPos, _lastRemoved);
                 _saveData();
               });
             },
           ),
           duration: Duration(seconds: 2),
         );
        Scaffold.of(context).removeCurrentSnackBar();
         Scaffold.of(context).showSnackBar(snack);
       });
      },
    );
  }


  Future<File> _gerfile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDolist);
    final file = await _gerfile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _gerfile();
      return file.readAsString();
    } catch (e) {
      return null ;
    }
  }

}



