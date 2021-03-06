import 'package:flutter/material.dart';

import 'package:lbs_pedometer/lbs_pedometer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Pedometer _pedometer = Pedometer();

  List<Coordinate> _history = [];

  @override
  void initState() {
    super.initState();
    _pedometer.requestPermission();
    _pedometer.getHistory().then((list) {
      if (list != null){
        _history.addAll(list);
        _pedometer.start(onTakeStep: onTakeStep);
        for(Coordinate data in list){
          print(data.toString());
        }

        if (mounted){
          setState(() { });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'background pedometer plug in'.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      MaterialButton(
                        padding: EdgeInsets.all(16),
                        onPressed: clickStart,
                        child: Center(
                          child: Text(
                            'START',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      MaterialButton(
                        padding: EdgeInsets.all(16),
                        onPressed: clickStop,
                        child: Center(
                          child: Text(
                            'STOP',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30,),

                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, pos){
                        return ListTile(
                          title: Text('lat: ${_history[pos].latitude}, '
                              '\nlng: ${_history[pos].latitude}'),
                        );
                      },
                      itemCount: _history.length,
                    ),
                  ),

                ],
              ),
            ),
          )
      ),
    );
  }

  void clickStart() {
    _pedometer.start(
      onTakeStep: onTakeStep,
    );
  }

  void clickStop() async{
    _pedometer.stop(onEnd: (coordinates){
      for(Coordinate data in coordinates){
        print(data);
      }
    });
    _history.clear();
    if (mounted){
      setState(() { });
    }
  }

  void onTakeStep(Coordinate coordinate) {
    _history.add(coordinate);
    if (mounted){
      setState(() { });
    }
  }

}
