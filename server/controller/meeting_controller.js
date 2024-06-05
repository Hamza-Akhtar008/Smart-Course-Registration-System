
import Batch_Advisor from "../models/batch_advisor.js";
import HOD from "../models/hod.js";
import Meeting from "../models/meeting.js";
import Student from "../models/student_model.js";

export const get_hod_batch_advisor = async (req, res) => {
    const { student_id } = req.body; // Destructure student_id from req.body
    try {
        const std = await Student.findOne({
            where: { student_id: student_id },
            attributes: ['depart_id'], // Fetch only the depart_id
        });

        const depart_id = std ? std.depart_id : null; // Access depart_id property

        if (!depart_id) {
            // Handle the case where depart_id is not found
            return res.status(404).json({ success: false, error: 'Student not found' });
        }

        // Fetch all HOD records from the database
        const allHODs = await HOD.findAll({
            where: { depart_id: depart_id },
            attributes: [ 'Hod_name'],
        });

        const allBatch_Advisor = await Batch_Advisor.findAll({
            where: { depart_id: depart_id },
            attributes: ['advisor_name'],
        });

        res.status(200).json({ success: true, hodList: allHODs, advisors: allBatch_Advisor });
    } catch (error) {
        console.error('Error retrieving HODs:', error);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
};
export const addNewMeeting = async (req, res) => {
    try {
      // Extract meeting data from the request body
      const { student_id, recipient_type, recipient_name } = req.body;
      const std = await Student.findOne({
        where: { student_id: student_id },
        attributes: ['depart_id'], // Fetch only the depart_id
    });

    const depart_id = std ? std.depart_id : null;
      // Create a new meeting in the database
      const newMeeting = await Meeting.create({
        student_id,
        depart_id,
        recipient_type,
        recipient_name,
      });
  
      // Respond with the newly created meeting
      res.status(201).json({ success: true, data: newMeeting });
    } catch (error) {
      console.error('Error adding new meeting:', error);
      res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
  };

  export const getRequestedMeetings = async (req, res) => {
    try {
      const { student_id } = req.body;
      
      // Fetch requested meetings for the given student_id
      const requestedMeetings = await Meeting.findAll({
        where: { student_id },
        attributes: ['meeting_id','recipient_type','recipient_name', 'meeting_date', 'meeting_time'],
      });
  
      res.status(200).json({ success: true, requestedMeetings });
    } catch (error) {
      console.error('Error retrieving requested meetings:', error);
      res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
  };

  export const deletemeeting = async (req, res) => {
    try {
      const { meeting_id } = req.body;
      
      // Fetch requested meetings for the given student_id
      let requestedMeetings = await Meeting.findOne({
        where: { meeting_id:meeting_id }
      });
  if(requestedMeetings)
  {
    requestedMeetings.destroy();
    res.status(200).json({ success: true,message:"Requested Meeting WithDrawn" });
  }
  else
  {
    res.status(201).json({ success: false,message:"Cannot Find Requested Meeting" });
  }
    
    } catch (error) {
      console.error('Error retrieving Requested Meeting:', error);
      res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
  };

  export const getRequestedMeeting = async (req, res) => {
    try {
      const { user_id,user_type } = req.body;
      let user;
      let requestedMeetings
      if(user_type==='HOD')
      {
user =  await HOD.findOne({where:{HODID:user_id}});
requestedMeetings= await Meeting.findAll({
  where: { recipient_name:user.Hod_name,recipient_type:'HoD' },
 
});
      }
      else
      {
        user =  await Batch_Advisor.findOne({where:{AdvisorID:user_id}})
requestedMeetings=await Meeting.findAll({
  where: { recipient_name:user.advisor_name,recipient_type:'Batch Advisor' },

});
      }
      res.status(200).json({ success: true,requestedMeetings: requestedMeetings });
    } catch (error) {
      console.error('Error retrieving requested meetings:', error);
      res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
  };


  export const updateMeeting = async (req, res) => {
    try {
      // Extract meeting data from the request body
      const { student_id, meeting_id, meeting_date,meeting_time } = req.body;
  

      // Create a new meeting in the database
      const newMeeting = await Meeting.findOne({
     where:{
      student_id:student_id,
      meeting_id:meeting_id,
     }
      });
  if(newMeeting)
  {
    
    await newMeeting.update({meeting_date:meeting_date,meeting_time:meeting_time});
  }
      // Respond with the newly created meeting
      res.status(201).json({ success: true, data: newMeeting });
    } catch (error) {
      console.error('Error adding new meeting:', error);
      res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
  };
