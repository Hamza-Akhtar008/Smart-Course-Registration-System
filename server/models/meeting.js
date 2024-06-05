// Import Sequelize library and connection
import { DataTypes } from 'sequelize';
import { sequelize } from '../config/dbconfig.js';
import Student from './student_model.js';
import Department from './department.js';

const Meeting = sequelize.define('meeting', {
  meeting_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
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
  depart_id: {
    type: DataTypes.STRING,
    allowNull: false,
    references: {
      model: Department,
      key: 'depart_id',
    },
  },
  recipient_type: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  recipient_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  meeting_date: {
    type: DataTypes.DATE,
    defaultValue: null,
  },
  meeting_time: {
    type: DataTypes.STRING,
    defaultValue: null,
   
  },
});




export default Meeting;
