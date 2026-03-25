import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Lab2Home(),
  ));
}
class Lab2Home extends StatelessWidget {
  const Lab2Home({super.key});
              
  @override        
  Widget build(BuildContext context) {
    return Scaffold(   //Task1
      backgroundColor:Colors.blueGrey,     //setting the background color
      body: SafeArea(
        child:SingleChildScrollView(
          //width:double.infinity
         child:Column(                //Task2
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
             color:Colors.green,
             width:250,
            height:250,
            margin: EdgeInsets.all(25.0),
            padding:const EdgeInsets.symmetric(vertical:15),), 
            Icon(Icons.favorite,color: Colors.black,size: 25,),
            SizedBox(
                 height:60.0,
            ),
            Icon(Icons.thumb_up,color: Colors.black,size: 25,),
            Icon(Icons.share,color: Colors.black,size: 25,),
            //Task 3
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
              Icon(Icons.volume_up,color: Colors.black,size:25),
               Icon(Icons.bluetooth,color: Colors.black,size:25),
               Icon(Icons.wifi,color: Colors.black,size:25),
               
               ]
            ),
            //Task4
            SizedBox(
                width: double.infinity,
           
            child:Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height:100,
                  color:Colors.blue,
                  width:double.infinity,
                ),
                SizedBox(
                  height:20,
                ),
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                  children: [
                    Container(
                      width:50,
                      height:50,
                      color: Colors.red,
                    ),
                    Container(
                       width:50,
                      height:50,
                      color: Colors.green,
                    )
                  ],
)
              ],
            ),
              ),
            ],
        ),
        ) 
          )
      );
      }
}