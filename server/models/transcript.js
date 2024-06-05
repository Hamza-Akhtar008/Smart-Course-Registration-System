import { DataTypes } from 'sequelize';
import {sequelize} from '../config/dbconfig.js';
import Student from './student_model.js';

// Define the Transcript model
const Transcript = sequelize.define('transcript', {
  transcriptId: {
    type: DataTypes.STRING,
    primaryKey: true,
    allowNull: false,
  },
  student_id: {
    type: DataTypes.STRING,
    allowNull: false,
    references: {
      model: Student,
      key: 'student_id',
    },
  },
  transcriptInfo: {
    type: DataTypes.STRING, 
    allowNull: true, 
  },
  semesterinfo: {
    type: DataTypes.STRING, 
    allowNull: true, 
  },
});


// Export the model
export default Transcript;