import express from 'express';
import CourseOffering from '../models/Course_Offering.js';
import Course from '../models/Course.js';
import Student from '../models/student_model.js';
import HOD from '../models/hod.js';
import Batch_Advisor from '../models/batch_advisor.js';


const router = express.Router();

// Get all course offerings
router.get('/getallcourseofferings', async (req, res) => {
  try {
    const courseOfferings = await CourseOffering.findAll({where:{offering:true}});
     let course_Name=[];
    for (let index = 0; index < courseOfferings.length; index++) {
     let cour = await   Course.findOne({where : {
      CourseID:courseOfferings[index].CourseID
      }})
   course_Name.push(cour.Course_Name);
    }
    console.log(course_Name);
   return res.status(200).json({
    success: true,
    message: 'Successfully retrieved all current students',
    data: courseOfferings,
    course_name:course_Name
  });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});
router.post('/getcourseofferings', async (req, res) => {
  let { student_id,SearchName ,user_type} = req.body;

 
  try {
    let  user;
if(user_type==='Student'){

  user = await Student.findOne({
    where: { student_id: student_id },
    attributes: {
      include: ['depart_id'],
    },
  });
}
else if( user_type ==='HOD')
{
  user = await HOD.findOne({
    where: { HODID: student_id },
    attributes: {
      include: ['depart_id'],
    },
  });
}
else if(
  user_type ==='Batch Advisor'
)
{
  user = await Batch_Advisor.findOne({
    where: { AdvisorID: student_id },
    attributes: {
      include: ['depart_id'],
    },
  });
}
console.log(user);
    let courseOfferings = await CourseOffering.findAll({where:{offering:true,depart_id:user.depart_id}});
    let fileroffering=[]
     let course_Name=[];
     let course_pre=[];
     let course_type=[];
    for (let index = 0; index < courseOfferings.length; index++) {
     let cour = await   Course.findOne({where : {
      CourseID:courseOfferings[index].CourseID
      }})
      if(SearchName)
      {
        if(cour.Course_Name.toLowerCase().includes(SearchName.toLowerCase()))
      {
        course_Name.push(cour.Course_Name);
        if(!cour.Course_Pre_reg)
        {
         course_pre.push("NONE");
        }
        else{
         course_pre.push(cour.Course_Pre_reg);
        }
        
        course_type.push(cour.Course_Type)
        fileroffering.push(courseOfferings[index]);
      }
      }
      else
      {
        course_Name.push(cour.Course_Name);
        if(!cour.Course_Pre_reg)
        {
         course_pre.push("NONE");
        }
        else{
         course_pre.push(cour.Course_Pre_reg);
        }
        
        course_type.push(cour.Course_Type)
      }
  
  
    }
    console.log(course_Name);
 
    for (let index = 0; index < course_pre.length; index++) {
      if(!course_pre[index])
      {
        course_pre[index]= ' ';
      }
      
    }
   if(SearchName)
   {
    courseOfferings=fileroffering;
   }
   return res.status(200).json({
    success: true,
    message: 'Successfully retrieved all current students',
    data: courseOfferings,
    course_name:course_Name,
    course_pre:course_pre,
    course_type:course_type
  });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});
// Create a new course offering
router.post('/add_new_courseofferings', async (req, res) => {
 
  let { section, Semester, CourseID, depart_id } = req.body;
  let Course_Name=CourseID;
 const course= await Course.findOne(
    {
      where:{
        Course_Name
      }
    })
console.log(Semester);
CourseID =course.CourseID;
const existingcourse = await CourseOffering.findOne({where:{
  section: section,
     Semester: Semester,
     depart_id: depart_id,
     CourseID: CourseID,
}})


if(existingcourse)
{
  return res.status(400).json({
    success: false,
    message: 'Course Already Offered',
  });
}
  try {
    const newCourseOffering = await CourseOffering.create({
     section: section,
     Semester: Semester,
     depart_id: depart_id,
     CourseID: CourseID,
      
    });

    return res.status(200).json({
      success: true,
      message: 'Student added successfully',
      newCourseOffering: newCourseOffering,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});




// Delete a course offering by ID
router.delete('/delete_courseofferings', async (req, res) => {
  const { id } = req.body;

  try {
    await CourseOffering.destroy({ where: { id } });
    res.json({ message: 'Course has been Un-offered Successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
