import os
insert_time_file = "INSERT_time_2_between.txt"
hours = range(0, 24)
minutes = range(0, 60)
time_of_day_ranges = [
    '0-8',
    '9-12',
    '13-15',
    '16-20',
    '21-23'
]


inserts_sql = []
with open(insert_time_file, "w+", encoding="UTF-8") as file:
    for hour in hours:
        # if hour <= 8:
        #     time_of_day = '0-8'
        # elif hour <= 12:
        #     time_of_day = '9-12'
        # elif hour <= 15:
        #     time_of_day = '13-15'
        # elif hour <= 20:
        #     time_of_day = '16-20'
        # else:
        #     time_of_day = '21-23'

        if hour <= 8:
            time_of_day = 'between 0 and 8'
        elif hour <= 12:
            time_of_day = 'between 9 and 12'
        elif hour <= 15:
            time_of_day = 'between 13 and 15'
        elif hour <= 20:
            time_of_day = 'between 16 and 20'
        else:
            time_of_day = 'between 21 and 23'

        for minute in minutes:
            # time = f"{hour:02d}:{minute:02d}"
            inserts_sql.append(f"INSERT INTO [TIME] (Hour, Minutes, TimeOfDay) VALUES ({hour}, {minute}, '{time_of_day}');")
            
    file.write('\n'.join(inserts_sql))