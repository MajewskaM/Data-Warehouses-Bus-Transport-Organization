import os
# function to save registration and bus type to a file (shorten bus only to show in SQL)
data_folder = "data_to_transform"
if not os.path.exists(data_folder):
    os.makedirs(data_folder)

bus_reg_type_2020_file_path = os.path.join(
    data_folder, "Bus_Registration_Type_2020.bulk")
bus_reg_type_2021_file_path = os.path.join(
    data_folder, "Bus_Registration_Type_2021.bulk")

bus_2020_file_path = os.path.join(
    data_folder, "Bus_2020.txt")
bus_2021_file_path = os.path.join(
    data_folder, "Bus_2021_additions.txt")

    

def save_registration_and_bus_type(filename, data):
    with open(filename, "w+", encoding="UTF-8") as file:
        for row in data:
            registration_number = row.split(',')[1]
            bus_type = row.split(',')[4]
            feedback_monitor = row.split(',')[10]
            file.write(f"{registration_number},{bus_type},{feedback_monitor}")
bus_list_2020 = []
bus_list_2021 = []
# Open the file in read mode
with open(bus_2020_file_path, 'r') as file:
    # Iterate over each line in the file
    for line in file:
        # Each line is read as a string and appended to the list
        bus_list_2020.append(line)

# Open the file in read mode
with open(bus_2021_file_path, 'r') as file:
    # Iterate over each line in the file
    for line in file:
        # Each line is read as a string and appended to the list
        bus_list_2021.append(line)

update_bus_2020_file_path = os.path.join(
    data_folder, "Bus_2020_UPDATES.txt")

# file to create updates in existing sql data
#update: we update bus feature: FeedbackMonitor in all of the 2020 buses
updates_sql = []
with open(update_bus_2020_file_path, "w+", encoding="UTF-8") as file:
    for bus in bus_list_2020:
        if int(bus.split(',')[10]) == 0:
            bus_reg = bus.split(',')[1]
            updates_sql.append(f"UPDATE BUS SET FeedbackMonitor=1 WHERE RegistrationNumber='{bus_reg}';")

    file.write('\n'.join(updates_sql))
    
# save bus registration and type files
save_registration_and_bus_type(bus_reg_type_2020_file_path, bus_list_2020)
save_registration_and_bus_type(
    bus_reg_type_2021_file_path, bus_list_2021)
