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
    def get_results_from_procedure(self):
        return [r for buffer in self.cursor.stored_results() for r in buffer.fetchall()]

    # Search for flights which can be booked
    # Returns a list of strings in the following format:
    # American Airlines flight #121:  CID -> DEN   05/08/20 01:37 PM
    def search_flights(self, fromAirport='', toAirport='', departAfter='', departBefore='', americanOnly=True):
        self.cursor.callproc('SearchFlights', (fromAirport, toAirport, departAfter, departBefore, americanOnly))
        results = self.get_results_from_procedure()
        
        flights = []
        for r in results:
            departureTimeStr = r[3].strftime('%m/%d/%y %I:%M %p')
            flights.append('%s flight #%d:  %s -> %s   %s' % (r[4], r[0], r[1], r[2], departureTimeStr))
        return flights