import 'package:flutter/material.dart';

//Task 1: Creating a stateless widget and adding an appbar
void main() {
  runApp( MaterialApp(
    home:MyWidget()
    
  )
  
  );
}



class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(      //Task2
        title:Text("Flutter Lab 1"),
        backgroundColor: const Color.fromARGB(255, 43, 15, 169),  //Task 2:changing the color of appbar
        foregroundColor: Colors.black,
        centerTitle: true, // Task 3: Cenetr aligned the app bar

      ),
      body:Column(        //Task6 and 7
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text("Left Item"),
            SizedBox(width:20),     
            Text("Right item"),
          ],
          ),
          Expanded(child: Center(
            child:Text("Noor ul Ain",   //Task5
            style: TextStyle(
              fontSize: 24)),
            
          )
          ),
          SizedBox(height:20),
          Image.asset(
            'assets/glasses.jpg',    //Task 8:
            height:150,
          ),
          SizedBox(height: 20), // 
          Image.network(
            'https://picsum.photos/200/300', // Task 9: Any valid URL //final task
            height: 150,
          ),
          
        ],

      )
      
    );
  }
}