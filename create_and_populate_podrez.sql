DROP DATABASE IF EXISTS podrez;
CREATE DATABASE podrez;

\c podrez;

CREATE TABLE roles (
	role integer PRIMARY KEY,
	description VARCHAR
);

CREATE TABLE podUser (
	podID SERIAL PRIMARY KEY,
	password VARCHAR NOT NULL,
	role integer,
	FOREIGN KEY (role) REFERENCES roles (role)
);


CREATE TABLE studentAccount (
	podID INTEGER NOT NULL,
	firstName VARCHAR,
	lastName VARCHAR,
	preferredName VARCHAR,
	SID INTEGER UNIQUE NOT NULL, /*login info*/
	age INTEGER,
	birthdate DATE,
	gender VARCHAR,
	PRIMARY KEY (podID),
	FOREIGN KEY (podID) REFERENCES podUser (podID)
);

CREATE TABLE reslifeAccount (
	podID INTEGER NOT NULL,
	resID VARCHAR UNIQUE NOT NULL, /*login info*/
	firstName VARCHAR, 
	lastName VARCHAR,
	preferredName VARCHAR,
	permission INTEGER,
	studentID INTEGER,
	PRIMARY KEY (podID),
	FOREIGN KEY (podID) REFERENCES podUser (podID)
);

CREATE TABLE housingAccount (
	podID INTEGER NOT NULL, 
	housingID VARCHAR UNIQUE NOT NULL, /*login info*/
	firstName VARCHAR,
	lastName VARCHAR, 
	permission INTEGER, 
	studentID INTEGER, 
	PRIMARY KEY (podID),
	FOREIGN KEY (podID) REFERENCES podUser (podID)
);

CREATE TABLE building (
	buildingID VARCHAR PRIMARY KEY, 
	description VARCHAR
);

CREATE TABLE room (
	roomID VARCHAR,
	buildingID VARCHAR,
	FOREIGN KEY (buildingID) REFERENCES building (buildingID),
	PRIMARY KEY (roomID, buildingID)
);

CREATE TABLE application (
	applicationID SERIAL PRIMARY KEY, 
	SID INTEGER,
	semester INTEGER,
	submitted DATE,
	info JSONB,
	FOREIGN KEY (SID) REFERENCES studentAccount (SID)
);

CREATE TABLE agreement (
	applicationID INTEGER NOT NULL,
	roomID VARCHAR NOT NULL,
	buildingID VARCHAR NOT NULL, 
	billVal NUMERIC (7,2),
	FOREIGN KEY (applicationID) REFERENCES application (applicationID),
	FOREIGN KEY (roomID, buildingID) REFERENCES room (roomID, buildingID),
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
	roomID VARCHAR NOT NULL,
	buildingID VARCHAR NOT NULL, 
	guestID INTEGER,
	FOREIGN KEY (roomID, buildingID) REFERENCES room (roomID, buildingID), 
	FOREIGN KEY (guestID) REFERENCES guest (guestID)
);

CREATE TABLE maintRequest (
	maintID SERIAL PRIMARY KEY, 
	podID INTEGER NOT NULL, 
	buildingID VARCHAR, 
	roomID VARCHAR NOT NULL,
	submitted DATE NOT NULL,
	info JSONB,
	FOREIGN KEY (roomID, buildingID) REFERENCES room (roomID, buildingID), 	
	FOREIGN KEY (podID) REFERENCES podUser (podID)
);

CREATE TABLE incident (
	incidentID SERIAL PRIMARY KEY, 
	resID_owner VARCHAR NOT NULL,
	resID_creater VARCHAR NOT NULL, 
	podID INTEGER NOT NULL, 
	submitted DATE NOT NULL,
	info JSONB,
	FOREIGN KEY(podID) REFERENCES podUser (podID),
	FOREIGN KEY(resID_owner) REFERENCES reslifeAccount (resID),
	FOREIGN KEY(resID_creater) REFERENCES reslifeAccount (resID)
);

CREATE TABLE account_incident (
	podID INTEGER NOT NULL, 
	incidentID INTEGER NOT NULL, 
	involvment_type INTEGER, 
	FOREIGN KEY (podID) REFERENCES podUser (podID), 
	FOREIGN KEY (incidentID) REFERENCES incident (incidentID), 
	PRIMARY KEY (podID, incidentID)
);

CREATE TABLE equipment (
	eqID SERIAL PRIMARY KEY, 
	info JSONB
);

CREATE TABLE rentalAgreement (
	eqRentalID SERIAL PRIMARY KEY,
	podID INTEGER NOT NULL, 
	rentalDate DATE NOT NULL, 
	submitted DATE NOT NULL,
	FOREIGN KEY (podID) REFERENCES podUser (podID)
);

CREATE TABLE equipment_rentalAgreement (
	eqRentalID INTEGER NOT NULL, 
	eqID INTEGER NOT NULL,
	FOREIGN KEY (eqRentalID) REFERENCES rentalAgreement (eqRentalID),
	FOREIGN KEY (eqID) REFERENCES equipment (eqID),
	PRIMARY KEY (eqRentalID, eqID)
);

CREATE TABLE program (
	programID SERIAL PRIMARY KEY,
	resID_owner VARCHAR NOT NULL,
	resID_creater VARCHAR NOT NULL, 
	podID INTEGER NOT NULL, 
	submitted DATE NOT NULL,
	info JSONB,
	FOREIGN KEY(podID) REFERENCES podUser (podID),
	FOREIGN KEY(resID_owner) REFERENCES reslifeAccount (resID),
	FOREIGN KEY(resID_creater) REFERENCES reslifeAccount (resID)
);

CREATE TABLE account_program (
	resID VARCHAR NOT NULL, 
	programID INTEGER NOT NULL, 
	FOREIGN KEY (resID) REFERENCES reslifeAccount (resID),
	FOREIGN KEY (programID) REFERENCES program (programID),
	PRIMARY KEY (resID, programID)
);

CREATE TABLE attending (
	podID INTEGER NOT NULL, 
	programID INTEGER NOT NULL,
	FOREIGN KEY (podID) REFERENCES podUser (podID),
	FOREIGN KEY (programID) REFERENCES program (programID),
	PRIMARY KEY (podID, programID)
);


/*STUDENT ACCOUNT CREATION FUNCTION*/
CREATE OR REPLACE FUNCTION insert_student(firstName VARCHAR, lastName VARCHAR, preferredName VARCHAR, SID INTEGER, age INTEGER, birthdate DATE, gender VARCHAR) 
RETURNS void AS $BODY$
DECLARE
_podID INTEGER;
BEGIN
	INSERT INTO podUser (role, password)
	VALUES (1, '$2a$10$Fuur7DqgFCZJGmT1TuPE1.yVVL59gsc6HIksQCDk9OCesYyxQpnkG') RETURNING podID INTO _podID;

	INSERT INTO studentAccount (podID, firstName, lastName, preferredName, birthdate, SID, age, gender)
	VALUES (_podID, firstName, lastName, preferredName, birthdate, SID, age, gender);

END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_student(firstName VARCHAR, lastName VARCHAR, preferredName VARCHAR, SID INTEGER, password VARCHAR, age INTEGER, birthdate DATE, gender VARCHAR) 
RETURNS void AS $BODY$
DECLARE
_podID INTEGER;
BEGIN
	INSERT INTO podUser (role, password)
	VALUES (1, password) RETURNING podID INTO _podID;

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
	INSERT INTO podUser (role, password)
	VALUES (2, '$2a$10$Fuur7DqgFCZJGmT1TuPE1.yVVL59gsc6HIksQCDk9OCesYyxQpnkG') RETURNING podID INTO _podID;

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
	INSERT INTO podUser (role, password)
	VALUES (3, '$2a$10$Fuur7DqgFCZJGmT1TuPE1.yVVL59gsc6HIksQCDk9OCesYyxQpnkG') RETURNING podID INTO _podID;


	INSERT INTO housingAccount (podID, housingID, firstName, lastName, permission, studentID)
	VALUES (_podID, housingID, firstName, lastName, permission, studentID);
END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_housingAccount(housingID VARCHAR, firstName VARCHAR, lastName VARCHAR, permission INTEGER)
RETURNS void AS $BODY$
DECLARE
_podID INTEGER;
BEGIN
	INSERT INTO podUser (role, password)
	VALUES (3, '$2a$10$Fuur7DqgFCZJGmT1TuPE1.yVVL59gsc6HIksQCDk9OCesYyxQpnkG') RETURNING podID INTO _podID;


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



INSERT INTO roles (role, description)
VALUES (1, 'student'),
(2, 'reslife'), 
(3, 'housing');


INSERT INTO building (buildingID, description)
VALUES ('BL1','Bud Light Tower 1'),
('BL2','Bud Light Tower 2'),
('WCTV','Wildcat Tent Village'),
('SAHH','Stella Artois High Horse');

INSERT INTO room (roomID, buildingID)
VALUES 
('100','BL1'),
('101','BL1'),
('102','BL1'),
('103','BL1'),
('104','BL1'),
('105','BL1'),
('106','BL1'),
('107','BL1'),
('108','BL1'),
('109','BL1'),
('110','BL1'),
('111','BL1'),
('112','BL1'),
('113','BL1'),
('114','BL1'),
('115','BL1'),
('116','BL1'),
('117','BL1'),
('118','BL1'),
('119','BL1'),
('120','BL1'),
('121','BL1'),
('122','BL1'),
('123','BL1'),
('124','BL1'),
('125','BL1'),
('200','BL1'),
('201','BL1'),
('202','BL1'),
('203','BL1'),
('204','BL1'),
('205','BL1'),
('206','BL1'),
('207','BL1'),
('208','BL1'),
('209','BL1'),
('210','BL1'),
('211','BL1'),
('212','BL1'),
('213','BL1'),
('214','BL1'),
('215','BL1'),
('216','BL1'),
('217','BL1'),
('218','BL1'),
('219','BL1'),
('220','BL1'),
('221','BL1'),
('222','BL1'),
('223','BL1'),
('224','BL1'),
('225','BL1'),
('300','BL1'),
('301','BL1'),
('302','BL1'),
('303','BL1'),
('304','BL1'),
('305','BL1'),
('306','BL1'),
('307','BL1'),
('308','BL1'),
('309','BL1'),
('310','BL1'),
('311','BL1'),
('312','BL1'),
('313','BL1'),
('314','BL1'),
('315','BL1'),
('316','BL1'),
('317','BL1'),
('318','BL1'),
('319','BL1'),
('320','BL1'),
('321','BL1'),
('322','BL1'),
('323','BL1'),
('324','BL1'),
('325','BL1'),
('400','BL1'),
('401','BL1'),
('402','BL1'),
('403','BL1'),
('404','BL1'),
('405','BL1'),
('406','BL1'),
('407','BL1'),
('408','BL1'),
('409','BL1'),
('410','BL1'),
('411','BL1'),
('412','BL1'),
('413','BL1'),
('414','BL1'),
('415','BL1'),
('416','BL1'),
('417','BL1'),
('418','BL1'),
('419','BL1'),
('420','BL1'),
('421','BL1'),
('422','BL1'),
('423','BL1'),
('424','BL1'),
('425','BL1'),
('500','BL1'),
('501','BL1'),
('502','BL1'),
('503','BL1'),
('504','BL1'),
('505','BL1'),
('506','BL1'),
('507','BL1'),
('508','BL1'),
('509','BL1'),
('510','BL1'),
('511','BL1'),
('512','BL1'),
('513','BL1'),
('514','BL1'),
('515','BL1'),
('516','BL1'),
('517','BL1'),
('518','BL1'),
('519','BL1'),
('520','BL1'),
('521','BL1'),
('522','BL1'),
('523','BL1'),
('524','BL1'),
('525','BL1'),
('600','BL1'),
('601','BL1'),
('602','BL1'),
('603','BL1'),
('604','BL1'),
('605','BL1'),
('606','BL1'),
('607','BL1'),
('608','BL1'),
('609','BL1'),
('610','BL1'),
('611','BL1'),
('612','BL1'),
('613','BL1'),
('614','BL1'),
('615','BL1'),
('616','BL1'),
('617','BL1'),
('618','BL1'),
('619','BL1'),
('620','BL1'),
('621','BL1'),
('622','BL1'),
('623','BL1'),
('624','BL1'),
('625','BL1'),
('700','BL1'),
('701','BL1'),
('702','BL1'),
('703','BL1'),
('704','BL1'),
('705','BL1'),
('706','BL1'),
('707','BL1'),
('708','BL1'),
('709','BL1'),
('710','BL1'),
('711','BL1'),
('712','BL1'),
('713','BL1'),
('714','BL1'),
('715','BL1'),
('716','BL1'),
('717','BL1'),
('718','BL1'),
('719','BL1'),
('720','BL1'),
('721','BL1'),
('722','BL1'),
('723','BL1'),
('724','BL1'),
('725','BL1'),
('100','BL2'),
('101','BL2'),
('102','BL2'),
('103','BL2'),
('104','BL2'),
('105','BL2'),
('106','BL2'),
('107','BL2'),
('108','BL2'),
('109','BL2'),
('110','BL2'),
('111','BL2'),
('112','BL2'),
('113','BL2'),
('114','BL2'),
('115','BL2'),
('116','BL2'),
('117','BL2'),
('118','BL2'),
('119','BL2'),
('120','BL2'),
('121','BL2'),
('122','BL2'),
('123','BL2'),
('124','BL2'),
('125','BL2'),
('200','BL2'),
('201','BL2'),
('202','BL2'),
('203','BL2'),
('204','BL2'),
('205','BL2'),
('206','BL2'),
('207','BL2'),
('208','BL2'),
('209','BL2'),
('210','BL2'),
('211','BL2'),
('212','BL2'),
('213','BL2'),
('214','BL2'),
('215','BL2'),
('216','BL2'),
('217','BL2'),
('218','BL2'),
('219','BL2'),
('220','BL2'),
('221','BL2'),
('222','BL2'),
('223','BL2'),
('224','BL2'),
('225','BL2'),
('300','BL2'),
('301','BL2'),
('302','BL2'),
('303','BL2'),
('304','BL2'),
('305','BL2'),
('306','BL2'),
('307','BL2'),
('308','BL2'),
('309','BL2'),
('310','BL2'),
('311','BL2'),
('312','BL2'),
('313','BL2'),
('314','BL2'),
('315','BL2'),
('316','BL2'),
('317','BL2'),
('318','BL2'),
('319','BL2'),
('320','BL2'),
('321','BL2'),
('322','BL2'),
('323','BL2'),
('324','BL2'),
('325','BL2'),
('400','BL2'),
('401','BL2'),
('402','BL2'),
('403','BL2'),
('404','BL2'),
('405','BL2'),
('406','BL2'),
('407','BL2'),
('408','BL2'),
('409','BL2'),
('410','BL2'),
('411','BL2'),
('412','BL2'),
('413','BL2'),
('414','BL2'),
('415','BL2'),
('416','BL2'),
('417','BL2'),
('418','BL2'),
('419','BL2'),
('420','BL2'),
('421','BL2'),
('422','BL2'),
('423','BL2'),
('424','BL2'),
('425','BL2'),
('500','BL2'),
('501','BL2'),
('502','BL2'),
('503','BL2'),
('504','BL2'),
('505','BL2'),
('506','BL2'),
('507','BL2'),
('508','BL2'),
('509','BL2'),
('510','BL2'),
('511','BL2'),
('512','BL2'),
('513','BL2'),
('514','BL2'),
('515','BL2'),
('516','BL2'),
('517','BL2'),
('518','BL2'),
('519','BL2'),
('520','BL2'),
('521','BL2'),
('522','BL2'),
('523','BL2'),
('524','BL2'),
('525','BL2'),
('600','BL2'),
('601','BL2'),
('602','BL2'),
('603','BL2'),
('604','BL2'),
('605','BL2'),
('606','BL2'),
('607','BL2'),
('608','BL2'),
('609','BL2'),
('610','BL2'),
('611','BL2'),
('612','BL2'),
('613','BL2'),
('614','BL2'),
('615','BL2'),
('616','BL2'),
('617','BL2'),
('618','BL2'),
('619','BL2'),
('620','BL2'),
('621','BL2'),
('622','BL2'),
('623','BL2'),
('624','BL2'),
('625','BL2'),
('700','BL2'),
('701','BL2'),
('702','BL2'),
('703','BL2'),
('704','BL2'),
('705','BL2'),
('706','BL2'),
('707','BL2'),
('708','BL2'),
('709','BL2'),
('710','BL2'),
('711','BL2'),
('712','BL2'),
('713','BL2'),
('714','BL2'),
('715','BL2'),
('716','BL2'),
('717','BL2'),
('718','BL2'),
('719','BL2'),
('720','BL2'),
('721','BL2'),
('722','BL2'),
('723','BL2'),
('724','BL2'),
('725','BL2'),
('HAHA1','WCTV'),
('HAHA2','WCTV'),
('HAHA3','WCTV'),
('HAHA4','WCTV'),
('HAHA5','WCTV'),
('HAHA6','WCTV'),
('HAHA7','WCTV'),
('HAHA8','WCTV'),
('HAHA9','WCTV'),
('HAHA10','WCTV'),
('LOLOL1','WCTV'),
('LOLOL2','WCTV'),
('LOLOL3','WCTV'),
('LOLOL4','WCTV'),
('LOLOL5','WCTV'),
('LOLOL6','WCTV'),
('LOLOL7','WCTV'),
('LOLOL8','WCTV'),
('LOLOL9','WCTV'),
('LOLOL10','WCTV'),
('CRAP','SAHH');
SELECT insert_student('Aaron','Abegg','Aaron',301977853,18,to_date('8-28-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Aaron','Abeita','Aaron',301945853,20,to_date('6-13-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Abbey','Abel','Abbey',301439716,19,to_date('1-22-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Abbie','Abela','Abbie',303403728,20,to_date('12-12-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Abby','Abelar','Abby',302205256,19,to_date('10-1-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Abdul','Abelardo','Abdul',302966377,19,to_date('10-19-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Abe','Abele','Abe',303585091,23,to_date('5-21-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Abel','Abeles','Abel',301458488,22,to_date('1-6-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Abigail','Abell','Abigail',303186051,17,to_date('7-1-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Abraham','Abella','Abraham',302123046,23,to_date('9-16-1993', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Abram','Abellera','Abram',302367201,23,to_date('7-2-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Ada','Abelman','Ada',301094983,23,to_date('8-28-1993', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adah','Abeln','Adah',301623977,21,to_date('11-6-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adalberto','Abels','Adalberto',301391200,17,to_date('3-3-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adaline','Abelson','Adaline',301138607,19,to_date('6-30-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adam','Abramowitz','Adam',302353808,19,to_date('11-7-1997', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adam','Abramowski','Adam',302969953,21,to_date('8-8-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adan','Abrams','Adan',303669396,24,to_date('7-31-1992', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Addie','Abramson','Addie',303490273,23,to_date('10-5-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adela','Abrantes','Adela',301871194,20,to_date('9-26-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adelaida','Abreau','Adelaida',303978996,24,to_date('5-12-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adelaide','Abrecht','Adelaide',303622501,19,to_date('5-7-1997', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adele','Abrego','Adele',302821969,22,to_date('3-28-1994', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adelia','Abrell','Adelia',303160271,22,to_date('11-29-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adelina','Abreo','Adelina',301639706,20,to_date('11-20-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adeline','Abreu','Adeline',301280621,18,to_date('6-23-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adell','Abrev','Adell',302621838,19,to_date('9-10-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adella','Abrew','Adella',303832796,19,to_date('12-31-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adelle','Abrey','Adelle',302308229,18,to_date('7-21-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adena','Abrial','Adena',301955201,21,to_date('3-29-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adina','Ballagas','Adina',302111965,18,to_date('12-3-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adolfo','Ballagh','Adolfo',302627318,23,to_date('12-5-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adolph','Ballam','Adolph',301323043,20,to_date('2-6-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adria','Ballan','Adria',303012301,17,to_date('4-19-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adrian','Ballance','Adrian',303889921,20,to_date('1-2-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adrian','Ballantine','Adrian',303724905,18,to_date('7-15-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adriana','Ballantyne','Adriana',301377771,18,to_date('9-13-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adriane','Ballar','Adriane',302040482,19,to_date('2-7-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adrianna','Ballard','Adrianna',303776133,18,to_date('4-19-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adrianne','Ballas','Adrianne',301109610,20,to_date('4-6-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adrien','Ballato','Adrien',303510300,21,to_date('2-18-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Adriene','Balle','Adriene',303604112,21,to_date('2-21-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Adrienne','Ballejos','Adrienne',303575592,20,to_date('12-31-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Afton','Ballek','Afton',302092145,23,to_date('5-8-1993', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Agatha','Ballen','Agatha',301389827,21,to_date('1-9-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Agnes','Ballena','Agnes',301508941,21,to_date('7-16-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Agnus','Ballengee','Agnus',302297218,24,to_date('4-18-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Agripina','Ballenger','Agripina',301017029,17,to_date('10-13-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Agueda','Ballensky','Agueda',302413217,24,to_date('7-22-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Agustin','Ballentine','Agustin',301620059,17,to_date('8-20-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Agustina','Baller','Agustina',302165639,21,to_date('3-6-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Ahmad','Ballerini','Ahmad',303255527,18,to_date('2-13-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Ahmed','Balles','Ahmed',301210779,23,to_date('7-12-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Ai','Ballestas','Ai',303564032,17,to_date('7-2-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Aida','Ballester','Aida',301958684,20,to_date('5-31-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aide','Ballestero','Aide',301686596,20,to_date('10-31-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Aiko','Ballesteros','Aiko',302441898,21,to_date('7-9-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aileen','Ballesterous','Aileen',302438518,20,to_date('10-19-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Ailene','Balletta','Ailene',302633305,20,to_date('4-26-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aimee','Balletto','Aimee',303920416,23,to_date('12-26-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aisha','Ballew','Aisha',301364868,19,to_date('12-8-1997', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Aja','Balley','Aja',301226044,24,to_date('9-8-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Akiko','Ballez','Akiko',302699178,19,to_date('1-6-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Akilah','Balleza','Akilah',302328790,22,to_date('2-5-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Al','Balli','Al',301002610,18,to_date('11-7-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alaina','Balliet','Alaina',302694036,24,to_date('8-4-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alaine','Balliett','Alaine',303048771,21,to_date('5-15-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alan','Balliew','Alan',302408987,21,to_date('4-9-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alana','Ballif','Alana',302126360,19,to_date('4-20-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alane','Ballin','Alane',302464974,21,to_date('4-14-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alanna','Ballina','Alanna',301885940,17,to_date('10-2-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alayna','Cerar','Alayna',302500489,23,to_date('9-16-1993', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alba','Cerasi','Alba',303630310,20,to_date('7-18-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Albert','Ceraso','Albert',303919929,22,to_date('1-18-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Albert','Cerasoli','Albert',302946898,21,to_date('11-23-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alberta','Cerasuolo','Alberta',301312109,19,to_date('4-16-1997', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Albertha','Ceravolo','Albertha',303929385,17,to_date('10-15-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Albertina','Cerbantes','Albertina',301473669,19,to_date('10-22-1997', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Albertine','Cerbone','Albertine',302372352,19,to_date('6-20-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alberto','Cerce','Alberto',303790161,21,to_date('8-28-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Albina','Cerceo','Albina',303618882,19,to_date('1-4-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alda','Cerchia','Alda',302677236,21,to_date('12-7-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alden','Cercone','Alden',302586080,17,to_date('10-21-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aldo','Cercy','Aldo',302387917,22,to_date('3-26-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alease','Cerda','Alease',301900032,19,to_date('2-15-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alec','Cerdan','Alec',301830018,21,to_date('4-8-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alecia','Cerecedes','Alecia',301093098,23,to_date('5-25-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aleen','Cerecer','Aleen',303862692,24,to_date('1-13-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aleida','Cereceres','Aleida',302870663,17,to_date('12-29-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aleisha','Cereghino','Aleisha',301289503,24,to_date('5-18-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alejandra','Cerenzia','Alejandra',303540284,23,to_date('9-29-1993', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alejandrina','Cereo','Alejandrina',302037640,22,to_date('3-8-1994', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alejandro','Ceretti','Alejandro',301203266,19,to_date('8-6-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alena','Cerezo','Alena',303261868,22,to_date('7-29-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alene','Cerf','Alene',302011671,24,to_date('2-12-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alesha','Cerino','Alesha',303573586,23,to_date('1-15-1994', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aleshia','Cerio','Aleshia',302859380,19,to_date('4-3-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alesia','Cerise','Alesia',302029436,20,to_date('3-16-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alessandra','Cermak','Alessandra',302689308,21,to_date('6-24-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aleta','Cermeno','Aleta',301880383,23,to_date('3-20-1993', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Aletha','Cerminaro','Aletha',303303663,17,to_date('8-18-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alethea','Cerna','Alethea',302858574,24,to_date('11-17-1992', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alethia','Cernansky','Alethia',301650532,18,to_date('12-30-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alex','Cerney','Alex',301206715,24,to_date('7-11-1992', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alex','Cerni','Alex',301286695,21,to_date('8-19-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alexa','Cerniglia','Alexa',301394375,20,to_date('6-4-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alexander','Cernoch','Alexander',303381784,19,to_date('7-3-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alexander','Cernohous','Alexander',301969280,17,to_date('11-25-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alexandra','Cernota','Alexandra',301939650,25,to_date('1-23-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alexandria','Cernuto','Alexandria',303818302,24,to_date('12-28-1992', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alexia','Cerny','Alexia',301382790,20,to_date('8-12-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alexis','Ceron','Alexis',301462989,22,to_date('6-18-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alexis','Cerone','Alexis',301321535,17,to_date('4-24-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alfonso','Ceroni','Alfonso',301996907,19,to_date('6-7-1997', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alfonzo','Ceronsky','Alfonzo',301914251,18,to_date('1-4-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alfred','Cerqueira','Alfred',302282918,24,to_date('10-1-1992', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alfreda','Cerra','Alfreda',302177219,21,to_date('7-10-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alfredia','Cerrano','Alfredia',303390492,22,to_date('7-25-1994', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alfredo','Cerrato','Alfredo',303399543,18,to_date('11-25-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Ali','Cerrello','Ali',302719271,24,to_date('5-28-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Ali','Cerreta','Ali',301680696,20,to_date('5-30-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alia','Cerri','Alia',302354953,18,to_date('10-13-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alica','Namaka','Alica',302099085,20,to_date('1-26-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alice','Naman','Alice',303155860,23,to_date('4-13-1993', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alicia','Namanny','Alicia',303110169,17,to_date('8-5-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alida','Namanworth','Alida',302560252,24,to_date('5-26-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alina','Namauu','Alina',303036981,21,to_date('11-19-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aline','Namdar','Aline',302017577,24,to_date('1-31-1993', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alisa','Namer','Alisa',301285202,21,to_date('5-22-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alise','Namey','Alise',303975250,19,to_date('7-24-1997', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alisha','Namihira','Alisha',302168881,19,to_date('1-19-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alishia','Namisnak','Alishia',301198758,22,to_date('10-6-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alisia','Namm','Alisia',302658211,19,to_date('11-30-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alison','Nampel','Alison',302935750,17,to_date('5-27-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alissa','Namsaly','Alissa',302138596,23,to_date('6-24-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alita','Namur','Alita',303647046,21,to_date('12-26-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alix','Nan','Alix',303738278,22,to_date('4-16-1994', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Aliza','Nanas','Aliza',302934578,19,to_date('7-17-1997', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alla','Nanasy','Alla',301781581,21,to_date('4-10-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Allan','Nance','Allan',301591845,22,to_date('4-3-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alleen','Nancy','Alleen',301615879,19,to_date('10-25-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Allegra','Nanda','Allegra',303186070,18,to_date('9-5-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Allen','Nanes','Allen',302330794,19,to_date('9-11-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Allen','Nanez','Allen',303545179,25,to_date('1-15-1992', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Allena','Nanfito','Allena',301640672,18,to_date('5-1-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Allene','Nang','Allene',302004948,17,to_date('10-30-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Allie','Nangle','Allie',302844329,24,to_date('11-4-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alline','Nani','Alline',302408587,23,to_date('5-3-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Allison','Nania','Allison',302985276,17,to_date('8-30-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Allyn','Nanik','Allyn',301426001,24,to_date('8-16-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Allyson','Nanka','Allyson',302970722,20,to_date('9-11-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alma','Nanke','Alma',302143329,25,to_date('1-28-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Almeda','Nanna','Almeda',303279992,18,to_date('11-5-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Almeta','Nannen','Almeta',302149880,24,to_date('9-6-1992', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alona','Nanney','Alona',301176516,21,to_date('3-4-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alonso','Nanni','Alonso',303636923,20,to_date('8-15-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alonzo','Nannie','Alonzo',302985622,17,to_date('5-22-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alpha','Nannini','Alpha',303922925,22,to_date('3-16-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alphonse','Nanny','Alphonse',302582528,18,to_date('4-1-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alphonso','Nansteel','Alphonso',302871786,18,to_date('12-21-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alta','Zutter','Alta',302218837,17,to_date('8-20-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Altagracia','Zuver','Altagracia',303563636,20,to_date('2-10-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Altha','Zuvich','Altha',301076810,23,to_date('11-5-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Althea','Zuwkowski','Althea',303282427,24,to_date('10-13-1992', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alton','Zuziak','Alton',303083258,24,to_date('12-12-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alva','Zvorsky','Alva',303471945,21,to_date('9-1-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alva','Zwack','Alva',302373987,17,to_date('8-8-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alvaro','Zwagerman','Alvaro',302090263,21,to_date('1-5-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alvera','Zwahlen','Alvera',303529300,19,to_date('8-2-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alverta','Zwanzig','Alverta',301296266,21,to_date('10-24-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alvin','Zwart','Alvin',301848465,20,to_date('11-7-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alvina','Zweier','Alvina',303941758,22,to_date('1-25-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alyce','Zweifel','Alyce',302593486,24,to_date('12-6-1992', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alycia','Zweig','Alycia',302733492,18,to_date('6-5-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alysa','Zwerschke','Alysa',303457819,20,to_date('9-9-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alyse','Zwick','Alyse',302257710,17,to_date('9-17-1999', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Alysha','Zwicker','Alysha',303616776,19,to_date('12-7-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alysia','Zwickl','Alysia',303638719,21,to_date('6-30-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alyson','Zwiebel','Alyson',303937786,19,to_date('8-19-1997', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Alyssa','Zwiefel','Alyssa',301615873,17,to_date('4-7-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amada','Zwiefelhofer','Amada',302802850,22,to_date('4-29-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Amado','Zwiener','Amado',302550661,18,to_date('1-28-1999', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amal','Zwigart','Amal',303226313,21,to_date('7-16-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amalia','Zwilling','Amalia',302253612,20,to_date('8-9-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Amanda','Zwinger','Amanda',303013010,23,to_date('5-27-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amber','Zwingman','Amber',301898391,22,to_date('8-8-1994', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amberly','Zwolak','Amberly',302712702,20,to_date('7-22-1996', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Ambrose','Zwolensky','Ambrose',301742650,18,to_date('2-20-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Amee','Zwolinski','Amee',301705244,21,to_date('10-7-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amelia','Zwolski','Amelia',302028063,20,to_date('10-28-1996', 'MM-DDD-YYYY'),'F');
SELECT insert_student('America','Zybia','America',302852686,21,to_date('8-14-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Ami','Zych','Ami',302972585,22,to_date('7-27-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Amie','Zygmont','Amie',302733544,21,to_date('2-14-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amiee','Zyla','Amiee',303693699,18,to_date('11-9-1998', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Amina','Zylka','Amina',301110525,23,to_date('6-12-1993', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amira','Zylstra','Amira',301174407,22,to_date('12-6-1994', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Ammie','Zymowski','Ammie',301992813,21,to_date('11-19-1995', 'MM-DDD-YYYY'),'M');
SELECT insert_student('Amos','Zynda','Amos',302273624,22,to_date('1-31-1995', 'MM-DDD-YYYY'),'F');
SELECT insert_student('Amparo','Zysett','Amparo',301736104,18,to_date('12-30-1998', 'MM-DDD-YYYY'),'M');
SELECT insert_reslifeAccount('Brianna97','Brianna','Welters','Brianna',1,301516485);
SELECT insert_reslifeAccount('Brianne35','Brianne','Weltha','Brianne',1,301186319);
SELECT insert_reslifeAccount('Brice76','Brice','Welti','Brice',1,301641117);
SELECT insert_reslifeAccount('Bridget8','Bridget','Weltmer','Bridget',1,303674794);
SELECT insert_reslifeAccount('Bridgett65','Bridgett','Welton','Bridgett',1,303742900);
SELECT insert_reslifeAccount('Bridgette8','Bridgette','Welty','Bridgette',2,301635836);
SELECT insert_reslifeAccount('Brigette44','Brigette','Weltz','Brigette',2,302282078);
SELECT insert_reslifeAccount('Brigid38','Brigid','Weltzin','Brigid',2,302922716);
SELECT insert_reslifeAccount('Brigida95','Brigida','Welz','Brigida',1,301015219);
SELECT insert_reslifeAccount('Brigitte68','Brigitte','Welzel','Brigitte',1,303898091);
SELECT insert_reslifeAccount('Brinda93','Brinda','Wemark','Brinda',1,303163901);
SELECT insert_reslifeAccount('Britany89','Britany','Wember','Britany',1,303690452);
SELECT insert_reslifeAccount('Britney78','Britney','Wemhoff','Britney',2,301964012);
SELECT insert_reslifeAccount('Britni26','Britni','Wemmer','Britni',2,302577084);
SELECT insert_reslifeAccount('Britt93','Britt','Wempa','Britt',1,301401526);
SELECT insert_reslifeAccount('Britt73','Britt','Wempe','Britt',1,302040864);
SELECT insert_reslifeAccount('Britta39','Britta','Wemple','Britta',1,301344492);
SELECT insert_reslifeAccount('Brittaney97','Brittaney','Wen','Brittaney',1,302021255);
SELECT insert_reslifeAccount('Brittani96','Brittani','Wence','Brittani',1,302273143);
SELECT insert_reslifeAccount('Brittanie55','Brittanie','Wenciker','Brittanie',3,302647286);
SELECT insert_housingAccount('Cheyenne13','Cheyenne','Vaccarezza',1,303450145);
SELECT insert_housingAccount('Chi73','Chi','Vaccarino',1);
SELECT insert_housingAccount('Chi38','Chi','Vaccaro',1);
SELECT insert_housingAccount('Chia97','Chia','Vacchiano',1);
SELECT insert_housingAccount('Chieko22','Chieko','Vacek',1);
SELECT insert_housingAccount('Chin73','Chin','Vacha',2);
SELECT insert_housingAccount('China85','China','Vache',2);
SELECT insert_housingAccount('Ching86','Ching','Vacher',2);
SELECT insert_housingAccount('Chiquita50','Chiquita','Vacheresse',1);
SELECT insert_housingAccount('Chloe62','Chloe','Vachon',1,301177799);