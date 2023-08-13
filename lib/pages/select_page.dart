import 'package:water/models/humidity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../componants/humidity_tile.dart';
import '../models/home.dart';


import 'order_page_air.dart';
import 'order_page_sol.dart';



class SelectPage extends StatefulWidget {


   SelectPage({
     super.key
   });
  @override
  State<SelectPage> createState() => _SelectPageState();

  void onToggleCallback(int index) {}
}
class _SelectPageState extends State<SelectPage>{




    bool initialPosition = true;
  void goToOrderPage(Humidity humidity,int index) {
    //navigate to order page
    if(index == 0){
      sol(humidity);
    }
    else{
      air(humidity);
    }
  }


    void sol(Humidity humidity) {
      //navigate to order page Sol
      Navigator.push(context, MaterialPageRoute(
        builder: (context) =>
            OrderPageSol(
              humidity: humidity,
            ),
      ));
    }
    void air(Humidity humidity) {
      //navigate to order page Air
      Navigator.push(context, MaterialPageRoute(
        builder: (context) =>
            OrderPageAir(
              humidity: humidity,
            ),
      ));
    }


  @override
  Widget build(BuildContext context) {

    return Consumer<HumidityHome>(
        builder: (context, value, child) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                // Heading
                Text(
                  'Humidity Page',
                  style: TextStyle(fontSize: 20),
                ),

                SizedBox(height: 50,),

                Expanded(
                  child: ListView.builder(
                      itemCount: value.selected.length,
                      itemBuilder: (context, index) {
                        //get individual humidity
                        Humidity indiviHumidity = value.selected[index];


                        //return to a nice tile
                        return HumidityTile(
                          humidity: indiviHumidity,
                          onTap: () => goToOrderPage(indiviHumidity, index),

                        );

                      }
                  ),
                ),


              ],

            ),

          ),
        )
    );
  }
}