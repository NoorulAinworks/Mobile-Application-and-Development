import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(
    home: Xylophone(),
  ));
}
class Xylophone extends StatelessWidget {
  const Xylophone({super.key});
  void PlaySound(int note){
    final player=AudioPlayer();
      player.play(AssetSource('note$note.wav')
    );
  }
  Widget Buildkey({required Color color, required int note, String label='Xylophone' }){
    return Expanded(
      child:TextButton(
        
        style:TextButton.styleFrom(
          backgroundColor: color,
          
          
         padding: EdgeInsets.zero,           
          shape: const RoundedRectangleBorder(),

          
        ),
        
        onPressed: (){
          PlaySound(note);
        },
        
child: Center(
  child: Text(
    label,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
),

      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Buildkey(color: const Color.fromARGB(255, 208, 26, 13), note:  1,label:'Xylophone'),
            Buildkey(color: const Color.fromARGB(255, 235, 95, 193), note:  2,label:'Xylophone'),
            Buildkey(color: const Color.fromARGB(255, 240, 215, 54), note:  3,label:'Xylophone'),
            Buildkey(color: const Color.fromARGB(255, 68, 199, 197), note:  4,label:'Xylophone'),
            Buildkey(color: const Color.fromARGB(255, 65, 240, 117), note:  5,label:'Xylophone'),
            Buildkey(color: const Color.fromARGB(255, 14, 49, 38), note:  6,label:'Xylophone'),
            Buildkey(color: const Color.fromARGB(255, 159, 177, 235), note:  7,label:'Xylophone'),
          ],
        ),
      ),
    );
  }
}