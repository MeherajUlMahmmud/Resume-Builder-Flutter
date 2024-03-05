import 'package:gocv/models/resume.dart';
import 'package:gocv/providers/CurrentResumeProvider.dart';
import 'package:gocv/providers/ResumeListProvider.dart';
import 'package:gocv/providers/UserDataProvider.dart';
import 'package:gocv/repositories/resume.dart';
import 'package:gocv/screens/main_screens/ResumeDetailsScreen.dart';
import 'package:gocv/screens/profile_screens/ProfileScreen.dart';
import 'package:gocv/screens/utility_screens/SettingsScreen.dart';
import 'package:gocv/utils/constants.dart';
import 'package:gocv/utils/helper.dart';
import 'package:gocv/widgets/resume_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ResumeRepository resumeRepository = ResumeRepository();

  late String userId;

  late ResumeListProvider resumeListProvider;
  late CurrentResumeProvider currentResumeProvider;

  TextEditingController titleController = TextEditingController();

  List<Resume> resumes = [];
  bool isLoading = true;
  bool isError = false;
  String errorText = '';

  Map<String, dynamic> newResumeData = {};

  @override
  void initState() {
    super.initState();

    resumeListProvider = Provider.of<ResumeListProvider>(
      context,
      listen: false,
    );
    currentResumeProvider = Provider.of<CurrentResumeProvider>(
      context,
      listen: false,
    );

    setState(() {
      userId = UserProvider().userData!.id.toString();
    });

    fetchResumes();
  }

  fetchResumes() async {
    try {
      final response = await resumeRepository.getResumes(userId);
      print(response);

      if (response['status'] == Constants.httpOkCode) {
        final List<Resume> fetchedResumes = (response['data'] as List)
            .map<Resume>((resume) => Resume.fromJson(resume))
            .toList();
        setState(() {
          resumes = fetchedResumes;
          resumeListProvider.setResumeList(resumes);
          isLoading = false;
          isError = false;
          errorText = '';
        });
      } else {
        if (Helper().isUnauthorizedAccess(response['status'])) {
          if (!mounted) return;
          Helper().showSnackBar(
            context,
            Constants.sessionExpiredMsg,
            Colors.red,
          );
          Helper().logoutUser(context);
        } else {
          setState(() {
            isLoading = false;
            isError = true;
            errorText = response['message'];
          });
          Helper().showSnackBar(
            context,
            Constants.genericErrorMsg,
            Colors.red,
          );
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
        errorText = 'Error fetching resumes: $error';
      });
      Helper().showSnackBar(
        context,
        'Error fetching resumes',
        Colors.red,
      );
    }
  }

  void createResume() async {
    try {
      final response = await resumeRepository.createResume(newResumeData);
      if (response['status'] == Constants.httpCreatedCode) {
        Resume resume = Resume.fromJson(response['data']);
        resumeListProvider.addResume(resume);

        setState(() {
          isLoading = false;
          isError = false;
          errorText = '';
        });
        Navigator.pop(context);
      } else {
        if (Helper().isUnauthorizedAccess(response['status'])) {
          Helper().showSnackBar(
            context,
            Constants.sessionExpiredMsg,
            Colors.red,
          );

          Helper().logoutUser(context);
        } else {
          setState(() {
            isLoading = false;
            isError = true;
            errorText = response['error'];
          });

          Helper().showSnackBar(
            context,
            'Failed to create resume',
            Colors.red,
          );
        }
      }
    } catch (error) {
      // Handle error
      Helper().showSnackBar(
        context,
        'Failed to create resume: $error',
        Colors.red,
      );
    }
  }

  void deleteResume(int index) async {
    try {
      String resumeId = resumeListProvider.resumeList[index].id.toString();
      final response = await resumeRepository.deleteResume(resumeId);
      if (response['status'] == Constants.httpDeletedCode) {
        resumeListProvider.removeResume(index);

        setState(() {
          isLoading = false;
          isError = false;
          errorText = '';
        });
      } else {
        // Handle error
        Helper().showSnackBar(
          context,
          response['message'] ?? 'Failed to delete resume',
          Colors.red,
        );
      }
    } catch (error) {
      // Handle error
      Helper().showSnackBar(
        context,
        'Failed to delete resume: $error',
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          Constants.appName,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              curve: Curves.easeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image.asset(
                      //   'assets/images/logo.png',
                      //   width: 40,
                      //   height: 40,
                      // ),
                      SizedBox(width: 10),
                      Text(
                        Constants.appName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Build Resume on the Go',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, size: 24),
              title: const Text(
                'Home',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_2_outlined, size: 24),
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, ProfileScreen.routeName);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.list,
                size: 24,
              ),
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
            ),
            ListTile(
              leading: const RotationTransition(
                turns: AlwaysStoppedAnimation(180 / 360),
                child: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text('Would you like to logout?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Logout'),
                          onPressed: () {
                            Helper().logoutUser(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                fetchResumes();
              },
              child: isError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorText,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          ElevatedButton(
                            onPressed: () {
                              fetchResumes();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 10.0,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showAddDialog(context);
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      padding: const EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.receipt_long),
                                          SizedBox(width: 10),
                                          Text(
                                            'New Resume',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     // Navigator.pushNamed(
                                  //     //   context,
                                  //     //   CoverLetterScreen.routeName,
                                  //     // );
                                  //   },
                                  //   child: Container(
                                  //     width: width * 0.45,
                                  //     padding: const EdgeInsets.all(15.0),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.grey.shade100,
                                  //       borderRadius:
                                  //           BorderRadius.circular(10.0),
                                  //     ),
                                  //     child: const Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         Icon(Icons.receipt_long),
                                  //         SizedBox(width: 10),
                                  //         Text(
                                  //           'Cover Letter',
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: width,
                              child: const Text(
                                'My Resumes',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: resumeListProvider.resumeList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    currentResumeProvider.setCurrentResume(
                                      resumeListProvider.resumeList[index],
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      ResumeDetailsScreen.routeName,
                                    );
                                  },
                                  child: ResumeCard(
                                    resume:
                                        resumeListProvider.resumeList[index],
                                    onDeleteAction: () {
                                      deleteResume(index);
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
            ),
    );
  }

  showAddDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget okButton = TextButton(
      child: const Text('Create'),
      onPressed: () async {
        setState(() {
          newResumeData['name'] = titleController.text;
          newResumeData['user'] = userId;
          isLoading = true;
        });
        titleController.clear();
        createResume();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Create a new resume'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resume title',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            autofocus: true,
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Resume title',
            ),
            keyboardType: TextInputType.text,
          ),
        ],
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
