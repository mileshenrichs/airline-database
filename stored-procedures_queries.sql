use db_class_airline;

-- Log in user query
DROP PROCEDURE IF EXISTS LogIn;

DELIMITER $$
CREATE PROCEDURE LogIn(un VARCHAR(30), pw VARCHAR(30))
BEGIN
	SELECT COUNT(un), id FROM User
		WHERE un = username
		AND pw = password;
END$$
DELIMITER ;

CALL LogIn('user1', 'password1');

-- Register new user query
DROP PROCEDURE IF EXISTS CreateUser;

DELIMITER $$
CREATE PROCEDURE CreateUser(
	un VARCHAR(30), pw VARCHAR(30), ttl VARCHAR(30),
    fn VARCHAR(30), mn VARCHAR(30), ln VARCHAR(30),
    sfx VARCHAR(5), pn VARCHAR(30), dob DATE,
    gd VARCHAR(6), cnt VARCHAR(50), al1 VARCHAR(70),
    al2 VARCHAR(70), ct VARCHAR(50), em VARCHAR(70),
    pt VARCHAR(20), phn VARCHAR(14))
BEGIN
	INSERT INTO User 
		(username, password, title, firstName, middleName, lastName, suffix, preferredName, dateOfBirth,
         gender, country, addressLine1, addressLine2, city, email, phoneType, phoneNumber)
        VALUES (un, pw, ttl, fn, mn, ln, sfx, pn, dob, gd, cnt, al1, al2, ct, em, pt, phn);
        
	SELECT LAST_INSERT_ID();
END$$
DELIMITER ;

CALL CreateUser('miles', 'securepassword', NULL, 'Miles', NULL, 'Henrichs', NULL, NULL, '1998-04-09', 'male', 'United States',
				'615 Elm St', NULL, 'Iowa City', 'miles-henrichs@uiowa.edu', 'mobile', '3191234567');

-- Search flights query
DROP PROCEDURE IF EXISTS SearchFlights;

DELIMITER $$
CREATE PROCEDURE SearchFlights(fromAirport CHAR(5), toAirport CHAR(5), departAfter DATE, departBefore DATE, americanOnly TINYINT(1))
BEGIN
	SELECT * FROM Flight
		WHERE fromAirportCode = fromAirport
        AND toAirportCode = toAirport
        AND departureDate >= departAfter
        AND departureDate <= departBefore
        AND (americanOnly = 0 OR (americanOnly = 1 AND airline = 'American Airlines'))
	ORDER BY departureDate ASC;
END$$
DELIMITER ;

CALL SearchFlights('CID', 'DEN', '2020-05-05', '2020-05-09', 1);


-- View available seats for flight query
DROP PROCEDURE IF EXISTS GetAvailableSeats;

DELIMITER $$
CREATE PROCEDURE GetAvailableSeats(flightId INTEGER)
BEGIN
	SELECT s.name FROM Seat s
		INNER JOIN Aircraft a ON a.id = (SELECT f.aircraftId FROM Flight f WHERE f.id = flightId)
	WHERE s.aircraftId = a.id
    AND s.id NOT IN (SELECT t.holdsSeatId FROM Ticket t WHERE t.forFlightId = flightId);
END$$
DELIMITER ;

CALL GetAvailableSeats(121);


-- Book a flight query
DROP PROCEDURE IF EXISTS BookFlight;

DELIMITER $$
CREATE PROCEDURE BookFlight(flightId INTEGER, userId INT, seatType VARCHAR(14), seatName VARCHAR(6))
BEGIN
	DECLARE aircraftId INT;
	DECLARE seatId INT;
    DECLARE generatedTicketId INT;
    
    SET aircraftId = (SELECT f.aircraftId FROM Flight f WHERE f.id = flightId);
    
    SET seatId = (
			SELECT s.id FROM Seat s
			WHERE s.name = seatName
            AND s.aircraftId = aircraftId
	);

	INSERT INTO Ticket (type, registeredByUserId, holdsSeatId, forFlightId)
		VALUES (seatType, userId, seatId, flightId);
        
	SET generatedTicketId = (SELECT LAST_INSERT_ID());
        
	SELECT f.airline, t.forFlightId, s.name, t.type, s.class, f.departureDate FROM Ticket t
		INNER JOIN Seat s ON s.id = t.holdsSeatID
        INNER JOIN Aircraft a ON a.id = (SELECT f.aircraftId FROM Flight f WHERE f.id = flightId)
        INNER JOIN Flight f ON f.id = flightId
    WHERE t.id = generatedTicketId;
END$$
DELIMITER ;

CALL BookFlight(121, 1, 'Adult', '3B');


-- Find your trips query
DROP PROCEDURE IF EXISTS FindUserTrips;

DELIMITER $$
CREATE PROCEDURE FindUserTrips(userId INT)
BEGIN
	SELECT f.fromAirportCode, f.toAirportCode, f.airline, f.id, t.type, s.name, s.class, f.departureDate FROM Ticket t
		INNER JOIN Seat s ON s.id = t.holdsSeatID
        INNER JOIN Aircraft a ON a.id = s.aircraftId
        INNER JOIN Flight f ON f.id = t.forFlightId
    WHERE t.registeredByUserId = userId
    ORDER BY f.departureDate ASC;
END$$
DELIMITER ;

CALL FindUserTrips(1);


