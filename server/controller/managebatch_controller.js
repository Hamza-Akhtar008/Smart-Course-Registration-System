
import Batch from '../models/batch.js';

// Controller to get all department IDs
export const getAllbatchIds = async (req, res) => {
  try {
    // Fetch all department records from the database
    const allBatch = await Batch.findAll({
      attributes: ['batch_id'], 
    });

    // Extract the department IDs from the result
    const allBatchIds = allBatch.map((batch) => batch.batch_id);

    res.status(200).json({ success: true, data: allBatchIds });
  } catch (error) {
    console.error('Error retrieving department IDs:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const addNewBatch = async (req, res, next) => {
  try {
    const { batch_id, batch_name } = req.body;

    // Check if a batch with the given ID already exists
    const existingBatch = await Batch.findOne({
      where: { batch_id },
    });

    if (existingBatch) {
      return res.status(400).json({ success: false, error: 'Batch with this ID already exists' });
    }

    // Create a new batch record in the database
    const newBatch = await Batch.create({
      batch_id,
      batch_name,
    });

    res.status(201).json({ success: true, data: newBatch });
  } catch (error) {
    console.error('Error adding new batch:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

// Controller to get all batch records
export const getAllBatches = async (req, res, next) => {
  try {
    // Fetch all batch records from the database
    const allBatches = await Batch.findAll({
      attributes: ['batch_id', 'batch_name'], // List of fields to retrieve
    });

    res.status(200).json({ success: true, data: allBatches });
  } catch (error) {
    console.error('Error retrieving batches:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

// Controller to delete a batch by ID
export const deleteBatchById = async (req, res, next) => {
  try {
    const { batch_id } = req.body;

    // Find the batch by ID
    const batchToDelete = await Batch.findByPk(batch_id);

    // If the batch with the specified ID doesn't exist, return an error
    if (!batchToDelete) {
      return res.status(404).json({ success: false, error: 'Batch not found' });
    }

    // Delete the batch
    await batchToDelete.destroy();

    res.status(200).json({ success: true, message: 'Batch deleted successfully' });
  } catch (error) {
    console.error('Error deleting batch:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

// Controller to edit a batch by ID
export const editBatchById = async (req, res, next) => {
  try {
    const { batch_id, batch_name } = req.body;

    // Find the batch by ID
    const batchToUpdate = await Batch.findByPk(batch_id);

    // If the batch with the specified ID doesn't exist, return an error
    if (!batchToUpdate) {
      return res.status(404).json({ success: false, error: 'Batch not found' });
    }

    // Update the batch fields
    batchToUpdate.batch_name = batch_name;

    // Save the changes
    await batchToUpdate.save();

    res.status(200).json({ success: true, message: 'Batch updated successfully' });
  } catch (error) {
    console.error('Error updating batch:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};