import { DataTypes } from 'sequelize';
import { sequelize } from '../config/dbconfig.js'; 

const Course = sequelize.define('course', {
  CourseID: {
    type: DataTypes.STRING,
    allowNull: false,
    primaryKey: true,
  },
  Course_Name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  Course_Type: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  Course_Pre_reg: {
    type: DataTypes.STRING,
    defaultValue: null,
  },
  Course_Description: {
    type: DataTypes.STRING,
  },
}, {
  
 

});

export default Course;
