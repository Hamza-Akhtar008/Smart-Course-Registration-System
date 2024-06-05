

import AcademicsStaff from "../models/academic_staff.js";
export const getstaff = async (req, res) => {
    const { academics_id } = req.body;
   
    try {
      // Fetch all students where is_current is true
      const currentStudents = await AcademicsStaff.findAll({
        where: {
      
            academics_id:academics_id
        },
        attributes: ['academics_id', 'staff_name', 'staff_email', 'staff_contact'],
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