import os
from unidecode import unidecode
import numpy as np
import random
from faker import Faker
from cities import region_postalcode_city

fake = Faker('pl_PL')

# create the "data" folder if it doesn't exist
data_folder = "data"
if not os.path.exists(data_folder):
    os.makedirs(data_folder)

# file paths within the "data" folder
service_office_2020_file_path = os.path.join(
    data_folder, "Service_Office_2020.txt")
service_office_2021_additions_file_path = os.path.join(
    data_folder, "Service_Office_2021_additions.txt")
bus_2020_file_path = os.path.join(data_folder, "Bus_2020.txt")
bus_2021_additions_file_path = os.path.join(
    data_folder, "Bus_2021_additions.txt")


# function to remove polish characters
def remove_polish_characters(address):
    return unidecode(address)

# Function to get a random bus from one of the city stations/service offices according to the route
# after_update parameter indicates the range of service offices; in the 2nd timestamp, we have more of them
def get_random_bus_from_service(route, after_update):
    from_city = (route.split(',')[1]).split("-")[0]

    if after_update:
        target_service = service_office_list_2020 + service_office_list_2021_additions
        target_buses = bus_list_2020 + bus_list_2021_additions
    else:
        target_service = service_office_list_2020
        target_buses = bus_list_2020

     # choosing randomly from one of offices in city from which we start our route
    bus_office = [office for office in target_service if from_city in office]

    # if in start city there is no service office, we choose from the destination city
    if len(bus_office) == 0:
        to_city = (route.split(',')[1]).split("-")[1]
        bus_office = [office for office in target_service if to_city in office]
    if len(bus_office) == 0:
        random_bus_office = random.choice(target_service)
    else:
        random_bus_office = random.choice(bus_office)

    office_id = random_bus_office.split(',')[0]
    random_bus = random.choice(
        [bus for bus in target_buses if bus.split(",")[0] == office_id])
    return random_bus.split(',')[1]

# function to get available places for a given registration number of a bus
def get_avaliable_places(reg_number):
    bus_list = bus_list_2020 + bus_list_2021_additions
    for bus in bus_list:
        if bus.split(',')[1] == reg_number:
            bus_info = bus
            break
    return int(bus_info.split(',')[6]) + int(bus_info.split(',')[7])

# Excel Service_Office sheet 1

bus_service_id = 1
service_office_list_2020 = []
service_office_list_2021_additions = []
service_office_region_counter = {
    region: 0 for region in region_postalcode_city.keys()}
bus_slots_cities = []
slots = [8, 9, 10]
BUS_SERVICES_NO_2020 = 20
# assuming new offices were added -> value in 2021 should be grater than value in 2020
BUS_SERVICES_NO_2021 = 24

# generate service offices data for 2020
with open(service_office_2020_file_path, "w+", encoding="UTF-8") as file:
    while bus_service_id < BUS_SERVICES_NO_2021:
        region = random.choice(list(region_postalcode_city.keys()))
        service_office_region_counter[region] += 1
        office_count = service_office_region_counter[region]
        bus_service_name = f"{region}'s Bus Service no. {office_count}"
        postal_code_prefix, city = random.choice(
            list(region_postalcode_city[region].items()))
        postal_code = f"{postal_code_prefix}-{np.random.randint(999):03}"
        address = remove_polish_characters(
            fake.street_name() + " " + fake.building_number())
        country = "Poland"
        bus_slots = random.choice(slots)
        bus_slots_cities.append((bus_slots, city))
        row_service_office = f"{bus_service_id},{bus_service_name},{address},{postal_code},{city},{region},{country},{bus_slots}"

        if (bus_service_id <= BUS_SERVICES_NO_2020):
            service_office_list_2020.append(row_service_office)
        else:
            service_office_list_2021_additions.append(row_service_office)

        bus_service_id += 1

    file.write('\n'.join(service_office_list_2020))

# file with service offices added in 2021
with open(service_office_2021_additions_file_path, "w+", encoding="UTF-8") as file:
    file.write('\n'.join(service_office_list_2021_additions))


# Excel Service_Office sheet 2

bus_list_2020 = []
bus_list_2021_additions = []
types_of_bus = {"minibus": (8, 0), "standard": (15, 7), "low floor": (10, 5)}
reg_cities = {"CB": "Bydgoszcz", "CT": "Torun", "GD": "Gdansk", "GA": "Gdynia", "NO": "Olsztyn",
              "NE": "Elblag", "WA": "Warszawa", "WR": "Radom", "ZS": "Szczecin", "ZK": "Koszalin"}
cities_reg = {v: k for k, v in reg_cities.items()}
bus_regnum_2020 = []
all_bus_regnum = []
bus_brand = ["Volvo", "Mercedes-Benz", "Man", "Solaris"]
bus_service_id = 1

# generate bus data for 2020
with open(bus_2020_file_path, "w+", encoding="UTF-8") as file:
    for num_of_bus, office_city in bus_slots_cities:
        for _ in range(num_of_bus):
            service_id = bus_service_id
            registration_number = cities_reg[office_city] + \
                str(random.choice(range(10000, 99999)))
            vin = fake.vin()
            brand = random.choice(bus_brand)
            bus_type = random.choice(list(types_of_bus.keys()))
            production_year = np.random.randint(2005, 2019)
            seats, standing_places = types_of_bus[bus_type]
            wheelchair = np.random.randint(2)
            air_conditioning = np.random.randint(2)
            feedback_monitor = np.random.randint(2)
            row_bus = f"{service_id},{registration_number},{vin},{brand},{bus_type},{production_year},{seats},{standing_places},{wheelchair},{air_conditioning},{feedback_monitor}"

            if bus_service_id <= BUS_SERVICES_NO_2020:
                bus_list_2020.append(row_bus)
                bus_regnum_2020.append(registration_number)
            else:
                bus_list_2021_additions.append(row_bus)
            all_bus_regnum.append(registration_number)
        bus_service_id += 1

    file.write('\n'.join(bus_list_2020))

# file with buses added in 2021
with open(bus_2021_additions_file_path, "w+", encoding="UTF-8") as file:
    file.write('\n'.join(bus_list_2021_additions))
    
update_bus_2020_file_path = os.path.join(
    data_folder, "Bus_2020_UPDATES.txt")

bus_reg_type_2020_file_path = os.path.join(
    data_folder, "Bus_Registration_Type_2020.bulk")

bus_reg_type_2021_file_path = os.path.join(
    data_folder, "Bus_Registration_Type_2021.bulk")

# file to create updates in existing sql data
#update: we update bus feature: FeedbackMonitor in all of the 2020 buses
updates_sql = []
with open(update_bus_2020_file_path, "w+", encoding="UTF-8") as file:
    for bus in bus_list_2020:
        if int(bus.split(',')[10]) == 0:
            bus_reg = bus.split(',')[1]
            updates_sql.append(f"UPDATE BUS SET FeedbackMonitor=1 WHERE RegistrationNumber='{bus_reg}';")

    file.write('\n'.join(updates_sql))

def save_registration_and_bus_type(filename, data):
    with open(filename, "w+", encoding="UTF-8") as file:
        for row in data:
            registration_number = row.split(',')[1]
            bus_type = row.split(',')[4]
            feedback_monitor = row.split(',')[10]
            file.write(f"{registration_number},{bus_type},{feedback_monitor}")

# save bus registration and type files
save_registration_and_bus_type(bus_reg_type_2020_file_path, bus_list_2020)
save_registration_and_bus_type(bus_reg_type_2021_file_path, bus_list_2021_additions)





