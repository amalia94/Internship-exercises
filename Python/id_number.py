def validate_id_number(func):
    def wrapper(id_number):
        if len(id_number) != 13:
            return "Invalid ID number length"
        if not id_number.isdigit():
            return "ID number should contain only digits"
        return func(id_number)

    return wrapper


def validate_last_component(funct):
    def wrapper(id_number):
        personal_numeric_code = [int(x) for x in id_number]
        constant_num = [2, 7, 9, 1, 4, 6, 3, 5, 8, 2, 7, 9]
        total = sum(personal_numeric_code * constant_num for numeric_code, constant_num in
                    zip(personal_numeric_code[:12], constant_num)) % 11
        awaited_sum = 1 if total == 10 else total
        try:
            if personal_numeric_code[12] != awaited_sum:
                raise ValueError("ID number sum is invalid")
        except ValueError as error:
            print(error)

        return funct(id_number)

    return wrapper()


county_codes = {
    '42': 'Vrancea',
    '34': 'Sibiu'
}
county = county_codes.keys()


@validate_id_number
def interpret_id_number(id_number):
    sex = int(id_number[0])
    year = int(id_number[1:3])
    month = int(id_number[3:5])
    day = int(id_number[5:7])
    county = int(id_number[7:9])

    county_codes = {
        '42': 'Vrancea',
        '34': 'Sibiu'
    }
    county = county_codes.keys()


    gender = "Male" if sex in [1, 3, 5, 7] else "Female" if sex in [2, 4, 6, 8] else "Unknown"

    if sex in [5, 7]:
        year += 2000
    elif sex in [6, 8]:
        year += 2000
    elif sex in [1, 2]:
        year += 1900
    elif sex in [3, 4]:
        year += 1800

    id_interpretation = {
        'gender': gender,
        'year': year,
        'month': month,
        'day': day,
        'county': county

}
    return id_interpretation

id_number = "9231207890123"
result = interpret_id_number(id_number)
print(result)
