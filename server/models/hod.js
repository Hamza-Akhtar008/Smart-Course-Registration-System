import { DataTypes } from 'sequelize';
import { sequelize } from '../config/dbconfig.js';
import Department from './department.js';
const HOD = sequelize.define('hod', {
  HODID: {
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
  Hod_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  hod_contact: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  hod_email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  hod_password: {
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

export default HOD;
