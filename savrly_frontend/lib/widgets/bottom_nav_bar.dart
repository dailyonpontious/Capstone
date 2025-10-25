
import 'package:flutter/material.dart'; 
import '../screens/profile_screen.dart'; 

class BottomNavBar extends StatelessWidget { 
  final int currentIndex; 
  final Function(int) onTap; 

  const BottomNavBar({ 
    super.key, 
    required this.currentIndex, 
    required this.onTap, 
  }); 

  @override 
  Widget build(BuildContext context) { 
    return BottomNavigationBar( 
      backgroundColor: Color.fromRGBO(184, 205, 159, 0.5),
      selectedItemColor: Colors.grey,
      unselectedItemColor: Colors.black,
      elevation: 0,
      currentIndex: currentIndex, 
      onTap: (index) { 
        if (index == 0){
          Navigator.popUntil(context, (route) => route.isFirst);
        }else if (index == 1){ 

        }else if (index == 2){ 
          Navigator.push( 
            context, 
            MaterialPageRoute<void>( 
              builder: (context) => const ProfilePage() 
            ), 
          ); 
        }
      }, 
      items: const [ 
        BottomNavigationBarItem( 
          icon: Icon(Icons.home), 
          label: 'Home', 
        ), 
        BottomNavigationBarItem( 
          icon: Icon(Icons.schedule), 
          label: 'Meal Plan', 
        ),
        // BottomNavigationBarItem( 
        //   icon: Icon(Icons.schedule), 
        //   label: 'Meal Plan', 
        // ), // This is for future use
        BottomNavigationBarItem( 
          icon: Icon(Icons.person), 
          label: 'Profile', 
        ),
      ], 
    ); 
  } 
}