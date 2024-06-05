import express from "express";
import { Logincontroller, otp,resetpasswordrequest ,resetpassword } from "../controller/Controller.js";
import errorMiddleware from "../middlewares/errormiddleware.js";

const Router = express.Router()



// LOGIN || POST 

Router.post('/login',errorMiddleware, Logincontroller);
Router.post('/send_otp',otp);
Router.post('/reset_password_request',resetpasswordrequest)
Router.post('/reset_password',resetpassword)
export default Router;