// Import your Batch_Advisor model
import Batch_Advisor from '../models/batch_advisor.js';
import nodemailer from 'nodemailer';

export const add_new_batch_advisor = async (req, res,next) => {
  try {
    // Extract relevant information from the request body
    const {
      AdvisorID,
      depart_id,
      batch_id,
      advisor_name,
      advisor_contact,
      advisor_email,
      advisor_password,
    } = req.body;

    // Check if a Batch Advisor with the same email already exists
    const existingAdvisor = await Batch_Advisor.findOne({
      where: {
        advisor_email: advisor_email,
      },
    });

    if (existingAdvisor) {
      // If the advisor already exists, send a conflict response
      return res.status(409).json({
        success: false,
        message: 'Batch Advisor with the same email already exists',
      });
    }

    // Create a new Batch_Advisor record in the database
    const newBatchAdvisor = await Batch_Advisor.create({
      AdvisorID,
      depart_id,
      batch_id,
      advisor_name,
      advisor_contact,
      advisor_email,
      advisor_password,
    });
    const transporter = nodemailer.createTransport({
      service: 'Gmail', // Use your email service provider (e.g., Gmail, Yahoo)
      auth: {
        user: 'ik930530@gmail.com', // Your email address
        pass: 'cffk prmk gxwu xbob', // Your email password or an app-specific password
      },
    });
    const mailOptions = {
      from: 'ik930530@gmail.com', // Sender email address
      to: advisor_email, // Recipient email address
      subject: 'Batch Advisor Account Created Successfully', // Email subject
      html: `
        <p>Dear ${advisor_name},</p>
        <p>Your Batch Advisor account has been created successfully.</p>
        <p>Here are your login credentials:</p>
        <ul>
          <li><strong>Email:</strong> ${advisor_email}</li>
          <li><strong>Password:</strong> ${advisor_password}</li>
        </ul>
        <p>Please keep this information secure.</p>
        <p>Sincerely,</p>
        <p>The Administration Team</p>
      `, // HTML formatted email body
    };
    
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error('Error sending account details email:', error);
      } else {
        console.log('Account details email sent:', info.response);
      }
    });
    // Send a success response with the newly created Batch_Advisor record
    res.status(201).json({
      success: true,
      message: 'Batch Advisor created successfully',
      data: newBatchAdvisor,
    });
  } catch (error) {
    // Handle any errors that occur during the process
    console.error('Error creating Batch Advisor:', error);
    res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};

export const getAllBatchAdvisors = async (req, res) => {
  try {
   
    const batchAdvisors = await Batch_Advisor.findAll({
      attributes: {
        exclude: ['advisor_password', 'createdAt', 'updatedAt'],
      },
    });

    // Send a success response with the fetched Batch Advisors
    res.status(200).json({
      success: true,
      message: 'Batch Advisors retrieved successfully',
      data: batchAdvisors,
    });
  } catch (error) {
    // Handle any errors that occur during the process
    console.error('Error retrieving Batch Advisors:', error);
    res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};
export const deletebatchadvisorById = async (req, res) => {
  try {
    const { AdvisorID } = req.body;

    // Find the HOD by ID
    const batch_advisorToDelete = await Batch_Advisor.findByPk(AdvisorID);

    // If the HOD with the specified ID doesn't exist, return an error
    if (!batch_advisorToDelete) {
      return res.status(404).json({ success: false, error: 'Batch Advisor not found' });
    }

    // Delete the HOD
    await batch_advisorToDelete.destroy();

    res.status(200).json({ success: true, message: 'Batch Advisor successfully' });
  } catch (error) {
    console.error('Error deleting Batch Advisor:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};
export const editbatchadvisorById = async (req, res) => {
  try {
    const { AdvisorID, depart_id, batch_id,advisor_name, advisor_contact, advisor_email } = req.body;

   
    const batchadvisortoupdate = await Batch_Advisor.findByPk(AdvisorID);


    if (!batchadvisortoupdate) {
      return res.status(404).json({ success: false, error: 'Batch Advisor found' });
    }

    // Update the HOD fields
    batchadvisortoupdate.depart_id = depart_id;
    batchadvisortoupdate.batch_id = batch_id;
    batchadvisortoupdate.advisor_name = advisor_name;
    batchadvisortoupdate.advisor_contact = advisor_contact;
    batchadvisortoupdate.advisor_email = advisor_email;

    // Save the changes
    await batchadvisortoupdate.save();

    res.status(200).json({ success: true, message: 'Batch Advisor updated successfully' });
  } catch (error) {
    console.error('Error Batch Advisor:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};


export const get_advisor = async (req, res) => {
  const { HODID } = req.body;
  console.log(HODID);
  try {
    // Fetch all students where is_current is true
    const currentStudents = await Batch_Advisor.findAll({
      where: {
        
        AdvisorID:HODID
      },
      attributes: ['AdvisorID', 'depart_id',"batch_id", 'advisor_name', 'advisor_contact', 'advisor_email'],
    });
    return res.status(200).json({
      success: true,
      
      students: currentStudents,
    });
  } catch (error) {
    console.error('Error getting current students:', error);
    return res.status(500).json({
      success: false,
      message: 'An error occurred while fetching current students',
    });
  }
};