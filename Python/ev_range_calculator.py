

def estimated_available_range():
    battery_capacity = 62  # kWh
    consumption = 15.6  # kWh/km
    battery_level = 90  # %
    calculate_battery_capacity = (battery_level * battery_capacity) / 100
    print(calculate_battery_capacity)
    calculate_consumption = (calculate_battery_capacity / consumption) * 100
    print(calculate_consumption)


estimated_available_range()
