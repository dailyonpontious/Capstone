import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user == null)
              ElevatedButton(
                onPressed: () {
                  // userProvider.setUser(
                  //   User(name: 'Dailyon', email: 'dailyon@example.com'),
                  // );
                },
                child: const Text('Log in'),
              )
            else
              Text('Welcome, ${user.name}'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    );
  }

}