import mysql.connector
import os

class AirlineApplication:
    def __init__(self):
        # Create connection to MySQL database.  This requires two environment variables to be
        # configured on your machine (ARLINE_DB_PASSWORD and AIRLINE_DB_NAME).
        self.conn = mysql.connector.connect(user='root', password=os.environ['AIRLINE_DB_PASSWORD'],
                                            host='localhost', database=os.environ['AIRLINE_DB_NAME'])
        
        # Initialize SQL cursor to execute queries and iterate through result sets
        self.cursor = self.conn.cursor()

    # Call this method directly after executing cursor.callproc() to list the result set of the stored procedure.
    # The way that stored procedures are returned by the cursor is a little confusing, so all the logic is
    # encapsulated in this helper method.
    def _get_results_from_procedure(self):
        return [r for buffer in self.cursor.stored_results() for r in buffer.fetchall()]

    @staticmethod
    def _date_to_str(date):
        return date.strftime('%m/%d/%y %I:%M %p')

    # Register a new user by providing necessary account details.
    # Returns the user id of the newly created user.
    def register_user(self, username='', password='', title=None, firstName='', middleName=None, lastName='', suffix=None, 
                        preferredName=None, dateOfBirth='', gender='', country='', addressLine1='', addressLine2=None, 
                        city='', email='', phoneType='', phoneNumber=''):
        self.cursor.callproc('CreateUser', (username, password, title, firstName, middleName, lastName, suffix,
                                            preferredName, dateOfBirth, gender, country, addressLine1, addressLine2,
                                            city, email, phoneType, phoneNumber))
        self.conn.commit()
        user_id = self._get_results_from_procedure()[0]
        return user_id

    # Log in a user by providing credentials (username and password).
    # Returns user id if login was successful, -1 otherwise.
    def log_in(self, username='', password=''):
        self.cursor.callproc('LogIn', (username, password))
        result = self._get_results_from_procedure()[0]

        if bool(result[0]):
            return result[1]
        return -1

    # Search for flights which can be booked
    # Returns a list of strings in the following format:
    # American Airlines flight #121:  CID -> DEN   05/08/20 01:37 PM
    def search_flights(self, fromAirport='', toAirport='', departAfter='', departBefore='', americanOnly=True):
        self.cursor.callproc('SearchFlights', (fromAirport, toAirport, departAfter, departBefore, americanOnly))
        results = self._get_results_from_procedure()
        
        flights = []
        for r in results:
            flights.append('%s flight #%d:  %s -> %s   %s' % (r[4], r[0], r[1], r[2], self._date_to_str(r[3])))
        return flights

    # Find which seats are available to book for a given flight
    # Returns a list of strings, each of which is a seat name (i.e. ['2A', '3D'])
    def get_available_seats(self, flightId=1):
        self.cursor.callproc('GetAvailableSeats', (flightId,))
        results = self._get_results_from_procedure()

        return [result[0] for result in results]

    # Books a single ticket for a flight given a flightId, seatType (adult, child, etc), and seat name (1A, 3B, etc)
    # Inserts an entry into the Ticket table and returns a string representation of the ticket that was purchased
    def book_flight(self, flightId=1, userId=1, seatType='', seatName=''):
        self.cursor.callproc('BookFlight', (flightId, userId, seatType, seatName))
        self.conn.commit()
        ticket_info = self._get_results_from_procedure()
        t = ticket_info[0]

        return '%s #%d  %s Ticket  Seat %s (%s class)  Departs at %s' % (t[0], t[1], t[3], t[2], t[4], self._date_to_str(t[5]))

    # Returns a list of strings representing all the tickets for future flights the user has purchased
    # Strings are in the form:
    # CID -> DEN  American Airlines #121  Adult  Seat 3A (Business class)  Departs at 05/08/20 01:37 PM
    def find_user_trips(self, userId=1):
        self.cursor.callproc('FindUserTrips', (userId,))
        results = self._get_results_from_procedure()

        tickets = []
        for r in results:
            tickets.append('%s -> %s  %s #%d  %s  Seat %s (%s class)  Departs at %s' 
                                % (r[0], r[1], r[2], r[3], r[4], r[5], r[6], self._date_to_str(r[7])))
        return tickets