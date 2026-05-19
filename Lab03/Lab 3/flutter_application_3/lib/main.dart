import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
void main() {
  runApp
  (const MaterialApp(
    home:Lab03(),
  )
  );
  
}
class Lab03 extends StatelessWidget {
  const Lab03({super.key});
@override
  Widget build(BuildContext context) {
    return Scaffold(   
                //Task:01
      backgroundColor: const Color.fromARGB(255, 112, 115, 127),
      appBar: AppBar(
        actions:const[
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child:CircleAvatar(
              radius:50,
              backgroundImage: AssetImage('assets/cat.jpg'
            ),
          )
          ),
        ],
      ),
       body:Center(
        child:SingleChildScrollView(
       child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height:20),
            const CircleAvatar(
              radius:60,backgroundImage: NetworkImage('https://picsum.photos/200'),

            ),
            Card(
              elevation: 3.0,
              color: const Color.fromARGB(122, 12, 12, 11),
              child:Row(
                mainAxisSize: MainAxisSize.min,
                children:const[
                   Icon(Icons.abc_sharp,color:Colors.deepPurple,size:45),
                   Icon(Icons.favorite,color:Colors.lightGreenAccent, size:45),
                   Icon(Icons.install_mobile,color:Color.fromARGB(255, 255, 65, 100),size:45)
                ]
 ),
            ),
            Card(
              elevation:2.0,
              color:Color.fromARGB(122, 12, 12, 11),
              child:Column(
                mainAxisSize: MainAxisSize.min,
                children: const[
                  Icon(Icons.abc_sharp,color:CupertinoColors.activeOrange, size:55),
                   Icon(Icons.favorite,color:Colors.lightGreenAccent, size:55),
                   Icon(Icons.install_mobile,color:Color.fromARGB(255, 244, 67, 102),size:45)
                ]
              )
              ),
            Card(
              elevation:4,
              color:Color.fromARGB(122, 12, 12, 11),
              child:Row(
                mainAxisSize: MainAxisSize.min,
                children:const[
                  Icon(Icons.install_mobile,color:Colors.limeAccent,size:65),
                   Icon(Icons.install_mobile,color: Color.fromARGB(255, 65, 255, 157),size:65),
                    Icon(Icons.install_mobile,color:Color.fromARGB(255, 255, 65, 100),size:65)
                   ]
              )
            ),
            Card(
              elevation:8,shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading:const CircleAvatar(
                  child:Icon(Icons.person),
                ),
                title: const Text("Noor ul Ain"),
                subtitle: const Text("Registration No: 23-NTU-BSSE-1221"),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation:8,shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child:ListTile(
                leading:const CircleAvatar(
                  child:Icon(Icons.person),
                ),title:const Text("Ainy"),
                subtitle:const Text("Registration No: 23-NTU-BSSE-01"),
                trailing: const Icon(
                       Icons.call,
                       color:Colors.pink,
                )
              )
                 
            ),
            Container(
              color:Colors.lightGreen,
              padding: EdgeInsets.all(20.0),
              margin:EdgeInsets.symmetric(vertical:50.0,horizontal:10.0),
              child:Container(
                padding: EdgeInsets.only(left: 10),
                color: Colors.white,
                child:Text(
                  "margin and padding difference"
                  )
              )
            )
            
             ],
           ),
  )
       ),
    );
  }
}