import { array } from 'yup';
import StudyPlan from '../models/studyplan.js';
import Transcript from '../models/transcript.js';
import Student from '../models/student_model.js';
import Course from '../models/Course.js';


export const getStudyPlansandTranscript = async (req, res) => {
  
    const student_id = req.body.student_id;

    try {
console.log(student_id);
        const student = await Student.findByPk(student_id);
      // Find all StudyPlans, excluding the createdAt and updatedAt fields
      const studyPlans = await StudyPlan.findOne({
        where:{
            depart_id:student.depart_id,
            batch_id:student.batch_id,
        },
         
        attributes: {
          exclude: ['createdAt', 'updatedAt'],
        },
      });
const transcript = await Transcript.findOne({where :{student_id:student_id}});
     if(!transcript)
     {
        res.status(401).json('No Transcript Found');
     }
    
     const transcriptInfo = await JSON.parse(transcript.transcriptInfo);

     const allCourses = await Course.findAll();

     for (const course of transcriptInfo) {
       const matchingCourse = allCourses.find(c => c.dataValues.CourseID === course.courseId);
       
       if (matchingCourse) {
         course.Course_Name = matchingCourse.Course_Name;
       }
     }
   
      res.status(200).json({
        success: true,
        message: 'Study plans retrieved successfully',
        studyplan_details: studyPlans.study_plan_details,
        transcriptinfo: JSON.stringify(transcriptInfo),
        transcriptdetail:transcript.semesterinfo,
      });
    } catch (error) {
      // Handle any errors that occur during the process
      console.error('Error retrieving Study Plans:', error);
      res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: error.message,
      });
    }
  };
  
 
 