import 'package:flutter/material.dart';

void main() {
  runApp( MaterialApp(
    home:MyWidget()
    
  )
  
  );
}



class MyWidget extends StatefulWidget {        //Task: 6
  const MyWidget({super.key});
  @override
  State<MyWidget> createState()=> _MyWidgetState();
}
class _MyWidgetState extends State<MyWidget> {

  bool isFollowed = false;
  int score = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(    
      body:SafeArea( 
             
        child: Container(         
          
          margin:EdgeInsets.all(20.0),
         child:Center(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children :[CircleAvatar(
              radius:50,
              backgroundImage: AssetImage('assets/cat.jpg')),
              Text('Noor ul Ain'),
              Text('23-NTU-CS-1221'),
              SizedBox(
                  width:20,height:20,),
                   // Task 7: Like Button
                   ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFollowed = !isFollowed;
                    });
                  },
                  child: Text(
                    isFollowed ? "Following" : "Follow",
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.orange),
                  onPressed: () {
                    setState(() {
                      score++;
                    });
                  },
                ),
              //Task :8
              Card(
                elevation:4,
                child:ListTile(
                  leading:Icon(Icons.favorite,color:Colors.orange),
                  title: Text("Likes"),
                  subtitle: Text("Total likes received"),
                  trailing: Text('$score'),
                )
              ),
              //phase 2
              Row(           //Task4
                children:[
                Expanded(
                  flex:2,
                  child:Container(
                    height:100,
                    color: const Color.fromARGB(255, 243, 171, 231),
                  ),
                ),
                SizedBox(
                  height:20,
                  width:20,
                  ),
              Expanded(
                  flex:1,

                  child:Container(
                    height:100,
                    color:Color.fromARGB(255, 245, 171, 210)
                  ),
                )]) ]
          )
        ) 
        )
      )
      
     
  );
  }
}                 


