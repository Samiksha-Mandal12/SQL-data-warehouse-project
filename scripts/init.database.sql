/* 
======================================================
Create Database and Schemas
======================================================

Script Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already 
	exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three
	schemas within the database: 'Bronze', 'Silver', 'Gold'.

	WARNING!
		Running this script will drop the entire 'DataWarehouse' databse if it exists.
		All data in the database will be permanently deleted. Proceed with caution and ensure
		you have proper backups before running this script.

		*/



-- Drop and recreate the 'Datawarehouse' database

	IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = 'DataWarehouse')
		BEGIN
			ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
			END;
			GO



-- Create Database 'DataWarehouse'

USE MASTER;

CREATE DATABASE  DataWarehouse;

USE DataWarehouse;


--create schemas

CREATE SCHEMA  Bronze;
GO


CREATE SCHEMA  Silver;
GO


CREATE SCHEMA  Gold;
GO
