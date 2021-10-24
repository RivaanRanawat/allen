import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SuggestionBox extends StatefulWidget {
  final String headerText;
  final String descriptionText;
  final Color color;
  final List<String> texts;
  const SuggestionBox(
      {Key? key,
      required this.headerText,
      required this.descriptionText,
      required this.color,
      required this.texts})
      : super(key: key);

  @override
  State<SuggestionBox> createState() => _SuggestionBoxState();
}

class _SuggestionBoxState extends State<SuggestionBox> {
  bool _isDetails = false;

  List<Widget> displayDetails() {
    List<Widget> textWidgets = [];
    for (int i = 0; i < widget.texts.length; i++) {
      textWidgets.add(Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            "\u2022 ${widget.texts[i]}",
            style: const TextStyle(fontFamily: 'Cera Pro', fontSize: 14),
          ),
        ),
      ));
    }
    return textWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDetails = !_isDetails;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _isDetails
            ? (MediaQuery.of(context).size.height * 0.125 + ((displayDetails().length+1.5)*18))
            : MediaQuery.of(context).size.height * 0.124,
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.01,
          left: 35,
          right: 35,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        // padding: const EdgeInsets.onlt(10),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 15.0, bottom: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.headerText,
                  style: const TextStyle(
                    fontFamily: "Cera Pro",
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.descriptionText,
                    style: const TextStyle(
                      fontFamily: "Cera Pro",
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Visibility(
                visible: _isDetails,
                child: const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text("Commands",
                          style: TextStyle(
                              fontFamily: 'Cera Pro',
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ),
              Visibility(
                visible: _isDetails,
                child: Expanded(child: Column(children: displayDetails())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
