import { DataTypes } from 'sequelize';
import { sequelize } from '../config/dbconfig.js';
import Department from './department.js';
import Batch from './batch.js';

const StudyPlan = sequelize.define(
  'studyplan',
  {
    studplanid: {
      type: DataTypes.STRING,
      primaryKey: true,
      allowNull: false,
    },
    depart_id: {
      type: DataTypes.STRING,
      allowNull: false,
      references: {
        model: Department,
        key: 'depart_id',
      },
    },
    batch_id: {
      type: DataTypes.STRING,
      allowNull: false,
      references: {
        model: Batch,
        key: 'batch_id',
      },
    },
    study_plan_details: {
      type: DataTypes.JSON,
      allowNull: false,
    },
    total_credit_hours: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: {
          args: [1],
          msg: 'Total credit hours must be greater than 0',
        },
        isNumeric: {
          msg: 'Please enter a valid number for total credit hours',
        },
      },
    },
  },
);

export default StudyPlan;
