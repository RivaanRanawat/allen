import 'package:allen/screens/home_screen.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';

class StartingScreen extends StatefulWidget {
  const StartingScreen({Key? key}) : super(key: key);

  @override
  _StartingScreenState createState() => _StartingScreenState();
}

class _StartingScreenState extends State<StartingScreen> {
  List<dynamic> pages = [
    {'image': 'assets/images/news.png', 'text': 'Get the all the latest news!',},
    {
      'image': 'assets/images/todo-list.png',
      'text': 'Manage your tasks with To-Do List!'
    },
    {'image': 'assets/images/expense.png', 'text': 'Calculate your expenses!'},
    {
      'image': 'assets/images/bitcoin.png',
      'text': 'Know More about bitcoin and it\'s value!'
    },
    {
      'image': 'assets/images/calendarAlarm.png',
      'text': 'Set Calendar events, alarm and reminders!'
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
          radius: 30,
          verticalPosition: 0.85,
          onFinish: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          itemBuilder: (index, value) {
            int pageIndex = (index % pages.length);
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    pages[pageIndex]['image'],
                    width: 300,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      pages[pageIndex]['text'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: pageIndex==0 || pageIndex==3? Colors.black: Colors.white,
                      ),
                    ),
                  ),
                ]);
          },
          colors: const [
            Colors.white,
            Colors.blueAccent,
            Colors.pinkAccent,
            Color.fromRGBO(165, 231, 244, 1),
            Color.fromRGBO(157, 202, 235, 1)
          ]),
    );
  }
}
