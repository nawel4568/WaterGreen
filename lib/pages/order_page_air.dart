import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:water/models/humidity.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../models/anibutton.dart';

class OrderPageAir extends StatefulWidget {
  Humidity humidity;
  OrderPageAir({Key? key,required this.humidity}) : super(key: key);

  @override
  State<OrderPageAir> createState() => _OrderPageAirState();
}

class _OrderPageAirState extends State<OrderPageAir> with SingleTickerProviderStateMixin{


  bool isDarkMode = false;
  late AnimationController _animationController;

  ////////// Bluetooth //////////////
  late BluetoothConnection _connection;
  late StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  late StreamSubscription<Uint8List>? _dataStreamSubscription;
  final List<BluetoothDiscoveryResult> _devices = [];
  String _humidityData = "0.0";
  bool _isConnected = false;


  @override
  void initState() {

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    super.initState();
    _initBluetooth();
    //_dataStreamSubscription = StreamSubscription.empty();
  }
  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();
    FlutterBluetoothSerial.instance.cancelDiscovery();
    _dataStreamSubscription?.cancel();
    if (_dataStreamSubscription == null) {
      print('Stream subscription canceled.');
    } else {
      print('Unable to cancel stream subscription.');
    }
    //_connection?.close();
    super.dispose();
  }

  Future<void> _initBluetooth() async{
    try{
      // Start Bluetooth Discovery
      _discoveryStreamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
        setState(() {
          _devices.add(r);
        });
      });

    }catch(ex){
      print('error initializing Bluetooth : $ex');
    }
  }

  void _connectToDevice(BluetoothDiscoveryResult device) async{
    try{
      //canceled discovery
      _discoveryStreamSubscription.cancel();

      // connect to selected device
      _connection = await BluetoothConnection.toAddress(device.device.address);
      setState(() {
        _isConnected = true;
      });

      //listen to received Data
      _dataStreamSubscription = _connection.input!.listen((data) {
        setState(() {
          _humidityData = utf8.decode(data);
        });
      });
      if (_dataStreamSubscription == null) {
        print('Stream subscription canceled.');
      } else {
        print('Unable to cancel stream subscription.');
      }
    }catch(ex){
      print('error connecting to device : $ex');
    }
  }

  void _DisconnectedFromDevice(){
    _connection.close();
    setState(() {
      _isConnected = false;
    });
  }



//////////////////////////////////

  // change the old parameters to the new one
  void changeParameters(){
    _sendData('$_humidityValue');
    print("the value is : $_humidityValue");
    //let user know is been successfully changed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Parameters successfully changed'),
      ),
    );
  }


  /////////// :

  changeThemeMode() {
    if(isDarkMode) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.forward(from: 1.0);
    }
  }


  double _humidityValue = 50;
  @override
  Widget build(BuildContext context) {
    double temp = double.tryParse('$_humidityData') ?? 0.0;
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(widget.humidity.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Humidity circle
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: CircularPercentIndicator(
                radius: 120.0,
                startAngle: 180,
                lineWidth: 20.0,
                percent: temp!/100,
                center: Text(
                  "$_humidityData%",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                progressColor: Colors.lightGreen[700],
                //animation: true,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),


            AnimatedToggle(
              values: ['ON', 'OFF'],
              onToggleCallback: (index) {
                isDarkMode = !isDarkMode;
                setState(() {
                  if(isDarkMode){
                    _sendData('0');
                    print('OFF');
                  }
                  else{
                    _sendData('1');
                    print('ON');
                  }
                  changeThemeMode();
                });
              },
            ),

            //****** Humidity level
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20 ),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Humidity',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 5),
                    SfSlider(
                        min: 0.0,
                        max: 100.0,
                        interval: 10,
                        stepSize: 10,
                        enableTooltip: true,
                        value:_humidityValue,
                        onChanged: (value) {
                          setState(() {
                            _humidityValue = value;
                          });
                        }
                    ),
                  ],
                ),
              ),
            ),


            //add change button
            MaterialButton(

              color: Colors.lightGreen[700],
              onPressed: changeParameters,

              child: const Text(
                "Change Parameters",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            if(_isConnected)
              ElevatedButton(
                onPressed: _DisconnectedFromDevice,
                child: Text('disconnect'),
              )
            else
              ElevatedButton(
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: AlertDialog(
                          title: Text('choose a device to connect'),
                          content: Column(
                            children: [
                              for(var device in _devices)
                                ListTile(
                                  title: Text(device.device.name ?? 'unknown Device'),
                                  subtitle: Text(device.device.address),
                                  onTap: (){
                                    Navigator.pop(context);
                                    _connectToDevice(device);

                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text('connect to device'),
              ),
          ],
        ),
      ),
    );

  }

  _sendData(String data) async{
    data = data.trim();
    print('send data : $data');

    try{
      _connection.output.add(Uint8List.fromList(utf8.encode(data)));
      await _connection.output.allSent;
    }catch(ex){
      // Ignore error, but notify state
    }
  }

}