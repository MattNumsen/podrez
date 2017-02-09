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
