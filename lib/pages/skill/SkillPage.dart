import 'package:flutter/material.dart';
import 'package:gocv/apis/api.dart';
import 'package:gocv/pages/skill/AddEditSkillPage.dart';
import 'package:gocv/providers/UserDataProvider.dart';
import 'package:gocv/utils/constants.dart';
import 'package:gocv/utils/helper.dart';
import 'package:gocv/utils/urls.dart';
import 'package:provider/provider.dart';

class SkillPage extends StatefulWidget {
  final String resumeId;

  const SkillPage({
    Key? key,
    required this.resumeId,
  }) : super(key: key);

  @override
  State<SkillPage> createState() => _SkillPageState();
}

class _SkillPageState extends State<SkillPage> {
  late UserProvider userProvider;
  late String accessToken;

  List<dynamic> skillList = [];

  bool isLoading = true;
  bool isError = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();

    userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    setState(() {
      accessToken = userProvider.tokens['access'].toString();
    });

    fetchSkills(widget.resumeId);
  }

  fetchSkills(String resumeId) {
    final String url = '${URLS.kSkillUrl}$resumeId/list/';

    APIService().sendGetRequest(accessToken, url).then((data) async {
      if (data['status'] == Constants.HTTP_OK) {
        setState(() {
          skillList = data['data']['data'];
          isLoading = false;
          isError = false;
          errorText = '';
        });
      } else {
        if (Helper().isUnauthorizedAccess(data['status'])) {
          Helper().showSnackBar(
            context,
            Constants.SESSION_EXPIRED_MSG,
            Colors.red,
          );
          Helper().logoutUser(context);
        } else {
          print(data['error']);
          setState(() {
            isLoading = false;
            isError = true;
            errorText = data['error'];
          });
          Helper().showSnackBar(
            context,
            'Failed to fetch skills',
            Colors.red,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AddEditSkillPage(
                resumeId: widget.resumeId,
              );
            },
          ));
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                )
              : skillList.isEmpty
                  ? const Center(
                      child: Text(
                        'No skills added',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        fetchSkills(widget.resumeId);
                      },
                      child: ListView.builder(
                        itemCount: skillList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showBottomSheet(
                                context,
                                skillList[index]['uuid'],
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.language,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: width * 0.7,
                                        child: Text(
                                          skillList[index]['skill'] +
                                              ' - ' +
                                              skillList[index]['proficiency'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  skillList[index]['description'] == null ||
                                          skillList[index]['description'] == ''
                                      ? const SizedBox()
                                      : Row(
                                          children: [
                                            const Icon(
                                              Icons.description,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              width: width * 0.7,
                                              child: Text(
                                                skillList[index]['description'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showBottomSheet(BuildContext context, String skillId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AddEditSkillPage(
                      resumeId: widget.resumeId,
                      skillId: skillId,
                    );
                  }));
                },
                child: const Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8.0),
                    Text('Update'),
                  ],
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () {
                  // _showDeleteConfirmationDialog(context, experienceId);
                },
                child: const Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8.0),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
