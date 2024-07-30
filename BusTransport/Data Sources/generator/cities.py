import itertools

region_postalcode_city = {
    "Kuyavia-Pomerania": {"85": "Bydgoszcz", "87": "Torun"},
    "Pomerania": {"80": "Gdansk", "81": "Gdynia"},
    "Warmia-Masuria": {"10": "Olsztyn", "82": "Elblag"},
    "Masovia": {"00": "Warszawa", "26": "Radom"},
    "West Pomerania": {"70": "Szczecin", "75": "Koszalin"}
}

# generating a dictionary with all possible city connections as tuple and assigning a line number


def connect_cities(cities_info):

    city_combinations = {}
    all_cities = []

    # collect all possible cities
    for region, cities in cities_info.items():
        for city in cities.values():
            all_cities.append(city)

    # generate combinations
    combinations = list(itertools.combinations(all_cities, 2))
    for combo in combinations.copy():
        reversed_combo = tuple(reversed(combo))
        if reversed_combo not in combinations:
            combinations.append(reversed_combo)

    # add line numbers
    for line_num, combo in enumerate(combinations, start=1):
        city_combinations[combo] = line_num

    return city_combinations
