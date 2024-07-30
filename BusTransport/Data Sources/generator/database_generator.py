import os
import random
from faker import Faker
from datetime import datetime
import numpy as np
import dates_2020
import dates_2021
from cities import region_postalcode_city, connect_cities
import service_office_gen as so
from bus_stops_gen import get_bus_stop_id, bus_stops_airports_ids

fake = Faker('pl_PL')

# create the "data" folder if it doesn't exist
data_folder = "data"
if not os.path.exists(data_folder):
    os.makedirs(data_folder)

# file paths within the "data" folder
route_file_path = os.path.join(data_folder, "Route.bulk")
# update_route_file_path = os.path.join(
#    data_folder, "UPDATE_route_statements.bulk")
schedule_2020_file_path = os.path.join(data_folder, "Schedule_2020.bulk")
schedule_2021_additions_file_path = os.path.join(
    data_folder, "Schedule_2021_additions.bulk")
travel_2020_file_path = os.path.join(data_folder, "Travel_2020.bulk")
travel_2021_additions_file_path = os.path.join(
    data_folder, "Travel_2021_additions.bulk")
validation_2020_file_path = os.path.join(data_folder, "Validation_2020.bulk")
validation_2021_additions_file_path = os.path.join(
    data_folder, "Validation_2021_additions.bulk")
ticket_2020_file_path = os.path.join(data_folder, "Ticket_2020.bulk")
ticket_2021_additions_file_path = os.path.join(
    data_folder, "Ticket_2021_additions.bulk")
feedback_2020_file_path = os.path.join(data_folder, "Feedback_2020.bulk")
feedback_2021_additions_file_path = os.path.join(
    data_folder, "Feedback_2021_additions.bulk")
bus_reg_type_2020_file_path = os.path.join(
    data_folder, "Bus_Registration_Type_2020.bulk")
bus_reg_type_2021_file_path = os.path.join(
    data_folder, "Bus_Registration_Type_2021.bulk")

# files/lists 'x_2021_additions' have only data that was generated in T2 - next timestamp (2021)
# files/lists 'x_2020' have data from first timestamp (2020)

# Changes introduced in 2021:
# 1. add more scheduled journeys (schedule table) on routes (dimension table)
# 2. update of route names (creating sql statements) - change to dimension tables
# 3. a new service office was added and therefore new buses

# Travels happening in 2021 generate data referring to the tables:
# - travel,
# - validation,
# - ticket,
# - feedback.

types_of_day = ["weekend", "holiday", "weekday"]

# function to determine day type


def get_daytype_name(date_str):
    date_obj = datetime.strptime(date_str, '%Y-%m-%d')
    month = date_obj.month

    if month == 7 or month == 8:
        return types_of_day[1]
    elif date_obj.weekday() < 5:
        return types_of_day[2]
    else:
        return types_of_day[0]

# function to generate random departure and arrival times


def generate_random_times(n, route):
    times = []
    route_name = (route.split(',')[1]).split('-')

    for _ in range(n):
        departure_hour = np.random.randint(4, 23)
        departure_minute = np.random.randint(60)
        departure_time = f"{departure_hour:02d}:{departure_minute:02d}"

        max_arrival = 23
        if same_region(route_name[0], route_name[1]):
            max_arrival = min(23, departure_hour + 1)

        arrival_hour = np.random.randint(departure_hour + 1, max_arrival + 1)
        arrival_minute = np.random.randint(60)
        arrival_time = f"{arrival_hour:02d}:{arrival_minute:02d}"

        times.append((departure_time, arrival_time))
    return times

# function to determine if two cities are in the same region


def same_region(city1, city2):
    region1 = find_region(city1)
    region2 = find_region(city2)
    if region1 is not None and region2 is not None:
        return region1 == region2
    else:
        return False

# function to find the region of a city


def find_region(city_name):
    for region, cities in region_postalcode_city.items():
        if city_name in cities.values():
            return region
    return None

# function to save registration and bus type to a file (shorten bus only to show in SQL)
def save_registration_and_bus_type(filename, data):
    with open(filename, "w+", encoding="UTF-8") as file:
        for row in data:
            registration_number = row.split(',')[1]
            bus_type = row.split(',')[4]
            feedback_monitor = row.split(',')[10]
            file.write(f"{registration_number},{bus_type},{feedback_monitor}\n")

# save bus registration and type files
save_registration_and_bus_type(bus_reg_type_2020_file_path, so.bus_list_2020)
save_registration_and_bus_type(
    bus_reg_type_2021_file_path, so.bus_list_2021_additions)

# generate all possible city combinations
city_combinations = connect_cities(region_postalcode_city)


# Route table generation
routes_list = []
routes_to_update_start = []
routes_to_update_end = []

with open(route_file_path, "w+", encoding="UTF-8") as file:
    for connection, route_number in city_combinations.items():
        route_name = f"{connection[0]} - {connection[1]}"
        possible_start_stops = get_bus_stop_id(connection[0])
        possible_end_stops = get_bus_stop_id(connection[1])
        start_stop = random.choice(possible_start_stops)
        end_stop = random.choice(possible_end_stops)
        row_route = f"{route_number},{route_name},{start_stop},{end_stop}"
        routes_list.append(row_route)

        if int(start_stop) in bus_stops_airports_ids:
            routes_to_update_start.append(route_number)

        if int(end_stop) in bus_stops_airports_ids:
            routes_to_update_end.append(route_number)

    file.write('\n'.join(routes_list))


# Schedule table generation
schedule_list_2020 = []
schedule_id = 1

with open(schedule_2020_file_path, "w+", encoding="UTF-8") as file:
    for route in routes_list:
        route_num = route.split(',')[0]
        for i in range(3):
            day_type = types_of_day[i]
            buses_per_day = np.random.randint(i, i + 50)
            random_times = generate_random_times(buses_per_day, route)
            for departure, arrival in random_times:
                row_schedule = f"{schedule_id},{route_num},{departure},{arrival},{day_type}"
                schedule_list_2020.append(row_schedule)
                schedule_id += 1

    file.write('\n'.join(schedule_list_2020))

schedule_list_2021 = schedule_list_2020[:]
schedule_2021_additions = []

# adding more scheduled travels in 2021 year
for _ in range(50):
    route = random.choice(routes_list)
    route_num = route.split(',')[0]
    # we have 3 possible schedules for one route - for each type of the day
    day_type = random.choice(types_of_day)
    random_times = generate_random_times(1, route)
    for departure, arrival in random_times:
        row_schedule = f"{schedule_id},{route_num},{departure},{arrival},{day_type}"
        schedule_list_2021.append(row_schedule)
        schedule_2021_additions.append(row_schedule)
        schedule_id += 1

# file with schedules added in 2021
with open(schedule_2021_additions_file_path, "w+", encoding="UTF-8") as file:
    file.write('\n'.join(schedule_2021_additions))


# Travel table generation
travel_list_2020 = []
travel_list_2021_additions = []
travel_id = 1

with open(travel_2020_file_path, "w+", encoding="UTF-8") as file:
    time_snapshot = 0
    while time_snapshot < 2:
        if time_snapshot == 0:
            data_source = dates_2020.x
            schedule_source = schedule_list_2020
            after_update = False
        else:
            data_source = dates_2021.x
            schedule_source = schedule_list_2021
            change_id = travel_id
            after_update = True

        weekday_schedules = [schedule for schedule in schedule_source if schedule.split(',')[
            4] == "weekday"]
        holiday_schedules = [schedule for schedule in schedule_source if schedule.split(',')[
            4] == "holiday"]
        weekend_schedules = [schedule for schedule in schedule_source if schedule.split(',')[
            4] == "weekend"]

        for date in data_source:
            day = get_daytype_name(date)
            if day == "weekday":
                for schedule in weekday_schedules:
                    bus_route = int(schedule.split(',')[1])
                    bus_registration = so.get_random_bus_from_service(
                        routes_list[(bus_route - 1)], after_update)
                    travel_schedule = schedule.split(',')[0]
                    row_travel = (str(travel_id) + "," + str(bus_registration) + "," +
                                  str(bus_route) + "," + str(travel_schedule) + "," + str(date))
                    if after_update:
                        travel_list_2021_additions.append(row_travel)
                    else:
                        travel_list_2020.append(row_travel)
                    travel_id += 1
            elif day == "holiday":
                for schedule in holiday_schedules:
                    bus_route = int(schedule.split(',')[1])
                    bus_registration = so.get_random_bus_from_service(
                        routes_list[bus_route - 1], after_update)
                    travel_schedule = schedule.split(',')[0]
                    row_travel = (str(travel_id) + "," + str(bus_registration) + "," +
                                  str(bus_route) + "," + str(travel_schedule) + "," + str(date))
                    if after_update:
                        travel_list_2021_additions.append(row_travel)
                    else:
                        travel_list_2020.append(row_travel)
                    travel_id += 1
            else:
                for schedule in weekend_schedules:
                    bus_route = int(schedule.split(',')[1])
                    bus_registration = so.get_random_bus_from_service(
                        routes_list[bus_route - 1], after_update)
                    travel_schedule = schedule.split(',')[0]
                    row_travel = (str(travel_id) + "," + str(bus_registration) + "," +
                                  str(bus_route) + "," + str(travel_schedule) + "," + str(date))
                    if after_update:
                        travel_list_2021_additions.append(row_travel)
                    else:
                        travel_list_2020.append(row_travel)
                    travel_id += 1
        time_snapshot += 1
    file.write('\n'.join(travel_list_2020))

# file with travels added in 2021
with open(travel_2021_additions_file_path, "w+", encoding="UTF-8") as file:
    file.write('\n'.join(travel_list_2021_additions))


# Validations table generation
validations_list_2020 = []
validations_list_2021_additions = []
travel_occupations = []
target_ticket_id = 1
all_travels = travel_list_2020 + travel_list_2021_additions

with open(validation_2020_file_path, "w+", encoding="UTF-8") as file:
    for travel in all_travels:
        bus = travel.split(',')[1]
        travel_id = travel.split(',')[0]
        # change indicating moving to next year
        if int(travel_id) == change_id:
            other_year_ticket_id = target_ticket_id
        places = so.get_avaliable_places(bus)
        occupancy = np.random.randint(2, places + 1)
        non_validated = 0

        for _ in range(occupancy):
            is_validated = np.random.choice([0, 1], p=[0.05, 0.95])

            if is_validated:
                row_validation = f"{target_ticket_id},{travel_id}"
                if int(travel_id) >= change_id:
                    validations_list_2021_additions.append(row_validation)
                else:
                    validations_list_2020.append(row_validation)
            else:
                non_validated += 1
            target_ticket_id += 1
        travel_occupations.append((travel_id, occupancy - non_validated))

    file.write('\n'.join(validations_list_2020))

# file with validations added in 2021
with open(validation_2021_additions_file_path, "w+", encoding="UTF-8") as file:
    file.write('\n'.join(validations_list_2021_additions))


# Ticket table generation
ticket_list_2020 = []
tickets_list_2021_additions = []
ticket_id = 1

with open(ticket_2020_file_path, "w+", encoding="UTF-8") as file:
    while ticket_id < target_ticket_id:
        name = so.remove_polish_characters(fake.first_name())
        surname = so.remove_polish_characters(fake.last_name())
        email = fake.email()
        row_ticket = f"{ticket_id},{name},{surname},{email}"

        if ticket_id >= other_year_ticket_id:
            tickets_list_2021_additions.append(row_ticket)
        else:
            ticket_list_2020.append(row_ticket)
        ticket_id += 1

    file.write('\n'.join(ticket_list_2020))

# file with tickets added in 2021
with open(ticket_2021_additions_file_path, "w+", encoding="UTF-8") as file:
    file.write('\n'.join(tickets_list_2021_additions))


# Feedback table generation
feedback_list_2020 = []
feedbacks_list_2021_additions = []
feedback_id = 1
with open(feedback_2020_file_path, "w+", encoding="UTF-8") as file:
    for travel_id, occupancy in travel_occupations:
        satisfactions_received = np.random.randint(occupancy + 1)
        while satisfactions_received > 0:
            satisfaction_lvl = np.random.randint(1, 11)
            row_feedback = f"{feedback_id},{travel_id},{satisfaction_lvl}"
            if int(travel_id) >= change_id:
                feedbacks_list_2021_additions.append(row_feedback)
            else:
                feedback_list_2020.append(row_feedback)
            feedback_id += 1
            satisfactions_received -= 1

    file.write('\n'.join(feedback_list_2020))


# file with feedbacks added in 2021
with open(feedback_2021_additions_file_path, "w+", encoding="UTF-8") as file:
    file.write('\n'.join(feedbacks_list_2021_additions))
