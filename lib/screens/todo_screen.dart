import 'package:allen/models/todo.dart';
import 'package:allen/services/db_helper.dart';
import 'package:allen/widgets/custom_drawer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String dayName = 'sat';
  bool checkBox = false;
  DateFormat date = DateFormat('d MMM');
  final TextEditingController taskController = TextEditingController();
  final AdvancedDrawerController _advancedDrawerController = AdvancedDrawerController();

  List<Todo> todos = [];
  bool isLoading = false;

  @override
  void dispose() {
    TodoDatabase.instance.close();
    super.dispose();
  }

  Future refreshTodos() async {
    setState(() => isLoading = true);

    todos = await TodoDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    refreshTodos();
    dayName =
        DateFormat('EEEE').format(DateTime.now()).substring(0, 3).toLowerCase();
  }

  Future addTodo(String title) async {
    final note = Todo(
        title: title,
        // id: 1,
        date: DateFormat.yMMMMd('en_US').format(DateTime.now()));

    await TodoDatabase.instance.create(note);
    refreshTodos();
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
        backgroundColor: isLoading ? Colors.white : Color(0xFF4044C9),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.09),
                  color: const Color(0xFF4044C9),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadeIn(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('  ${todos.length} tasks',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18)),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => showDialog(
                                context: context,
                                builder: (context) {
                                  return FadeIn(
                                    child: SimpleDialog(
                                      children: [
                                        SimpleDialogOption(
                                          onPressed: () {},
                                          child: TextField(
                                            controller: taskController,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: Colors.transparent,
                                                      width: 0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: Colors.transparent,
                                                      width: 0),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14),
                                                filled: true,
                                                fillColor: Color(0xffF5F6FA),
                                                hintText: "Enter Task",
                                                hintStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                )),
                                          ),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () {
                                            if (taskController
                                                .text.isNotEmpty) {
                                              addTodo(taskController.text);
                                              Navigator.of(context).pop();
                                              setState(() {
                                                taskController.text = "";
                                              });
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: const [
                                              Icon(Iconsax.tick_circle),
                                              Padding(
                                                padding: EdgeInsets.all(7),
                                                child: Text(
                                                  "Add",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            child: SlideInRight(
                              child: Container(
                                height: 60,
                                width: 150,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(70)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Add Task',
                                    style: TextStyle(
                                        color: Color(0xFF4044C9), fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            !isLoading
                ? Expanded(
                    flex: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(70)),
                      ),
                      child: ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (BuildContext context, int index) {
                          return FadeInLeft(
                            duration: Duration(
                                milliseconds:
                                    (index + 1) * 300 + (index + 1) * 400),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: ListTile(
                                  title: Text(
                                    '${(index + 1).toString()}. ${todos[index].title}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    todos[index].date,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Iconsax.trash4,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await TodoDatabase.instance
                                          .delete(todos[index].id);
                                      refreshTodos();
                                    },
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }
}
