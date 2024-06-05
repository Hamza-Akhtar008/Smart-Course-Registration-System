import AcademicsStaff from '../models/academic_staff.js';
import JWT from 'jsonwebtoken';
import Student from '../models/student_model.js';
import nodemailer from 'nodemailer';
import HOD from '../models/hod.js';
import Batch_Advisor from '../models/batch_advisor.js';



export const Logincontroller = async (req, res, next) => {
  const staff_email = req.body.staff_email;
  const staff_password = req.body.staff_password;

  if (!staff_email || !staff_password) {
    return res.status(400).json({ success: false, message: 'Please Provide All Fields' });
  }

  let user;
  let userType;
  let userid;

  // Check Academic Staff
  user = await AcademicsStaff.findOne({
    where: { staff_email },
    attributes: {
      exclude: ['createdAt', 'updatedAt'],
    },
  });

  if (user && user.staff_password === staff_password) {
    userType = 'Admin';
    userid = user.academics_id;
  } else {
    // Check Student
    user = await Student.findOne({
      where: { student_email: staff_email },
      attributes: {
        exclude: ['createdAt', 'updatedAt'],
      },
    });

    if (user && user.student_password === staff_password) {
      userType = 'Student';
      userid = user.student_id;

    
      
    } else {
      user = await HOD.findOne({
        where: { hod_email: staff_email },
        attributes: {
          exclude: ['createdAt', 'updatedAt'],
        },
      });
      if (user && user.hod_password === staff_password) {
        userType = 'HOD';
        userid = user.HODID;
  
      
       
      }
      else
      {
        user = await Batch_Advisor.findOne({
          where: { advisor_email: staff_email },
          attributes: {
            exclude: ['createdAt', 'updatedAt'],
          },
        });

        if (user && user.advisor_password === staff_password) {
          userType = 'Batch Advisor';
          userid = user.AdvisorID;
    
        
         
        }
        else
        {
          return res.status(403).send('Unauthorized');  

        }

      }

    }
  }
  if (!user.is_verify) {
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000);

    // Send OTP as an email to student_email
    sendOtpEmail(staff_email, otp);
user.otp=otp;
user.save()
    return res.status(200).json({
      otp: true,
      message: 'Account not verified. OTP sent to email for verification.',
    });
  }
  // Remove password from the response
  user.staff_password = undefined;

  // Assign type based on the user type (Admin or Student)
  user.type = userType;

  // Generate JWT token
  const token = JWT.sign({ user }, process.env.secret_Key);

  res.status(200).json({
    otp:false,
    success: true,
    message: 'Login Successfully',
    userType: userType,
    userid: userid,
    user: user,
    token,
  });
};

// Function to send OTP as an email
const sendOtpEmail = (email, otp) => {
  const transporter = nodemailer.createTransport({
    service: 'Gmail', // Use your email service provider (e.g., Gmail, Yahoo)
    auth: {
      user: 'ik930530@gmail.com', // Your email address
      pass: 'cffk prmk gxwu xbob', // Your email password or an app-specific password
    },
  });

  const mailOptions = {
    from: 'ik930530@gmail.com', // Sender email address
    to: email, // Recipient email address
    subject: 'Verification OTP', // Email subject
    html: `
      <html>
        <body>
          <h1>Verification OTP</h1>
          <p>Your verification OTP is: <strong>${otp}</strong></p>
        </body>
      </html>
    `, // HTML formatted email body
  };
  

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error('Error sending OTP:', error);
    } else {
      console.log('OTP sent:', info.response);
    }
  });
};

export const otp = async (req, res) => {
  try {
    const { student_email, otp } = req.body;
    let user = await Student.findOne({ where: { student_email: student_email } });
    if (!user) {
      user = await Batch_Advisor.findOne({ where: { advisor_email: student_email } });
    }
    if (!user) {
      user = await AcademicsStaff.findOne({ where: { staff_email: student_email } });
    }
    if (!user) {
      user = await HOD.findOne({ where: { hod_email: student_email } });
    }
    // Find the student by email
   

    if (!user) {
      return res.status(404).json({ message: 'Account not found' });
    }

    // Check if OTP matches
    if (user.otp === otp) {
      user.is_verify=true;
      user.otp="";
      await user.save();
      // You can update additional verification status or perform other actions here
      return res.status(200).json({ message: 'OTP verified successfully' });
    } else {
      return res.status(401).json({ message: 'Invalid OTP' });
    }
  } catch (error) {
    console.error('Error verifying OTP:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};


export const resetpasswordrequest = async (req, res) => {
  try {
    const { staff_email } = req.body;

    let user = await Student.findOne({ where: { student_email: staff_email } });
    if(user)
    {
      const otp = Math.floor(100000 + Math.random() * 900000);
      sendOtpEmail(user.student_email, otp);
      user.otp=otp;
      user.save();
    }
    if (!user) {
      user = await Batch_Advisor.findOne({ where: { advisor_email: staff_email } });
      if(user)
      {
        const otp = Math.floor(100000 + Math.random() * 900000);
      sendOtpEmail(user.advisor_email, otp);
      user.otp=otp;
      user.save();
      }
    }
    if (!user) {
      user = await AcademicsStaff.findOne({ where: { staff_email: staff_email } });
      if(user)
      {
        const otp = Math.floor(100000 + Math.random() * 900000);
      sendOtpEmail(user.staff_email, otp);
      user.otp=otp;
      user.save();
      }
    }
    if (!user) {
      user = await HOD.findOne({ where: { hod_email: staff_email } });
      if(user)
      {
        const otp = Math.floor(100000 + Math.random() * 900000);
      sendOtpEmail(user.hod_email, otp);
      user.otp=otp;
      user.save();
      }
    }
   

    if (!user) {
      return res.status(404).json({ message: 'Student not found' });
    }
    

    // Send OTP as an email to student_email
  
   
    return res.status(200).json({
      otp: true,
      message: 'OTP sent to email for verification.',
    });
  } catch (error) {
    console.error('Error verifying OTP:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const resetpassword = async (req, res) => {
  try {
    const { student_email, otp } = req.body;

    

    
    let user = await Student.findOne({ where: { student_email: student_email } });
    let student_password= generateRandomPassword(10);
    if(user)
    {
      if( user.otp === otp)
      {
   
        user.student_password=student_password;
        await user.save();
        sendpasswordresetemail(student_email,student_password,user.student_name);
      }
    }
    if (!user) {
      user = await Batch_Advisor.findOne({ where: { advisor_email: student_email } });
      if(user)
      {
        if( user.otp === otp)
        {
     
          user.advisor_password=student_password;
          await user.save();
          sendpasswordresetemail(student_email,student_password,user.advisor_name);
        }
      }
    }
    if (!user) {
      user = await AcademicsStaff.findOne({ where: { staff_email: student_email } });
      if(user)
      {
        if( user.otp === otp)
        {
     
          user.staff_password=student_password;
          await user.save();
          sendpasswordresetemail(student_email,student_password,user.staff_name);
        }
      }
    }
    if (!user) {
      user = await HOD.findOne({ where: { hod_email: student_email } });
      if(user)
      {
        if( user.otp === otp)
        {
     
          user.hod_password=student_password;
          await user.save();
          sendpasswordresetemail(student_email,student_password,user.Hod_name);
        }
        
      }
    }
   
    // Check if OTP matches
    if (user.otp === otp) {
           // You can update additional verification status or perform other actions here
      return res.status(200).json({ message: 'OTP verified and Password Sent to Email Address' });
    } else {
      return res.status(401).json({ message: 'Invalid OTP' });
    }
  } catch (error) {
    console.error('Error verifying OTP:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
function sendpasswordresetemail(email,password,name)
{
    const transporter = nodemailer.createTransport({
        service: 'Gmail', // Use your email service provider (e.g., Gmail, Yahoo)
        auth: {
          user: 'ik930530@gmail.com', // Your email address
          pass: 'cffk prmk gxwu xbob', // Your email password or an app-specific password
        },
      });
     
      const mailOptions = {
        from: 'ik930530@gmail.com', // Sender email address
        to: email, // Recipient email address
        subject: ' Account Reset Successfully', // Email subject
        html: `
          <p>Dear ${name},</p>
          <p>Your  account has been Reset successfully.</p>
          <p>Here are your login credentials:</p>
          <ul>
            <li><strong>Email:</strong> ${email}</li>
            <li><strong>Password:</strong> ${password}</li>
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
}
function generateRandomPassword(length) {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let password = '';
  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * characters.length);
    password += characters.charAt(randomIndex);
  }
  return password;
}
