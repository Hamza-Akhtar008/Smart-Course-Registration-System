import express from "express";
import { add_new_student, deactivateStudentById, editStudentById, getAllCurrentStudents ,getStudents} from "../controller/managestudent_controller.js";


const Router = express.Router()
Router.post('/add_new_student',add_new_student);
Router.get('/get_all_student',getAllCurrentStudents)
Router.delete('/delete_studnt',deactivateStudentById)
Router.patch('/edit_student',editStudentById)
Router.post('/get_student',getStudents)

export default Router;