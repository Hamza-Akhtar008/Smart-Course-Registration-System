import { DataTypes } from 'sequelize';
import {sequelize} from '../config/dbconfig.js'; 

const Course_Type = sequelize.define('course_type', {
    Course_Type_id: {
    type: DataTypes.STRING,
    primaryKey: true,
  },
  Course_Type_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
});

export default Course_Type;
