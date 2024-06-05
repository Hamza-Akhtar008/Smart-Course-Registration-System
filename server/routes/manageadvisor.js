import express from "express";
import errorMiddleware from "../middlewares/errormiddleware.js";
import {add_new_batch_advisor,deletebatchadvisorById,editbatchadvisorById,getAllBatchAdvisors,get_advisor} from '../controller/managebatch_advisor_controller.js'

const Router = express.Router()
Router.post('/add_new_batch_advisor',add_new_batch_advisor);
Router.patch('/editbatchadvisor',editbatchadvisorById);
Router.get('/getallbatchadvisor',getAllBatchAdvisors);
Router.delete('/delete_advisor',deletebatchadvisorById)
Router.post("/get_advisor", get_advisor);

export default Router;