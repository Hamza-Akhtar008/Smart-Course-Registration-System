import express from "express";
import { getAllDepartments ,deleteDepartmentById,editDepartmentById,addNewDepartment,getalldepartids} from "../controller/managedepartment_controller.js";


const Router = express.Router()
getalldepartids
Router.get('/getalldepartid',getalldepartids)
Router.post('/addnewdepart',addNewDepartment);
Router.get('/getalldepart',getAllDepartments);
Router.delete('/delete_depart',deleteDepartmentById)
Router.patch('/edit_depart',editDepartmentById)
export default Router;