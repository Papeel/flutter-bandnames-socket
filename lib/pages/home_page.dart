import 'dart:io';

import 'package:band_names/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id:'1',name: 'Metallica', votes: 5),
    Band(id:'2',name: 'Queen', votes: 1),
    Band(id:'3',name: 'Héroes del Silencio', votes: 2),
    Band(id:'4',name: 'Bon Jovi', votes: 4),
    Band(id:'5',name: 'ACDC', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle( color: Colors.black87),),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index)  => _bandTile(bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
   );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ) {
        print('direction: $direction');
        print('id: ${band.id}');
        //TODO: llamar borrado del server
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete band', style: TextStyle(color: Colors.white),),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20),),
        onTap: () => print(band.name),
      ),
    );
  }

  addNewBand(){
    final textControler =  TextEditingController();
    if( Platform.isAndroid){
      return showDialog(
        context: context, 
        builder: ( context ) {
          return AlertDialog(
            title: Text('New ban name:'),
            content:  TextField(
              controller: textControler,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textControler.text)
              )
            ],
          );
        },
      );
    }

    return showCupertinoDialog(
      context: context, 
      builder: ( context ) {
        return CupertinoAlertDialog(
          title: Text('New band name'),
          content: CupertinoTextField(
            controller: textControler,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textControler.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
    );
    
  }

  void addBandToList( String name ){
    
    if(!name.isEmpty){
      this.bands.add(
        Band(
          id: DateTime.now().toString(),
          name: name,
          votes: 0
        )
      );
      //setstate se hace de forma automática
    }
    
    Navigator.pop(context);
  }
}