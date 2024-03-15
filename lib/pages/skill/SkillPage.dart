import 'package:flutter/material.dart';
import 'package:gocv/models/skill.dart';
import 'package:gocv/pages/skill/AddEditSkillPage.dart';
import 'package:gocv/repositories/skill.dart';
import 'package:gocv/utils/constants.dart';
import 'package:gocv/utils/helper.dart';

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
  SkillRepository skillRepository = SkillRepository();

  List<Skill> skillList = [];

  bool isLoading = true;
  bool isError = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();

    fetchSkills(widget.resumeId);
  }

  fetchSkills(String resumeId) async {
    Map<String, dynamic> params = {
      'resume': resumeId,
    };

    try {
      final response = await skillRepository.getSkills(
        widget.resumeId,
        params,
      );

      if (response['status'] == Constants.httpOkCode) {
        final List<Skill> fetchedSkillList =
            (response['data']['data'] as List).map<Skill>((skill) {
          return Skill.fromJson(skill);
        }).toList();

        setState(() {
          skillList = fetchedSkillList;
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
          if (!mounted) return;
          Helper().showSnackBar(
            context,
            errorText,
            Colors.red,
          );
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
        errorText = 'Error fetching skill list: $error';
      });
      if (!mounted) return;
      Helper().showSnackBar(
        context,
        Constants.genericErrorMsg,
        Colors.red,
      );
    }
  }

  deleteSkill(String skillId) async {
    try {
      final response = await skillRepository.deleteSkill(skillId);

      if (response['status'] == Constants.httpNoContentCode) {
        setState(() {
          skillList.removeWhere(
            (skill) => skill.id.toString() == skillId,
          );
          isError = false;
        });

        if (!mounted) return;
        Helper().showSnackBar(
          context,
          'Skill deleted successfully',
          Colors.green,
        );
        Navigator.pop(context);
        Navigator.pop(context);
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
          if (!mounted) return;
          Helper().showSnackBar(
            context,
            errorText,
            Colors.red,
          );
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorText = 'Error deleting education details: $error';
      });
      Helper().showSnackBar(
        context,
        Constants.genericErrorMsg,
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddEditSkillPage(
                  resumeId: widget.resumeId,
                );
              },
            ),
          );
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
                          return skillItem(index, width);
                        },
                      ),
                    ),
    );
  }

  Widget skillItem(int index, double width) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: skillList[index].isActive == true
            ? Colors.white
            : Colors.grey.shade200,
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
                  '${skillList[index].name} - ${skillList[index].proficiency!}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AddEditSkillPage(
                                resumeId: widget.resumeId,
                                skillId: skillList[index].id.toString(),
                              );
                            },
                          ),
                        );
                      },
                      value: 'update',
                      child: const Text('Update'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Education'),
                              content: const Text(
                                'Are you sure you want to delete this education?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await deleteSkill(
                                      skillList[index].id.toString(),
                                    );
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      value: 'delete',
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ];
                },
              )
            ],
          ),
          const SizedBox(height: 10),
          skillList[index].description == null ||
                  skillList[index].description == ''
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
                        skillList[index].description ?? '',
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
    );
  }
}
