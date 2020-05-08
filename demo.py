from airline_application import AirlineApplication
import datetime

def run_demo():
    app = AirlineApplication()

    # Register user and save new user id
    print('Register user and save new user id')
    user_id = app.register_user(username='miles', password='securepassword', firstName='Miles', lastName='Henrichs', 
                                dateOfBirth='1998-04-09', gender='male', country='United States', addressLine1='415 Elm St', 
                                city='Iowa City', email='miles-henrichs@uiowa.edu', phoneType='mobile', phoneNumber='3191234567')
    print('Newly created user id is %d' % (user_id))

    print('\n\n')

    # Log in user with username = "user1" and password = "password1"
    print('Log in user with username = "user1" and password = "password1"')
    user_id = app.log_in(username='user1', password='password1')
    print('User id is %d' % (user_id,))

    print('\n\n')

    # Search for flights from Cedar Rapids to Denver that depart in the next couple of days
    print('Search for flights from Cedar Rapids to Denver that depart in the next couple of days')
    flights = app.search_flights(fromAirport='CID', toAirport='DEN', 
                                departAfter=datetime.date(2020, 5, 5), departBefore=datetime.date(2020, 5, 9), americanOnly=True)
    for flight in flights:
        print(flight)

    print('\n\n')

    # View available seats for a specific flight
    print('View available seats for a specific flight (flight #121)')
    seats = app.get_available_seats(flightId=121)
    print('%d available seats' % (len(seats),))
    print(seats)

    print('\n\n')

    # Book a seat on a flight
    print('Book a seat on a flight (flight #121, seat 3A)')
    purchased_ticket = app.book_flight(flightId=121, userId=1, seatType='Adult', seatName='3A')
    print(purchased_ticket)
    print('\nNow available seats are:')
    seats = app.get_available_seats(flightId=121)
    print('%d available seats' % (len(seats),))
    print(seats)

    print('\n\n')

    # Find my trips (tickets registered to user)
    print('Find my trips')
    tickets = app.find_user_trips(userId=1)
    for ticket in tickets:
        print(ticket)
    

if __name__ == '__main__':
    run_demo()