// Import Sequelize
import { DataTypes } from 'sequelize';
import { sequelize } from '../config/dbconfig.js';
import   Student from'./student_model.js';

const RegistrationApplication = sequelize.define('registrationapplication', {
  application_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
   autoIncrement:true,
  },
  student_id: {
    type: DataTypes.STRING, // Adjust the data type accordingly
    allowNull: false,
    references: {
      model: Student,
      key: 'student_id',
    },
  },
  courses: {
    type: DataTypes.JSON,
    allowNull: false,
  },
  isRecommended: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  batchAdvisorComment: {
    type: DataTypes.STRING,
    defaultValue: "",
  },
  isApproved: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  }
  ,isRejected: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  hodComments: {
    type: DataTypes.STRING,
    defaultValue: "",
  },
  isProcessed: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
});


export default RegistrationApplication;
