
import Course_type from '../models/course_type.js';

// Controller to get all department IDs
export const getAllCourse_typeIds = async (req, res,next) => {
  try {
    // Fetch all department records from the database
    const allcoursetype = await Course_type.findAll({
      attributes: ['Course_Type_id'], 
    });

    // Extract the department IDs from the result
    const allBatchIds = allcoursetype.map((course_type) => course_type.Course_Type_id);
console.log(allBatchIds);
    res.status(200).json({ success: true, data: allBatchIds });
  } catch (error) {
    console.error('Error retrieving Course Type:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const addNewCourseType = async (req, res, next) => {
  try {
    const { Course_Type_id, Course_Type_name } = req.body;

    // Check if a batch with the given ID already exists
    const existingBatch = await Course_type.findOne({
      where: { Course_Type_id },
    });

    if (existingBatch) {
      return res.status(400).json({ success: false, error: 'Course Type with this ID already exists' });
    }

    // Create a new batch record in the database
    const newBatch = await Course_type.create({
        Course_Type_id,
        Course_Type_name,
    });

    res.status(201).json({ success: true, data: newBatch });
  } catch (error) {
    console.error('Error adding new Course Type:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

// Controller to get all batch records
export const getAllCourseType = async (req, res, next) => {
  try {
    // Fetch all batch records from the database
    const allBatches = await Course_type.findAll({
      attributes: ['Course_Type_id', 'Course_Type_name'], // List of fields to retrieve
    });

    res.status(200).json({ success: true, data: allBatches });
  } catch (error) {
    console.error('Error retrieving Course Type:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

// Controller to delete a batch by ID
export const deleteCourseTypeById = async (req, res, next) => {
  try {
    const { Course_Type_id } = req.body;

    // Find the batch by ID
    const batchToDelete = await Course_type.findByPk(Course_Type_id);

    // If the batch with the specified ID doesn't exist, return an error
    if (!batchToDelete) {
      return res.status(404).json({ success: false, error: 'Course Type not found' });
    }

    // Delete the batch
    await batchToDelete.destroy();

    res.status(200).json({ success: true, message: 'Course Type deleted successfully' });
  } catch (error) {
    console.error('Error deleting Course Type:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

// Controller to edit a batch by ID
export const editCourseTypeById = async (req, res, next) => {
  try {
    const { Course_Type_id, Course_Type_name } = req.body;

    // Find the batch by ID
    const batchToUpdate = await Course_type.findByPk(Course_Type_id);

    // If the batch with the specified ID doesn't exist, return an error
    if (!batchToUpdate) {
      return res.status(404).json({ success: false, error: 'Course Type not found' });
    }

    // Update the batch fields
    batchToUpdate.Course_Type_name = Course_Type_name;

    // Save the changes
    await batchToUpdate.save();

    res.status(200).json({ success: true, message: 'Course Type updated successfully' });
  } catch (error) {
    console.error('Error updating Course Type:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};