import 'package:gocv/apis/api.dart';
import 'package:gocv/models/experience.dart';
import 'package:gocv/pages/work_experience/AddEditWorkExperiencePage.dart';
import 'package:gocv/repositories/experience.dart';
import 'package:gocv/utils/constants.dart';
import 'package:gocv/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:gocv/utils/urls.dart';

class WorkExperiencePage extends StatefulWidget {
  final String resumeId;
  const WorkExperiencePage({
    Key? key,
    required this.resumeId,
  }) : super(key: key);

  @override
  State<WorkExperiencePage> createState() => _WorkExperiencePageState();
}

class _WorkExperiencePageState extends State<WorkExperiencePage> {
  ExperienceRepository experienceRepository = ExperienceRepository();

  List<Experience> experienceList = [];

  bool isLoading = true;
  bool isError = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();

    fetchWorkExperiences(widget.resumeId);
  }

  fetchWorkExperiences(String resumeId) {
    final String url = '${URLS.kExperienceUrl}$resumeId/list/';

    APIService().sendGetRequest(accessToken, url).then((data) async {
      if (data['status'] == Constants.HTTP_OK) {
        setState(() {
          experienceList = data['data']['data']
              .map<Experience>((experience) => Experience.fromJson(experience))
              .toList();
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
          setState(() {
            isLoading = false;
            isError = true;
            errorText = data['error'];
          });
          Helper().showSnackBar(
            context,
            'Failed to fetch work experiences',
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AddEditWorkExperiencePage(
                resumeId: widget.resumeId,
              );
            },
          ));
        },
      ),
      body: isLoading
          ? const CircularProgressIndicator()
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
              : experienceList.isEmpty
                  ? const Center(
                      child: Text(
                        'No work experiences added',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        fetchWorkExperiences(widget.resumeId);
                      },
                      child: ListView.builder(
                        itemCount: experienceList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddEditWorkExperiencePage(
                                      resumeId: widget.resumeId,
                                      experienceId:
                                          experienceList[index].id.toString(),
                                    );
                                  },
                                ),
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
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.work_outline_rounded,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: width * 0.8,
                                            child: Text(
                                              '${experienceList[index].position} - ${experienceList[index].type}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.business,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: width * 0.8,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: width * 0.7,
                                              child: Text(
                                                experienceList[index]
                                                    .companyName!,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            experienceList[index]
                                                        .companyWebsite !=
                                                    null
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      left: 10,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Helper().launchInBrowser(
                                                            experienceList[
                                                                    index]
                                                                .companyWebsite!);
                                                      },
                                                      child: const Icon(
                                                        Icons.open_in_new,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.date_range,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: width * 0.8,
                                        child: Helper().isNullEmptyOrFalse(
                                          experienceList[index].endDate,
                                        )
                                            ? Text(
                                                '${Helper().formatMonthYear(experienceList[index].startDate ?? '')} - Present',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            : Text(
                                                '${Helper().formatMonthYear(experienceList[index].startDate ?? '')} - ${Helper().formatMonthYear(experienceList[index].endDate ?? '')}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Helper().isNullEmptyOrFalse(
                                    experienceList[index].description,
                                  )
                                      ? const SizedBox()
                                      : Row(
                                          children: [
                                            const Icon(
                                              Icons.description,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              width: width * 0.8,
                                              child: Text(
                                                experienceList[index]
                                                    .description!,
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
}
