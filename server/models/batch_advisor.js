import { DataTypes } from 'sequelize';
import { sequelize } from '../config/dbconfig.js';
import Department from './department.js';
import Batch from './batch.js'
const Batch_Advisor = sequelize.define('batch_advisor', {
  AdvisorID: {
    type: DataTypes.STRING,
    primaryKey: true,
  },
  depart_id: {
    type: DataTypes.STRING, // Adjust the data type accordingly
    allowNull: false,
    references: {
      model: Department,
      key: 'depart_id',
    },
  },
  batch_id: {
    type: DataTypes.STRING, // Adjust the data type accordingly
    allowNull: false,
    references: {
      model: Batch,
      key: 'batch_id',
    },
  },
  advisor_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  advisor_contact: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  advisor_email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  advisor_password: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  is_verify: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  otp: {
    type: DataTypes.STRING,
    defaultValue: '',
  },
});

export default Batch_Advisor;
