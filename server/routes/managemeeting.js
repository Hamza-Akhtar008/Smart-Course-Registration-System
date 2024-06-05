import express from 'express';
const router = express.Router();


import { get_hod_batch_advisor,addNewMeeting,getRequestedMeetings,deletemeeting,getRequestedMeeting ,updateMeeting} from '../controller/meeting_controller.js';

// Add new registration application
router.post('/get_hod_batchadvisor', get_hod_batch_advisor);
router.post('/add_new_meeting', addNewMeeting);
router.post('/get_requested_meetings', getRequestedMeetings);
router.post('/get_requested_meeting', getRequestedMeeting);
router.delete('/delete_request',deletemeeting);
router.post('/allocate_meeting',updateMeeting);
export default router;
