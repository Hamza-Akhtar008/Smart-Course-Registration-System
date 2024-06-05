import Department from '../models/department.js';
import Student from '../models/student_model.js';
import Batch from '../models/batch.js';
import AcademicsStaff from '../models/academic_staff.js';
import HOD from '../models/hod.js';
import Batch_Advisor from '../models/batch_advisor.js';
import Studyplan from '../models/studyplan.js'
import Course from '../models/Course.js'
import Transcript from '../models/transcript.js';
import Course_Type from '../models/course_type.js'
import CourseOffering from '../models/Course_Offering.js';
import RegistrationApplication from '../models/registration_application.js';
import Meeting from '../models/meeting.js';
const syncModels = async () => {
    const models = [AcademicsStaff, Batch, Department,Student,HOD,Batch_Advisor,Studyplan,Course,Transcript,Course_Type,CourseOffering,RegistrationApplication,Meeting]; // Add other models
  
    for (const model of models) {
      try {
        await model.sync();
        console.log(`${model.name} synchronized with the database`);
      } catch (error) {
        console.error(`Error synchronizing ${model.name} with the database:`, error);
      }
    }
  
    console.log('All models synchronized with the database');
  };

  export {   syncModels };