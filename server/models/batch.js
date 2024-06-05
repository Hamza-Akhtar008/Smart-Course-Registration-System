import { DataTypes } from 'sequelize';
import {sequelize} from '../config/dbconfig.js'; 

const Batch = sequelize.define('batch', {
  batch_id: {
    type: DataTypes.STRING,
    primaryKey: true,
  },
  batch_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
});

export default Batch;
