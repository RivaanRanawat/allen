import 'package:allen/screens/expense_tracker_screen.dart';
import 'package:allen/screens/home_screen.dart';
import 'package:allen/screens/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                margin: const EdgeInsets.only(
                  left: 20,
                  top: 24.0,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/male.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(),
              ),
              const Spacer(),
              Divider(
                color: Colors.grey.shade800,
              ),
              ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                ),
                leading: const Icon(Iconsax.home),
                title: const Text('Home'),
              ),
              ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TodoScreen(),
                  ),
                ),
                leading: const Icon(Iconsax.task),
                title: const Text('To-Do List'),
              ),
              ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ExpenseTrackerScreen(),
                  ),
                ),
                leading: const Icon(Iconsax.wallet),
                title: const Text('Expense Manager'),
              ),
              const SizedBox(
                height: 50,
              ),
              Divider(color: Colors.grey.shade800),
              ListTile(
                onTap: () async {
                  if (await canLaunch("https://github.com/rivaanranawat/allen")) {
                    await launch("https://github.com/rivaanranawat/allen");
                  }
                },
                leading: const Icon(Iconsax.code4),
                title: const Text('Source Code'),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
