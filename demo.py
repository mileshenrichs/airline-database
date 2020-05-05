from airline_application import AirlineApplication
import datetime

def run_demo():
    app = AirlineApplication()

    # 1. Search for flights from Cedar Rapids to Denver that depart in the next couple of days
    print('1. Search for flights from Cedar Rapids to Denver that depart in the next couple of days')
    flights = app.search_flights(fromAirport='CID', toAirport='DEN', 
                                departAfter=datetime.date(2020, 5, 5), departBefore=datetime.date(2020, 5, 9), americanOnly=True)
    for flight in flights:
        print(flight)

    print('\n\n')
    

if __name__ == '__main__':
    run_demo()