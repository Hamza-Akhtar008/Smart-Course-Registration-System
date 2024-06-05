import express from "express";
import { addNewStudyPlan ,getAllStudyPlans,deleteStudyPlanById,editStudyPlanById,getStudyPlansbyid,editStudyPlan} from "../controller/managestudyplan_controller.js";

const Router = express.Router()

Router.post('/add_new_studyplan',addNewStudyPlan)
Router.get('/gettallstudplans',getAllStudyPlans);
Router.delete('/deletestudyplan',deleteStudyPlanById);
Router.post('/gettstudplansbyid',getStudyPlansbyid);
Router.patch('/editStudyPlanbyid',editStudyPlanById)
Router.patch('/editStudyPlan',editStudyPlan)
export default Router;