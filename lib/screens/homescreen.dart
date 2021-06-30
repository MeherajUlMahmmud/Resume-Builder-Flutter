import 'package:cv_builder/pages/home.dart';
import 'package:cv_builder/pages/persons.dart';
import 'package:cv_builder/pages/samples.dart';
import 'package:cv_builder/pages/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentTabIndex = 0;

  //pages
  List<Widget> pages;
  Widget currentPage;

  HomePage homePage;
  SamplePage samplePage;
  PersonPage personPage;

  @override
  void initState() {
    //widget.model.fetchFood();

    homePage = HomePage();
    samplePage = SamplePage();
    personPage = PersonPage();

//    explorePage = ExplorePage(model: widget.model);

//    categoryPage = CategoryPage(model: widget.model);
    pages = [homePage, samplePage, personPage];

    currentPage = homePage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: currentTabIndex == 0
            ? Text(
                "Resume Builder",
              )
            : currentTabIndex == 1
                ? Text(
                    "Sample Resumes",
                  )
                : Text(
                    "Created Profiles",
                  ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Feather.settings,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Settings()));
            },
          ),
        ],
      ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
            currentPage = pages[index];
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        // unselectedItemColor: Colors.grey[500],
        elevation: 0.0,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTabIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Feather.credit_card,
              ),
              label: "Resumes"),
          BottomNavigationBarItem(
            icon: Icon(
              Feather.grid,
            ),
            label: "Samples",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Feather.user,
            ),
            label: "Persons",
          ),
        ],
      ),
    );
  }
}
