import os
import random
import numpy as np
from faker import Faker
from service_office_gen import region_postalcode_city

fake = Faker('pl_PL')

data_folder = "data"
if not os.path.exists(data_folder):
    os.makedirs(data_folder)

bus_stops_file_path = os.path.join(data_folder, "Bus_Stops.txt")

# Excel Bus_Stops sheet 1

Bus_Stops = []
bus_stop_id = 1
bus_stops_airports_ids = []

with open(bus_stops_file_path, "w+", encoding="UTF-8") as file:
    for region, cities in region_postalcode_city.items():
        for city in cities.values():
            bus_stop_counter = 1
            bus_stop_name = city + "'s Bus Stop no. "
            longitude = round(random.uniform(14.0, 24.0), 4)
            latitude = round(random.uniform(49.0, 54.0), 4)
            sitting_place = np.random.randint(2)
            airport = random.choices([0, 1], weights=[0.7, 0.3])[0]
            if airport:
                bus_shelter = np.random.randint(2)
                row_excel2 = f"{bus_stop_id},{bus_stop_name}{bus_stop_counter} - Airport,{longitude},{latitude},{sitting_place},{airport},{bus_shelter}"
                Bus_Stops.append(row_excel2)
                bus_stops_airports_ids.append(bus_stop_id)
                bus_stop_id += 1
                bus_stop_counter += 1

            airport = 0
            bus_shelter = np.random.randint(2)
            row_excel2 = f"{bus_stop_id},{bus_stop_name}{bus_stop_counter},{longitude},{latitude},{sitting_place},{airport},{bus_shelter}"
            Bus_Stops.append(row_excel2)
            bus_stop_id += 1

    file.write('\n'.join(Bus_Stops))

# function to return bus stops ids in given city


def get_bus_stop_id(city_name):
    city_stops_ids = [stop.split(',')[0]
                      for stop in Bus_Stops if city_name in stop]
    return city_stops_ids
