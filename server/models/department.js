import { DataTypes } from 'sequelize';
import {sequelize} from '../config/dbconfig.js'; 
const Department = sequelize.define('department', {
  depart_id: {
    type: DataTypes.STRING,
    primaryKey: true,
  },
  depart_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
});

export default Department;
