import Course from "../models/Course.js";

export const addNewCourse = async (req, res) => {
  try {
    const { CourseID, Course_Name, Course_Type,Course_Pre_reg, Course_Description } = req.body;

    const existingCourse = await Course.findOne({
        where: {
            CourseID: CourseID,
            Course_Type:Course_Type,
        },
      });
  
      if (existingCourse) {
        // If the advisor already exists, send a conflict response
        return res.status(409).json({
          success: false,
          message: 'Course Already Exist',
        });
      }
    // Add new course
    const newCourse = await Course.create({
      CourseID,
      Course_Name,
      Course_Type,
      Course_Pre_reg,
      Course_Description,
    });

    res.status(200).json(newCourse);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

export const editCourse = async (req, res) => {
    try {
      const { CourseID,Course_Type } = req.body;
  
      // Find the course
      const course = await Course.findOne({
        where: {
            CourseID: CourseID,
            Course_Type:Course_Type,
        },
      });
  
      if (!course) {
        return res.status(404).json({ error: 'Course not found' });
      }
  
      // Update the course
      await course.update(req.body);
  
      res.status(200).json(course);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  };

  export const deleteCourse = async (req, res) => {
    try {
      const { CourseID,Course_Type } = req.body;
  
      // Find the course
      const course = await Course.findOne({
        where: {
            CourseID: CourseID,
            Course_Type:Course_Type,
        },
      });
  
      if (!course) {
        return res.status(404).json({ error: 'Course not found' });
      }
  
      // Delete the course
      await course.destroy();
  
      res.status(200).json({ message: 'Course deleted successfully' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  };

  export const getAllCourses = async (req, res) => {
    try {
      // Get all courses
      const courses = await Course.findAll();
  
      res.status(200).json(courses);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  };
  export const getAllCourse_Ids = async (req, res,next) => {
    try {
      // Fetch all department records from the database
      const allcoursetype = await Course.findAll({
        attributes: ['Course_Name'], 
      });
  
      // Extract the department IDs from the result
      const allBatchIds = allcoursetype.map((course_type) => course_type.Course_Name);
 
      res.status(200).json({ success: true, data: allBatchIds });
    } catch (error) {
      console.error('Error retrieving Course Type:', error);
      res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
  };