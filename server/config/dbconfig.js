import { Sequelize } from 'sequelize';

const sequelize = new Sequelize({
  dialect: 'mysql',
  username: 'root',
  host: 'localhost',
  database:'scrs',
});

const dbconfig = async () => {
  try {
    await sequelize.authenticate();
    console.log('Connected to the database');
  } catch (error) {
    console.error('Unable to connect to the database:', error);
  }
};


  export { sequelize, dbconfig };
