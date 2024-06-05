import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_course_registration_system/screens/Batch_Advisor/Recommend_Application.dart';
import 'package:smart_course_registration_system/screens/Batch_Advisor/allocated_meeting.dart';
import 'package:smart_course_registration_system/screens/Batch_Advisor/calculate.dart';
import 'package:smart_course_registration_system/screens/Batch_Advisor/schedule_meeting.dart';
import 'package:smart_course_registration_system/screens/Batch_Advisor/view_application.dart';
import 'package:smart_course_registration_system/screens/Batch_Advisor/view_available_courses.dart';
import 'package:smart_course_registration_system/screens/HOD/allocated_meeting.dart';
import 'package:smart_course_registration_system/screens/HOD/approve_reject_application.dart';

import 'package:smart_course_registration_system/screens/HOD/schedule_meeting.dart';
import 'package:smart_course_registration_system/screens/HOD/view_application.dart';
import 'package:smart_course_registration_system/screens/HOD/view_available_courses.dart';
import 'package:smart_course_registration_system/screens/Student/RequestMeeting.dart';
import 'package:smart_course_registration_system/screens/Student/Upload_Transcript.dart';
import 'package:smart_course_registration_system/screens/Student/View_Progress.dart';
import 'package:smart_course_registration_system/screens/Student/calculate.dart';
import 'package:smart_course_registration_system/screens/Student/check_status.dart';
import 'package:smart_course_registration_system/screens/Student/course_registration.dart';
import 'package:smart_course_registration_system/screens/admin/Add_New/add_new_batch.dart';
import 'package:smart_course_registration_system/screens/admin/Add_New/add_new_course_type.dart';
import 'package:smart_course_registration_system/screens/admin/Add_New/add_new_depart.dart';
import 'package:smart_course_registration_system/screens/admin/Add_New/manage_course_type.dart';
import 'package:smart_course_registration_system/screens/admin/Add_New/offer_course.dart';
import 'package:smart_course_registration_system/screens/admin/Process_Application.dart';
import 'package:smart_course_registration_system/screens/admin/manage_department.dart';
import 'package:smart_course_registration_system/screens/admin/managebatch.dart';
import 'package:smart_course_registration_system/screens/admin/process.dart';
import 'package:smart_course_registration_system/screens/forget_password.dart';

import 'package:smart_course_registration_system/screens/forgetpassword_request.dart';
import 'package:smart_course_registration_system/screens/main/main_screenHod.dart';
import 'package:smart_course_registration_system/screens/main/main_screenStudent.dart';
import 'package:smart_course_registration_system/screens/main/main_screen_Batch_Advisor.dart';
import 'package:smart_course_registration_system/screens/verfiication.dart';
import 'screens/Login.dart';
import 'screens/admin/Add_New/add_new_batch_advisor.dart';
import 'screens/admin/Add_New/add_new_course.dart';
import 'screens/admin/Add_New/add_new_hod.dart';
import 'screens/admin/Add_New/add_new_student.dart';
import 'screens/admin/Add_New/add_new_study_plan.dart';
import 'screens/admin/manage_batch_advisor.dart';
import 'screens/admin/manage_hod.dart';
import 'screens/admin/manage_offered_courses.dart';
import 'screens/admin/manage_student_records.dart';
import 'screens/admin/manage_studyplan.dart';
import 'screens/admin/study_plan_details.dart';
import 'constants.dart';
import 'controllers/MenuAppController.dart';
import 'screens/main/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   String admintype='';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Course Registration System',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      initialRoute: '/', // Set the initial route
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => FutureBuilder<String?>(
            future: getToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final String? token = snapshot.data;


                if (token==null) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                          create: (context) => MenuAppController()),
                    ],
                    child: unauth(settings),
                  );
                }
                if (admintype == 'Admin') {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                          create: (context) => MenuAppController()),
                    ],
                    child: AdminbuildRoute(settings),
                  );
                }
              }
if(admintype == 'HOD')
  {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => MenuAppController()),
      ],
      child: HODbuildRoute(settings),
    );
  }
              if(admintype == 'Batch Advisor')
              {
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (context) => MenuAppController()),
                  ],
                  child: AdvisorbuildRoute(settings),
                );
              }



              if (admintype == 'Student') {
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (context) => MenuAppController()),
                  ],
                  child: StudentbuildRoute(settings),
                );
              }
              else {
                return CircularProgressIndicator();
              }

            }     ),
        );
      },
    );
  }

  Widget AdminbuildRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        return MainScreen();
      case '/manage_hod':
        return ManageHOD();
      case '/manage_batch_advisor':
        return ManageBatchAdvisor();
      case '/manage_student':
        return ManageStudent();
      case '/manage_study_plan':
        return ManageStudyPlan();
      case '/manage_offered_courses':
        return ManageOfferedCourse();
      case '/add_new_hod':
        return addnewhod();
      case '/add_new_batch_advisor':
        return addnewbatchadvisor();
      case '/add_new_student':
        return AddNewStudent();
      case '/add_new_study_plan':
        return AddNewStudyPlan();
      case '/add_new_course':
        return AddNewCourse();
      case '/view_study_plan_details':
        return StudyPlanDetails();
      case '/manage_department':
        return ManageDepartment();
      case '/add_new_department':
        return AddNewDepartment();
      case  '/managebatch':
        return ManageBatch();
      case '/add_new_batch':
        return AddNewBatch();
      case '/manage_degree':
        return ManageCourseType();
      case '/add_new_course_type':
        return AddNewCourseType();
      case '/offer_course':
        return AddNewCourseOffering();
      case '/Process_Application':
        return Process_Application();
      case '/process':
        return Process();
      default:

        return MainScreen(); // Default case or handle unknown routes
    }
  }
  Widget StudentbuildRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboardstudent':
        return MainScreenStudentStudent();
      case '/upload_transcript':
        return UploadTranscript();
      case '/View_progress':
        return View_Progress();
      case '/course_registration':
        return CourseRegistration();
      case '/check_status':
       return RegistrationStatusScreen();
      case '/request_meeting':
        return RequestMeeting();
      case '/calculate':
        return Calculate();
      default:
        return MainScreenStudentStudent(); // Default case or handle unknown routes
    }
  }

   Widget HODbuildRoute(RouteSettings settings) {
     switch (settings.name) {
       case '/dashboardHOD':
         return MainScreenHOD();
       case '/view_application':
         return ViewApplication();
       case '/approve_reject_application':
         return ApproveRejectApplication();
       case '/view_courses':
         return HODBatchAdvisorViewCourses();
       case '/schedule_meeting':
         return Schedule_Meeting();
       case '/allocte_meeting':
         return AllocateMeeting();
       default:
         return MainScreenHOD(); // Default case or handle unknown routes
     }
   }

   Widget AdvisorbuildRoute(RouteSettings settings) {
     switch (settings.name) {
       case '/dashboardHOD':
         return MainScreenBatchAdvisor();
       case '/view_application':
         return ViewApplicationAdvisor();
       case '/approve_reject_application':
         return RecommendApplication();
       case '/view_courses':
         return AdvisorViewCourses();
       case '/schedule_meeting':
         return Schedule_Meeting_Advisor();
       case '/allocte_meeting':
         return AllocateMeetingBatchAdvisor();
       case '/calculate_student_cgpa':
         return CalculateStudentCGPA();
       default:
         return MainScreenBatchAdvisor(); // Default case or handle unknown routes
     }
   }
   Widget unauth(RouteSettings settings) {
     switch (settings.name) {

       case '/otp_screen':
         return OTPScreen();
       case '/forgot_password_request':
         return ForgerPassword();
       case '/forget_password':
         return OTPScreenForgetPassword();
       default:
         return LoginScreen(); // Default case or handle unknown routes
     }
   }
  Future<String?> getToken() async {
    // Implement your asynchronous token retrieval logic
    final SharedPreferences prefs = await SharedPreferences.getInstance();
     String? token = prefs.getString('token');

      admintype = prefs.getString('usertype')!;


    return token;
  }
}
