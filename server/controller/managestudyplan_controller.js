import { array } from 'yup';
import StudyPlan from '../models/studyplan.js';

export const addNewStudyPlan = async (req, res) => {
  try {
    // Extract relevant information from the request body
    const {
      studplanid,
      depart_id,
      batch_id,
      study_plan_details,
      total_credit_hours,
    } = req.body;

    // Check if the study plan with the same studplanid already exists
    const existingStudyPlan = await StudyPlan.findOne({
      where: {
        studplanid: studplanid,
        depart_id:depart_id,
        batch_id:batch_id
      },
    });

    if (existingStudyPlan) {
      // If the study plan already exists, send a conflict response
      return res.status(409).json({
        success: false,
        message: 'Study plan with the same studplanid already exists',
      });
    }

    // Create a new StudyPlan record in the database
    const newStudyPlan = await StudyPlan.create({
      studplanid,
      depart_id,
      batch_id,
      study_plan_details,
      total_credit_hours
    });

    // Send a success response with the newly created StudyPlan record
    res.status(201).json({
      success: true,
      message: 'Study plan created successfully',
      data: newStudyPlan,
    });
  } catch (error) {
    // Handle any errors that occur during the process
    console.error('Error creating study plan:', error);
    res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};
export const getAllStudyPlans = async (req, res) => {
  
    try {
      // Find all StudyPlans, excluding the createdAt and updatedAt fields
      const studyPlans = await StudyPlan.findAll({
        attributes: {
          exclude: ['createdAt', 'updatedAt'],
        },
      });

      // Send a success response with the fetched StudyPlans
      res.status(200).json({
        success: true,
        message: 'Study plans retrieved successfully',
        data: studyPlans,
      });
    } catch (error) {
      // Handle any errors that occur during the process
      console.error('Error retrieving Study Plans:', error);
      res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: error.message,
      });
    }
  };
  
  export const getStudyPlansbyid = async (req, res) => {
  
    const studplanid = req.body.studplanid;
   console.log(studplanid);
    try {
      // Find all StudyPlans, excluding the createdAt and updatedAt fields
      const studyPlans = await StudyPlan.findByPk(studplanid);

      // Send a success response with the fetched StudyPlans
      res.status(200).json({
        success: true,
        message: 'Study plans retrieved successfully',
        study_plan_details: studyPlans.study_plan_details,
      });
    } catch (error) {
      // Handle any errors that occur during the process
      console.error('Error retrieving Study Plans:', error);
      res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: error.message,
      });
    }
  };
  export const deleteStudyPlanById = async (req, res) => {
    try {
      // Extract study plan ID from the request parameters
      const { studplanid } = req.body;
      // Check if the study plan exists
      const existingStudyPlan = await StudyPlan.findOne({
        where: {
          studplanid,
        },
      });
      if (!existingStudyPlan) {
        // If the study plan doesn't exist, send a not found response
        return res.status(404).json({
          success: false,
          message: 'Study plan not found',
        });
      }
      // Delete the study plan from the database
      await existingStudyPlan.destroy();
      // Send a success response
      res.status(200).json({
        success: true,
        message: 'Study plan deleted successfully',
      });
    } catch (error) {
      // Handle any errors that occur during the process
      console.error('Error deleting study plan:', error);
      res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: error.message,
      });
    }
  };
  
  export const editStudyPlanById = async (req, res) => {
    try {
      // Extract relevant information from the request body
      const { studplanid } = req.body;
      const { depart_id, batch_id, studyplan_details } = req.body;
  
      // Check if the study plan with the given ID exists
      const existingStudyPlan = await StudyPlan.findOne({
        where: {
          studplanid,
        },
      });
  
      if (!existingStudyPlan) {
        // If the study plan doesn't exist, send a not found response
        return res.status(404).json({
          success: false,
          message: 'Study plan not found',
        });
      }
  
      // Update the study plan details
      existingStudyPlan.depart_id = depart_id;
      existingStudyPlan.batch_id = batch_id;
      existingStudyPlan.studyplan_details = studyplan_details;
  
      // Save the updated study plan to the database
      await existingStudyPlan.save();
  
      // Send a success response with the updated study plan
      res.status(200).json({
        success: true,
        message: 'Study plan updated successfully',
        data: existingStudyPlan,
      });
    } catch (error) {
      // Handle any errors that occur during the process
      console.error('Error updating study plan:', error);
      res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: error.message,
      });
    }
  };
  

  export const editStudyPlan = async (req, res) => {
    try {
      // Extract relevant information from the request body
      const { studplanid } = req.body;
      
  
      // Check if the study plan with the given ID exists
      const existingStudyPlan = await StudyPlan.findOne({
        where: {
          studplanid,
        },
      });
  
      if (!existingStudyPlan) {
        // If the study plan doesn't exist, send a not found response
        return res.status(404).json({
          success: false,
          message: 'Study plan not found',
        });
      }
      const studyplan_details = existingStudyPlan.studyplan_details;
      const studyplanArray = JSON.parse(studyplan_details);

      studyplanArray.forEach((item) => {
        // Check if the object has valid key and value properties
        if (item && typeof item === 'object') {
          // Iterate over key-value pairs
          Object.entries(item).forEach(([key, value]) => {
            // Check if the key exists in req.body
            if (req.body.hasOwnProperty(key)) {
              // Access the value from req.body using the key
              const updatedValue = req.body[key];
              console.log(`Key: ${key}, Old Value: ${value}, New Value: ${updatedValue}`);
      
              // Update the value in the studyplanArray
              item[key] = updatedValue;
            } else {
              console.error(`Key '${key}' not found in req.body`);
            }
          });
        } else {
          console.error('Invalid structure in studyplan_details:', item);
        }
      });
      
      // Convert the updated studyplanArray back to a JSON string
     
      existingStudyPlan.studyplan_details=studyplanArray;
    

// Update the studyplan_details in existingStudyPlan


// Save the updated study plan to the database
await existingStudyPlan.save();
  
      // Send a success response with the updated study plan
      res.status(200).json({
        success: true,
        message: 'Study plan updated successfully',
        data: existingStudyPlan,
      });
    } catch (error) {
      // Handle any errors that occur during the process
      console.error('Error updating study plan:', error);
      res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: error.message,
      });
    }
  };
  