use db_class_airline;

-- Add common airports
DROP PROCEDURE IF EXISTS GenerateAirports;

DELIMITER $$
CREATE PROCEDURE GenerateAirports()
BEGIN
	INSERT INTO Airport (code, city, country) VALUES
		('CID', 'Cedar Rapids', 'United States'),
		('ATL', 'Atlanta', 'United States'),
		('PEK', 'Beijing', 'China'),
		('LAX', 'Los Angeles', 'United States'),
		('HND', 'Tokyo', 'Japan'),
		('ORD', 'Chicago', 'United States'),
		('DFW', 'Dallas', 'United States'),
		('DEN', 'Denver', 'United States'),
		('JFK', 'New York City', 'United States'),
		('SFO', 'San Francisco', 'United States'),
		('SEA', 'Seattle', 'United States'),
		('LAS', 'Las Vegas', 'United States'),
		('MCO', 'Orlando', 'United States'),
		('DXB', 'Dubai', 'United Arab Emirates'),
		('DEL', 'Delhi', 'India'),
		('MAD', 'Madrid', 'Spain');
END$$
DELIMITER ;

CALL GenerateAirports();

    
-- Generate aircrafts
DROP PROCEDURE IF EXISTS GenerateAircrafts;

DELIMITER $$
CREATE PROCEDURE GenerateAircrafts(numAircrafts INT)
BEGIN
	DECLARE i INT;
    DECLARE end_i INT;
    SET i = 0;
    SET end_i = numAircrafts;
    
    WHILE i < end_i DO
		-- Pick a random aircraft from 4 options and insert it
		INSERT INTO Aircraft (name) 
			SELECT ELT(FLOOR(RAND() * 4) + 1, 'Boeing 747', 'Airbus A380', 'Boeing 737', 'Airbus A320');
		SET i = i + 1;
	END WHILE;
END$$
DELIMITER ;
    
CALL GenerateAircrafts(1000);


-- Generate seats for each aircraft
DROP PROCEDURE IF EXISTS GenerateSeats;

DELIMITER $$
CREATE PROCEDURE GenerateSeats()
BEGIN
	DECLARE finished TINYINT(1) DEFAULT 0;
	DECLARE aircraftId INT;
    DECLARE seatRowIndex INT;
    DECLARE maxSeatRowIndex INT DEFAULT 10; -- Number of seat rows in an aircraft (1-10)
    DECLARE seatColumnIndex INT;
    DECLARE seatColumnLetter CHAR(1);
    DECLARE maxSeatColumnIndex INT DEFAULT 3; -- Number of seat columns in an aircraft (A-C)
    DECLARE fullSeatName VARCHAR(6);
    DECLARE seatClass VARCHAR(12);

	-- Establish cursor to iterate through all aircrafts
	DECLARE c CURSOR FOR (SELECT id FROM Aircraft);

	-- When cursor hits end of table, set finished to 1
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

	OPEN c;

	iterateAircrafts: LOOP
		-- Get next aircraft id
		FETCH c INTO aircraftId;
		IF finished = 1 THEN 
			LEAVE iterateAircrafts;
		END IF;
        
        -- Doubly nested loop to add seats to each aircraft
        SET seatRowIndex = 1;
        WHILE seatRowIndex <= maxSeatRowIndex DO
			IF seatRowIndex < 2 THEN
				SET seatClass = 'First';
			ELSEIF seatRowIndex < 5 THEN
				SET seatClass = 'Business';
			ELSE
				SET seatClass = 'Economy';
            END IF;
        
			SET seatColumnIndex = 1;
			WHILE seatColumnIndex <= maxSeatColumnIndex DO
				SET seatColumnLetter = ELT(seatColumnIndex, 'A', 'B', 'C');
                SET fullSeatName = (SELECT CONCAT(seatRowIndex, seatColumnLetter));
                
                -- Insert seat
                INSERT INTO Seat (name, class, aircraftId) VALUES (fullSeatName, seatClass, aircraftId);
                
                SET seatColumnIndex = seatColumnIndex + 1;
            END WHILE;
            
            SET seatRowIndex = seatRowIndex + 1;
        END WHILE;
	END LOOP iterateAircrafts;
	CLOSE c;
END$$
DELIMITER ;

CALL GenerateSeats();


-- Generate flights
DROP PROCEDURE IF EXISTS GenerateFlights;

DELIMITER $$
CREATE PROCEDURE GenerateFlights(numFlights INT)
BEGIN
	DECLARE airport1 CHAR(5);
    DECLARE airport2 CHAR(5);
    DECLARE departTime DATETIME;
    DECLARE airlineRandomNumber FLOAT;
    DECLARE airlineName VARCHAR(40);
    DECLARE aircraftId INT;
    
    DECLARE i INT;
    DECLARE end_i INT;
    SET i = 0;
    SET end_i = numFlights;
    
    WHILE i < end_i DO
		-- Randomly select two airports
		SET airport1 = (SELECT code FROM Airport ORDER BY RAND() LIMIT 1);
		SET airport2 = airport1;
		WHILE airport1 = airport2 DO
			SET airport2 = (SELECT code FROM Airport ORDER BY RAND() LIMIT 1);
		END WHILE;
		
		-- Randomly select departure time within the next week
		SET departTime = (SELECT NOW() + INTERVAL FLOOR(RAND() * 7 * 24 * 60) MINUTE);
		
		-- Randomly select airline (85% American, 7.5% United, 7.5% Southwest)
		SET airlineRandomNumber = RAND();
		IF airlineRandomNumber < .85 THEN
			SET airlineName = 'American Airlines';
		ELSEIF airlineRandomNumber < .925 THEN
			SET airlineName = 'United Airlines';
		ELSE
			SET airlineName = 'Southwest Airlines';
		END IF;
        
        -- Randomly select an aircraft
        SET aircraftId = (FLOOR(RAND() * (SELECT COUNT(*) FROM Aircraft) + 1));
        
        -- Insert flight into table
        INSERT INTO Flight (fromAirportCode, toAirportCode, departureDate, airline, aircraftId)
			VALUES (airport1, airport2, departTime, airlineName, aircraftId);
        
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL GenerateFlights(1000);


-- Generate a couple of users
DROP PROCEDURE IF EXISTS GenerateUsers;

DELIMITER $$
CREATE PROCEDURE GenerateUsers()
BEGIN
	INSERT INTO User 
		(username, password, firstName, lastName, dateOfBirth, gender, country, 
         addressLine1, city, email, phoneType, phoneNumber)
        VALUES
        ('user1', 'password1', 'John', 'Smith', '1990-05-01', 'male', 'United States', '116 Winchester Ln', 'Dallas',
         'johnsmith@gmail.com', 'mobile', '2613997268'),
		('user2', 'password2', 'Elizabeth', 'Cormier', '1992-10-15', 'female', 'France', '2831 Eiffel Pl', 'Paris',
         'liz-cormier@gmail.com', 'home', '6728319002');
END$$
DELIMITER ;

CALL GenerateUsers();


