import express from "express";
import { getstaff} from "../controller/manage_Academic_controller.js";


const Router = express.Router()

Router.post('/get_staff',getstaff)

export default Router;