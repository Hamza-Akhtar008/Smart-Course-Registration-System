// Import the Department model
import Department from '../models/department.js';

export const getalldepartids = async (req, res) => {
  try {
    // Fetch all department records from the database
    const allDepartments = await Department.findAll({
      attributes: ['depart_id'], 
    });

    // Extract the department IDs from the result
    const allDepartmentIds = allDepartments.map((department) => department.depart_id);

    res.status(200).json({ success: true, data: allDepartmentIds });
  } catch (error) {
    console.error('Error retrieving department IDs:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const addNewDepartment = async (req, res, next) => {
  try {
    const { depart_id, depart_name } = req.body;

    // Check if a department with the given ID already exists
    const existingDepartment = await Department.findOne({
      where: { depart_id },
    });

    if (existingDepartment) {
      return res.status(400).json({ success: false, error: 'Department with this ID already exists' });
    }

    // Create a new department record in the database
    const newDepartment = await Department.create({
      depart_id,
      depart_name,
    });

    res.status(201).json({ success: true, data: newDepartment });
  } catch (error) {
    console.error('Error adding new department:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const getAllDepartments = async (req, res, next) => {
  try {
    // Fetch all department records from the database
    const allDepartments = await Department.findAll({
      attributes: ['depart_id', 'depart_name'], // List of fields to retrieve
    });

    res.status(200).json({ success: true, data: allDepartments });
  } catch (error) {
    console.error('Error retrieving departments:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const deleteDepartmentById = async (req, res, next) => {
  try {
    const { depart_id } = req.body;

    // Find the department by ID
    const departmentToDelete = await Department.findByPk(depart_id);

    // If the department with the specified ID doesn't exist, return an error
    if (!departmentToDelete) {
      return res.status(404).json({ success: false, error: 'Department not found' });
    }

    // Delete the department
    await departmentToDelete.destroy();

    res.status(200).json({ success: true, message: 'Department deleted successfully' });
  } catch (error) {
    console.error('Error deleting department:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const editDepartmentById = async (req, res, next) => {
  try {
    const { depart_id, depart_name } = req.body;

    // Find the department by ID
    const departmentToUpdate = await Department.findByPk(depart_id);

    // If the department with the specified ID doesn't exist, return an error
    if (!departmentToUpdate) {
      return res.status(404).json({ success: false, error: 'Department not found' });
    }

    // Update the department fields
    departmentToUpdate.depart_name = depart_name;

    // Save the changes
    await departmentToUpdate.save();

    res.status(200).json({ success: true, message: 'Department updated successfully' });
  } catch (error) {
    console.error('Error updating department:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};
