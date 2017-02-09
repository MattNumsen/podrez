DROP DATABASE IF EXISTS podrez;
CREATE DATABASE podrez;

\c podrez;

CREATE TABLE roles (
	role integer PRIMARY KEY,
	description VARCHAR
);

CREATE TABLE user (
	podID SERIAL PRIMARY KEY,
	role integer,
	FOREIGN KEY (role) REFERENCES roles (role)
);


CREATE TABLE studentAccount (
	podID INTEGER NOT NULL,
	legalName VARCHAR,
	preferredName VARCHAR,
	SID INTEGER,
	age INTEGER,
	gender VARCHAR,
	PRIMARY KEY (podID),
	FOREIGN KEY (podID) REFERENCES user (podID)
);

CREATE TABLE reslifeAccount (
	podID INTEGER NOT NULL,
	resID SERIAL,
	legalName VARCHAR, 
	preferredNAme VARCHAR,
	roomID INTEGER, 
	permission INTEGER,
	StudentID INTEGER
	PRIMARY KEY (podID),
	FOREIGN KEY (podID) REFERENCES user (podID)
);

CREATE TABLE housingAccount (
	podID INTEGER NOT NULL, 
	housingID SERIAL, 
	name VARCHAR, 
	permission INTEGER, 
	studentID INTEGER, 
	PRIMARY KEY (podID),
	FOREIGN KEY (podID) REFERENCES user (podID)
);

CREATE TABLE building (
	buildingID VARCHAR PRIMARY KEY, 
	description VARCHAR
);

CREATE TABLE room (
	roomID VARCHAR PRIMARY KEY,
	buildingID VARCHAR
	FOREIGN KEY (buildingID) REFERENCES building (buildingID)
);

CREATE TABLE application (
	applicationID SERIAL PRIMARY KEY, 
	SID INTEGER,
	semester INTEGER,
	info JSONB,
	FOREIGN KEY (SID) REFERENCES studentAccount (SID)
);

CREATE TABLE agreement (
	applicationID INTEGER NOT NULL,
	roomID VARCHAR NOT NULL, 
	billVal NUMERIC (7,2),
	FOREIGN KEY (applicationID) REFERENCES application (applicationID),
	FOREIGN KEY (roomID) REFERENCES room (roomID),
	PRIMARY KEY (applicationID)
);

CREATE TABLE guest (
	guestID SERIAL PRIMARY KEY, 
	name VARCHAR, 
	phone INTEGER,
	email VARCHAR
);

CREATE TABLE reservation (
	reservationID SERIAL PRIMARY KEY, 
	reserved_date_start DATE,
	reserved_data_finish DATE,
	reservation_duration INTEGER,
	roomID INTEGER, 
	guestID INTEGER,
	FOREIGN KEY (roomID) REFERENCES room (roomID), 
	FOREIGN KEY (guestID) REFERENCES guest (guestID)
);

CREATE TABLE maintRequest (
	maintID SERIAL PRIMARY KEY, 
	userID INTEGER NOT NULL, 
	buildingID INTEGER, 
	roomID INTEGER,
	info JSONB,
	FOREIGN KEY (roomID) REFERENCES room (roomID), 
	FOREIGN KEY (buildingID) REFERENCES building (buildingID),
	FOREIGN KEY (userID) REFERENCES user (userID)
);

CREATE TABLE incident (
	incidentID SERIAL PRIMARY KEY, 
	incDate DATE, 
	info JSONB
);

CREATE TABLE account_incident (
	userID INTEGER NOT NULL, 
	incidentID INTEGER NOT NULL, 
	involvment_type INTEGER, 
	FOREIGN KEY (userID) REFERENCES user (userID), 
	FOREIGN KEY (incidentID) REFERENCES incident (incidentID), 
	PRIMARY KEY (userID, incidentID)
);

CREATE TABLE equipment (
	eqID SERIAL PRIMARY KEY, 
	info JSONB
);

CREATE TABLE rentalAgreement (
	eqRentalID SERIAL PRIMARY KEY,
	userID INTEGER NOT NULL, 
	rentalDate DATE NOT NULL, 
	FOREIGN KEY (userID) REFERENCES user (USERID)
);

CREATE TABLE eqiupment_rentalAgreement (
	eqRentalID INTEGER NOT NULL, 
	eqID INTEGER NOT NULL,
	FOREIGN KEY (eqRentalID) REFERENCES rentalAgreement (eqRentalID),
	FOREIGN KEY (eqID) REFERENCES equipment (eqID),
	PRIMARY KEY (eqRentalID, eqID)
);

CREATE TABLE program (
	programID SERIAL PRIMARY KEY, 
	info JSONB
);

CREATE TABLE account_program (
	resID INTEGER NOT NULL, 
	programID INTEGER NOT NULL, 
	FOREIGN KEY (resID) REFERENCES reslifeAccount (resID),
	FOREIGN KEY (programID) REFERENCES program (programID)
);

CREATE TABLE attending (
	podID INTEGER NOT NULL, 
	programID INTEGER NOT NULL,
	FOREIGN KEY (podID) REFERENCES user (podID),
	FOREIGN KEY (programID) REFERENCES program (programID)
);