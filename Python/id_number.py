import string


def validate_id_number(func):
    def wrapper(id_number):
        if len(id_number) != 13:
            return "Invalid ID number length"
        if not id_number.isdigit():
            return "ID number should contain only digits"
        return func(id_number)

    return wrapper


def convert(id_number):
    id_number(string.split())
    return id_number


def id_parameters(id_parameters):
    year = int(id_number[1:3])
    month = int(id_number[3:5])
    day = int(id_number[5:7])
    county = int(id_number[7:9])


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

    gender = 'M' if sex in [1, 3, 5, 7] else "F"

    if sex in [5, 6]:
        year += 2000

    id_interpretation = {
        'gender': gender,
        'year': year,
        'month': month,
        'day': day,
        'county': county

    }
    return id_interpretation


id_number = "5231207890123"
result = interpret_id_number(id_number)
print(result)
