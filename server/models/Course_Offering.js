import { DataTypes } from 'sequelize';
import { sequelize } from '../config/dbconfig.js';
import Course from './Course.js'; // Import the Course model
import Department from './department.js'; // Import the Department model

const CourseOffering = sequelize.define('courseoffering', {
  section: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  Semester: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  offering: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: true,
  },
  depart_id: {
    type: DataTypes.STRING, // Change the data type if needed
    allowNull: false,
  },
});

// Define an association with the Course model
CourseOffering.belongsTo(Course, {
  foreignKey: 'CourseID',
  onDelete: 'CASCADE',
});

// Define an association with the Department model
CourseOffering.belongsTo(Department, {
  foreignKey: 'depart_id',
  onDelete: 'CASCADE',
});

export default CourseOffering;
