import express from "express";
import { getAllbatchIds ,addNewBatch,getAllBatches,deleteBatchById,editBatchById} from "../controller/managebatch_controller.js";


const Router = express.Router()
Router.get('/getallbatchid',getAllbatchIds);
Router.post('/addnewbatch',addNewBatch);
Router.get('/getallbatch',getAllBatches);
Router.delete('/delete_batch',deleteBatchById)
Router.patch('/edit_batch',editBatchById)

export default Router;