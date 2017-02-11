/*----------------------------------------------------------------------------------------------------------------------

This document contains all stored procedures for the Podrez system, as listed below

insert_student(firstName VARCHAR, lastName VARCHAR, preferredName VARCHAR, birthdate DATE, SID INTEGER, age INTEGER, gender VARCHAR) 
insert_reslifeAccount(legalName VARCHAR, preferredNAme VARCHAR, roomID INTEGER, permission INTEGER, studentID INTEGER)
insert_housingAccount(name VARCHAR, permission INTEGER, studentID INTEGER)
delete_studentAccount(podID)
delete_reslifeAccount(podID)
delete_housingAccount(podID) 

----------------------------------------------------------------------------------------------------------------------*/

\c podrez

/*STUDENT ACCOUNT CREATION FUNCTION*/
CREATE OR REPLACE FUNCTION insert_student(firstName VARCHAR, lastName VARCHAR, preferredName VARCHAR, SID INTEGER, age INTEGER, birthdate DATE, gender VARCHAR) 
RETURNS void AS $BODY$
DECLARE
_podID INTEGER;
BEGIN
	INSERT INTO podUser (role)
	VALUES (1) RETURNING podID INTO _podID;

	INSERT INTO studentAccount (podID, firstName, lastName, preferredName, birthdate, SID, age, gender)
	VALUES (_podID, firstName, lastName, preferredName, birthdate, SID, age, gender);

END;
$BODY$ LANGUAGE plpgsql;


/*RESLIFE ACCOUNT CREATION FUNCTION*/
CREATE OR REPLACE FUNCTION insert_reslifeAccount(resID VARCHAR, firstName VARCHAR, lastName VARCHAR, preferredName VARCHAR, permission INTEGER, studentID INTEGER)
RETURNS void AS $BODY$
DECLARE
_podID INTEGER;
BEGIN
	INSERT INTO podUser (role)
	VALUES (2) RETURNING podID INTO _podID;

	INSERT INTO reslifeAccount (podID, resID, firstName, lastName, preferredName, permission, StudentID)
	VALUES (_podID, resID, firstName, lastName, preferredName, permission, StudentID);
END;
$BODY$ LANGUAGE plpgsql;


/*HOUSING ACCOUNT CREATION FUNCTION*/
CREATE OR REPLACE FUNCTION insert_housingAccount(housingID VARCHAR, firstName VARCHAR, lastName VARCHAR, permission INTEGER, studentID INTEGER)
RETURNS void AS $BODY$
DECLARE
_podID INTEGER;
BEGIN
	INSERT INTO podUser (role)
	VALUES (3) RETURNING podID INTO _podID;


	INSERT INTO housingAccount (podID, housingID, firstName, lastName, permission, studentID)
	VALUES (_podID, housingID, firstName, lastName, permission, studentID);
END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_housingAccount(housingID VARCHAR, firstName VARCHAR, lastName VARCHAR, permission INTEGER)
RETURNS void AS $BODY$
DECLARE
_podID INTEGER;
BEGIN
	INSERT INTO podUser (role)
	VALUES (3) RETURNING podID INTO _podID;


	INSERT INTO housingAccount (podID, housingID, firstName, lastName, permission)
	VALUES (_podID, housingID, firstName, lastName, permission);
END;
$BODY$ LANGUAGE plpgsql;


/*STUDENT ACCOUNT DELETION FUNCTION*/
CREATE OR REPLACE FUNCTION delete_studentAccount(given_podID INTEGER)
RETURNS void AS $BODY$
BEGIN
	DELETE FROM studentAccount where podID=given_podID;
	DELETE FROM podUser where podID=given_podID;
END;
$BODY$ LANGUAGE plpgsql;

/*RESLIFE ACCOUNT DELETION FUNCTION*/
CREATE OR REPLACE FUNCTION delete_reslifeAccount(given_podID INTEGER)
RETURNS void AS $BODY$
BEGIN
	DELETE FROM reslifeAccount where podID=given_podID;
	DELETE FROM podUser where podID=given_podID;
END;
$BODY$ LANGUAGE plpgsql;

/*HOUSING ACCOUNT DELETION FUNCTION*/
CREATE OR REPLACE FUNCTION delete_housingAccount(given_podID INTEGER)
RETURNS void AS $BODY$
BEGIN
	DELETE FROM housingAccount where podID=given_podID;
	DELETE FROM podUser where podID=given_podID;
END;
$BODY$ LANGUAGE plpgsql;