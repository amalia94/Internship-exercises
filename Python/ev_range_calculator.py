# Mercedes-AMG EQS Range calculator
# specifications for Mercedes-AMG EQS:
battery_capacity = 100  # kWh
efficiency = 0.2  # kWh/km

# Function to calculate the range


def calculate_range(battery_capacity, efficiency):
    range_km = battery_capacity / efficiency
    return range_km

# Calculate the range for Mercedes AMG QES:


range_eqs = calculate_range(battery_capacity, efficiency)

# Display the result
print("The estimated range for Mercedes AMG EQS is: ", range_eqs, "kilometers")
