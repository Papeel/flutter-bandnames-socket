import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:provider/provider.dart';

import 'package:band_names/models/models.dart';
import 'package:band_names/services/services.dart';


class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands',_handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload){
    this.bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();
      
    setState(() { });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle( color: Colors.black87),),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: 
            ServerStatus.Offline == socketService.serverStatus 
            ? Icon(Icons.offline_bolt, color: Colors.red[300],)
            : Icon(Icons.check_circle, color: Colors.blue[300],),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index)  => _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
   );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ )  => socketService.socket.emit('delete-band', {'id': band.id}),
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
        onTap: ()  =>
          socketService.socket.emit('vote-band', { 'id': band.id }),
      ),
    );
  }

  addNewBand(){
    final textControler =  TextEditingController();
    if( Platform.isAndroid){
      return showDialog(
        context: context, 
        builder: ( _ ) =>
          AlertDialog(
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
          ),
      );
    }

    return showCupertinoDialog(
      context: context, 
      builder: ( _ ) => CupertinoAlertDialog(
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
        ),
    );
    
  }

  void addBandToList( String name ){
    if(!name.isEmpty){
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }
    
    Navigator.pop(context);
  }

  final List<Color> colorList = [
    Colors.blue.shade50,
    Colors.blue.shade200,
    Colors.pink.shade50,
    Colors.pink.shade200,
    Colors.yellow.shade50,
    Colors.yellow.shade200,
    
  ];

  Widget _showGraph(){
    Map<String, double> dataMap = {};
    bands.forEach((band)=> dataMap.putIfAbsent(band.name, () => band.votes.toDouble()) );

    return Container(
      padding: EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 20,
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
        
      )
    );
  }
}