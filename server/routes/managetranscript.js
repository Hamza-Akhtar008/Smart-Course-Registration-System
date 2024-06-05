import express from "express";
import { getStudyPlansandTranscript} from "../controller/managetranscript_controller.js";

const Router = express.Router()

Router.post('/getStudyPlansandTranscript',getStudyPlansandTranscript)
export default Router;