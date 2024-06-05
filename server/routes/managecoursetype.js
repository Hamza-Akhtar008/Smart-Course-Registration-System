import express from "express";
import { getAllCourse_typeIds ,addNewCourseType,getAllCourseType,deleteCourseTypeById,editCourseTypeById} from "../controller/managecoursetype.js";


const Router = express.Router()
Router.get('/getallcoursetypeid',getAllCourse_typeIds);
Router.post('/addnewcoursetype',addNewCourseType);
Router.get('/getallcoursetype',getAllCourseType);
Router.delete('/delete_coursetype',deleteCourseTypeById)
Router.patch('/edit_coursetype',editCourseTypeById)

export default Router;