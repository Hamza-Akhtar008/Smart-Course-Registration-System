
import express from 'express';  
import { addNewCourse,editCourse,deleteCourse,getAllCourses ,getAllCourse_Ids} from '../controller/managecourse_controller.js';
const Router = express.Router();

Router.post('/addNewCourse', addNewCourse);

// Edit a course
Router.patch('/editCourse', editCourse);

// Delete a course
Router.delete('/deleteCourse', deleteCourse);

// Get all courses
Router.get('/getAllCourses', getAllCourses);
Router.get('/getAllCoursesids', getAllCourse_Ids);

export default Router;