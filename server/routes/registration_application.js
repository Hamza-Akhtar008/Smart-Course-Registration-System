import express from 'express';
const router = express.Router();

import {
  addNewRegistrationApplication,get_registration_application,delete_registration_application,get_all_registration_application,update_registration_application
} from '../controller/Registration_application_controller.js';
router.get('/get_all_registration_application',get_all_registration_application);
router.post('/add_new_registrationApplication', addNewRegistrationApplication);
router.post('/get_registrationApplication', get_registration_application);
router.delete('/delete_registrationApplication', delete_registration_application);
router.post('/update_registration_application',update_registration_application)


export default router;
