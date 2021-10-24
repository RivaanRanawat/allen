import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:allen/models/expense.dart';
import 'package:allen/models/todo.dart';
import 'package:allen/screens/expense_tracker_screen.dart';
import 'package:allen/screens/news_screen.dart';
import 'package:allen/screens/todo_screen.dart';
import 'package:allen/services/db_helper.dart';
import 'package:allen/services/expense_db_helper.dart';
import 'package:allen/widgets/custom_drawer.dart';
import 'package:allen/widgets/suggestion_box.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:iconsax/iconsax.dart';
import 'package:system_settings/system_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _advancedDrawerController = AdvancedDrawerController();
  String sdkKey =
      "7277de6e5e27e6ebc6f3d54478828ef32e956eca572e1d8b807a3e2338fdd0dc/stage";
  List newsArticles = [];
  String day = "";
  var isAlarm = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidInitializationSettings initializationSettingsAndroid;
  bool _isScrolled = false; // for showing the list of the commands
  bool isScrolling = false; //
  late ScrollController _scrollController;

  initAlan() {
    AlanVoice.addButton(sdkKey, buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.onCommand.add((command) => _handleCommand(command.data));
  }

  initLocalNotif() async {
    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (_) {});
  }

  /* 
  COMMANDS:
    NEWS:
    -> Give me the latest Business, Entertainment, General, Health, Science, Sports, Technology news
    -> What's up with Bitcoin or any other term
    -> Give me the news from BBC News/CNN/IGN/ The Times of India
    Casual Conversation:
    -> can do a lot of casual conversation to give human feel
    TRANSLATION:
    -> How would you say programming in spanish
    -> Translate programming to spanish
    -> translate
    CALCULATOR:
    -> What is 40+40
    -> 9 multiplied by 9 equals?
    WEATHER:
    -> What is the weather in mumbai?
    -> What is the humidity like in boston?
    Social:
    -> Send Email
    -> Call ${Phone}
    -> Search on Google
    -> Watch Youtube
    -> Open Instagram
    -> Show Me Directions from ___ to ___
    -> Send SMS
    Jokes:
    -> Tell me a joke
    Alarm:
    -> Set an alarm in minutes/seconds/hours
    Reminder:
    -> Give/Set me a reminder to take pet outside in 2 minutes/hours/seconds
    Quotes:
    -> can you tell me a quote
    -> can you motivate me
    -> can you tell me a quote by Albert Einstein
    Calendar:
    -> Add event to calendar
    Open Settings:
    -> so many settings bruh
    Todo List:
      -> Show me my todo list
      -> Add {} to my todo list
      -> How many tasks am i left with
  */

  void _handleCommand(Map<String, dynamic> response) async {
    switch (response["command"]) {
      case "newHeadlines":
        newsArticles = response["articles"];
        if (newsArticles != []) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewsScreen(newsArticles: newsArticles),
            ),
          );
        }
        break;
      case "sendEmail":
        final Email email = Email(
          body: response["emailData"]["body"],
          subject: response["emailData"]["subject"],
          recipients: [response["emailData"]["mailTo"]],
          isHTML: false,
        );

        await FlutterEmailSender.send(email);
        break;
      case "callPhone":
        String phoneNum = response["phone"]["phoneNum"];
        if (await canLaunch("tel:$phoneNum")) {
          await launch("tel:$phoneNum");
        }
        break;
      case "searchGoogle":
        String searchUrl = response["search"]["searchUrl"];
        if (await canLaunch("https://www.google.com/search?q=$searchUrl")) {
          await launch("https://www.google.com/search?q=$searchUrl");
        }
        break;
      case "searchYoutube":
        String searchUrl = response["search"]["searchUrl"];
        if (await canLaunch(
            "https://www.youtube.com/results?search_query=$searchUrl")) {
          await launch(
              "https://www.youtube.com/results?search_query=$searchUrl");
        }
        break;
      case "openInstagram":
        if (await canLaunch("https://www.instagram.com/")) {
          await launch(
            "https://www.instagram.com/",
            universalLinksOnly: true,
          );
        }
        break;
      case "openMaps":
        String destinationPlace = response["destinationName"];
        String originPlace = response["originName"] ?? "";
        if (await canLaunch(
            "https://www.google.com/maps/dir/?api=1&origin=$originPlace&destination=$destinationPlace")) {
          await launch(
              "https://www.google.com/maps/dir/?api=1&origin=$originPlace&destination=$destinationPlace");
        }
        break;
      case "smsPhone":
        String phoneNum = response["phone"]["phoneNum"];
        String smsBody = response["phone"]["smsBody"];
        if (await canLaunch("sms:$phoneNum?body=$smsBody")) {
          await launch(
            "sms:$phoneNum?body=$smsBody",
            universalLinksOnly: true,
          );
        }
        break;
      case "setAlarm":
        if (response["time"] == "minute") {
          Future.delayed(
              Duration(minutes: int.parse(response["alarmDuration"])), () {
            FlutterRingtonePlayer.playAlarm(volume: 1);
            setState(() {
              isAlarm = true;
            });
          });
        } else if (response["time"] == "second") {
          Future.delayed(
              Duration(seconds: int.parse(response["alarmDuration"])), () {
            FlutterRingtonePlayer.playAlarm(volume: 1);
            setState(() {
              isAlarm = true;
            });
          });
        } else {
          Future.delayed(Duration(hours: int.parse(response["alarmDuration"])),
              () {
            FlutterRingtonePlayer.playAlarm(volume: 1);
            setState(() {
              isAlarm = true;
            });
          });
        }
        break;
      case "wifiSettings":
        SystemSettings.wifi();
        break;
      case "displaySettings":
        SystemSettings.display();
        break;
      case "soundSettings":
        SystemSettings.sound();
        break;
      case "bluetoothSettings":
        SystemSettings.bluetooth();
        break;
      case "locationSettings":
        SystemSettings.location();
        break;
      case "appSettings":
        SystemSettings.apps();
        break;
      case "accessSettings":
        SystemSettings.accessibility();
        break;
      case "securitySettings":
        SystemSettings.security();
        break;
      case "settings":
        SystemSettings.system();
        break;
      case "storageSettings":
        SystemSettings.internalStorage();
        break;
      case "dndSettings":
        SystemSettings.notificationPolicy();
        break;
      case "networkSettings":
        SystemSettings.wireless();
        break;
      case "addToCalendar":
        final Event event = Event(
          title: response["event"]["eventTitle"],
          description: response["event"]["eventDescription"],
          startDate: DateTime(
            2021,
            response["event"]["startDateMonth"],
            int.parse(response["event"]["startDateDay"]),
          ),
          endDate: DateTime(
            2021,
            response["event"]["endDateMonth"],
            int.parse(response["event"]["endDateDay"]),
          ),
        );
        Add2Calendar.addEvent2Cal(event);
        break;
      case "setReminder":
        String title = response["reminderTitle"];
        await flutterLocalNotificationsPlugin.zonedSchedule(
            0,
            title,
            "You have to $title at ${DateFormat('jm').format(DateTime.now())}",
            tz.TZDateTime.now(tz.local).add(response["time"] == 'second'
                ? Duration(seconds: int.parse(response["reminderDuration"]))
                : response["time"] == 'hour'
                    ? Duration(hours: int.parse(response["reminderDuration"]))
                    : Duration(
                        minutes: int.parse(response["reminderDuration"]))),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'your channel id',
                'your channel name',
                channelDescription: 'your channel description',
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
        break;
      case "setTodo":
        String todoTitle = response["todoTitle"];
        final todo = Todo(
            title: todoTitle,
            // id: 1,
            date: DateFormat.yMMMMd('en_US').format(DateTime.now()));

        await TodoDatabase.instance.create(todo);
        break;
      case "showTodo":
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TodoScreen()));
        break;
      case "noOfTodo":
        List todos = await TodoDatabase.instance.readAllNotes();
        AlanVoice.playText("You are left with ${todos.length} tasks");
        break;
      case "readTodo":
        List todos = await TodoDatabase.instance.readAllNotes();
        for (int i = 0; i < todos.length; i++) {
          AlanVoice.playText(todos[i].title);
        }
        break;
      case "helpCommands":
        scrollToAllCommands();
        setState(() {
          _isScrolled = true;
        });
        break;
      case "addIncome":
        addExpense(
            response["title"], true, int.parse(response["income"].toString()));
        break;
      case "addExpense":
        addExpense(response["title"], false,
            int.parse(response["expense"].toString()));
        break;
      case "showExpenseScreen":
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ExpenseTrackerScreen()));
        break;
      case "showWallet":
        dynamic data = await refreshExpenses();
        String balance = data["balance"].toString();
        String income = data["income"].toString();
        String expense = data["expense"].toString();
        AlanVoice.playText(
            "Your total balance is $balance rupees with $income rupees income and $expense rupees expense.");
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }

  Future refreshExpenses() async {
    List<Expense> expenses = await ExpenseDatabase.instance.readAllExpenses();
    int balance = 0;
    int income = 0;
    int expense = 0;
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].incomeOrExpense == 'Income') {
        balance += expenses[i].money;
        income += expenses[i].money;
      } else {
        balance -= expenses[i].money;
        expense += expenses[i].money;
      }
    }
    return {"balance": balance, "income": income, "expense": expense};
  }

  Future addExpense(String title, bool isIncome, int money) async {
    final expense = Expense(
        title: title,
        // id: 1,
        money: money,
        incomeOrExpense: isIncome ? "Income" : "Expense");
    await ExpenseDatabase.instance.create(expense);
  }

  @override
  void initState() {
    super.initState();
    greet();
    initAlan();
    initLocalNotif();
    _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    TodoDatabase.instance.close();
    ExpenseDatabase.instance.close();
    super.dispose();
  }

  scrollToAllCommands() {
    _scrollController.animateTo(
        _scrollController.offset + MediaQuery.of(context).size.height * 0.37,
        curve: Curves.linear,
        duration: Duration(milliseconds: 500));
  }

  void greet() {
    int hour = DateTime.now().hour;
    if (hour < 12 && hour > 5) {
      day = "Morning";
    } else if (hour < 15) {
      day = "Afternoon";
    } else if (hour < 19) {
      day = "Evening";
    } else {
      day = "Night";
    }
  }

  List<Widget> suggestionBox() {
    int start = 300;
    int delay = 400;
    return [
      SlideInLeft(
        delay: Duration(milliseconds: start),
        child: const SuggestionBox(
            descriptionText:
                "See news from any source, about any term and category",
            headerText: "Get News",
            color: Color.fromRGBO(165, 231, 244, 1),
            texts: [
              "Show Me The News From CNN",
              "What's up with Cricket",
              "Show me the latest news in Technology"
            ]),
      ),
      SlideInLeft(
        delay: Duration(milliseconds: start + (delay)),
        child: const SuggestionBox(
            descriptionText:
                "Manage tasks of your day efficiently and productively",
            headerText: "To-Do List",
            color: Color.fromRGBO(157, 202, 235, 1),
            texts: [
              "Add Programming to my todo list",
              "How many tasks am I left with",
              "Show me my todo list",
              "Read my tasks",
            ]),
      ),
      SlideInLeft(
        delay: Duration(milliseconds: start + (2 * delay)),
        child: const SuggestionBox(
            descriptionText: "Calculate Your Income, Expense and total balance",
            headerText: "Expense Manager",
            color: Color.fromRGBO(162, 238, 239, 1),
            texts: [
              "25,000 income from Programming",
              "10,000 expense spent in Food",
              "What is my total balance"
            ]),
      ),
      Visibility(
        visible: _isScrolled,
        child: Column(
          children: [
            SlideInLeft(
              delay: Duration(milliseconds: start),
              child: const SuggestionBox(
                  descriptionText:
                      "Send, Search, Watch, Call, SMS and Get Directions",
                  headerText: "Social Media",
                  color: Color.fromRGBO(165, 231, 244, 1),
                  texts: [
                    "Send SMS to 9372656584 with body Hello",
                    "Show me directions from Mumbai to Pune",
                    "Call 9372656584",
                    "Search Bitcoin",
                    "Watch MrBeast",
                    "Send Email",
                  ]),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start + delay),
              child: const SuggestionBox(
                  descriptionText:
                      "Add events to calendar and set Reminders, Alarms",
                  headerText: "Reminders",
                  color: Color.fromRGBO(162, 238, 239, 1),
                  texts: [
                    "Send me a reminder to sleep in 1 minute",
                    "Ring an alarm in 40 seconds",
                    "Add an event to calendar",
                  ]),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start + delay),
              child: const SuggestionBox(
                  descriptionText:
                      "Know about weather of any region in the world",
                  headerText: "Get Weather",
                  color: Color.fromRGBO(157, 202, 235, 1),
                  texts: [
                    "What is the weather like in Mumbai",
                    "Is it raining in New Boston",
                    "What is the humidity"
                  ]),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start + (3 * delay)),
              child: const SuggestionBox(
                  descriptionText:
                      "Talk informally, get jokes, motivation or quotes by particular person",
                  headerText: "Casual Talk",
                  color: Color.fromRGBO(165, 231, 244, 1),
                  texts: [
                    "Can you tell me a quote by Albert Einstein",
                    "Can you motivate me",
                    "Tell me a joke",
                    "You're great!",
                  ]),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start + (4 * delay)),
              child: const SuggestionBox(
                  descriptionText:
                      "Translate any word or phrase from one language to another",
                  headerText: "Translation",
                  color: Color.fromRGBO(162, 238, 239, 1),
                  texts: [
                    "What languages can you translate to",
                    "How would you say life in Spanish",
                    "Translate programming to Spanish",
                  ]),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start + (5 * delay)),
              child: const SuggestionBox(
                  descriptionText:
                      "Know more about bitcoin and it's current price in various currencies",
                  headerText: "Bitcoin",
                  color: Color.fromRGBO(157, 202, 235, 1),
                  texts: [
                    "How many bitcoins are left",
                    "What was the past week bitcoin price",
                    "How much is bitcoin in rupees"
                  ]),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start),
              child: const SuggestionBox(
                  descriptionText:
                      "Add, Subtract, Multiply, Divide, square, cube, round off",
                  headerText: "Calculator",
                  color: Color.fromRGBO(165, 231, 244, 1),
                  texts: [
                    "What is 31 plus 32",
                    "What is 3 to the power 20",
                    "What is the square root of 54891"
                  ]),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start + (2 * delay)),
              child: const SuggestionBox(
                  descriptionText:
                      "Open various device settings like Network, App",
                  headerText: "Settings",
                  color: Color.fromRGBO(162, 238, 239, 1),
                  texts: [
                    "Open Accessibility Settings",
                    "Open Bluetooth Settings",
                    "Open Storage Settings",
                    "Open Network Settings",
                    "Open App Settings",
                    "Open Settings",
                  ]),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.grey.shade900,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.shade900,
            blurRadius: 20.0,
            spreadRadius: 5.0,
            offset: const Offset(-20.0, 0.0),
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      drawer: const CustomDrawer(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 80,
          backgroundColor: Colors.white,
          leading: IconButton(
            color: Colors.black,
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Iconsax.close_square : Iconsax.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
          actions: [
            IconButton(
              color: Colors.black,
              onPressed: () {
                setState(() {
                  _isScrolled = true;
                });
                scrollToAllCommands();
              },
              icon: const Icon(
                Iconsax.info_circle4,
              ),
            ),
          ],
          centerTitle: true,
          title: BounceInDown(
            child: const Text(
              "Allen",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ZoomIn(
                child: Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 120.0,
                          height: 120.0,
                          margin: const EdgeInsets.only(
                            top: 4.0,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(209, 243, 249, 1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          height: 123.0,
                          margin: const EdgeInsets.only(
                            top: 0.0,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/virtualAssistant.png'),
                              // fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeInRight(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03,
                      left: 40,
                      right: 40),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Color.fromRGBO(200, 200, 200, 1),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text("Good $day, what task can I do for you?",
                        style: const TextStyle(
                          fontFamily: "Cera Pro",
                          color: Color.fromRGBO(19, 61, 95, 1),
                          fontSize: 25.0,
                        )),
                  ),
                ),
              ),
              SlideInLeft(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: 22,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                      !_isScrolled
                          ? "Here are some suggestions"
                          : "Here are all the commands",
                      style: const TextStyle(
                        fontFamily: "Cera Pro",
                        color: Color.fromRGBO(19, 61, 95, 1),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Column(
                children: suggestionBox(),
              ),
            ],
          ),
        ),
        floatingActionButton: Visibility(
            visible: isAlarm,
            child: FadeIn(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: const Icon(Iconsax.stop, color: Colors.white),
                onPressed: () {
                  FlutterRingtonePlayer.stop();
                  setState(() {
                    isAlarm = false;
                  });
                },
              ),
            )),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }
}
