import 'package:allen/widgets/custom_drawer.dart';
import 'package:allen/widgets/news_card.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:iconsax/iconsax.dart';

class NewsScreen extends StatefulWidget {
  final List newsArticles;
  const NewsScreen({Key? key, required this.newsArticles}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _advancedDrawerController = AdvancedDrawerController();
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
        appBar: AppBar(
          elevation: 0,
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
          centerTitle: true,
          title: const Text(
            "Allen",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: ListView.builder(
          itemCount: widget.newsArticles.length,
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return FadeInLeft(
                child: NewsCard(
                  description: widget.newsArticles[index]["description"] ?? "",
                  imageUrl: widget.newsArticles[index]["urlToImage"] ?? "",
                  url: widget.newsArticles[index]["url"] ?? "",
                  title: widget.newsArticles[index]["title"] ?? "",
                ),
              );
            }
            return FadeInRight(
              child: NewsCard(
                description: widget.newsArticles[index]["description"] ?? "",
                imageUrl: widget.newsArticles[index]["urlToImage"] ?? "",
                url: widget.newsArticles[index]["url"] ?? "",
                title: widget.newsArticles[index]["title"] ?? "",
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }
}
