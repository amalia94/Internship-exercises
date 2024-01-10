# Develop a python function that interprets the standard RO ID number.
def validate_id_number(func):
    def wrapper(id_number):
        if len(id_number) != 13:
            return "Invalid ID number length"
        if not id_number.isdigit():
            return "ID number should contain only digits"
        return func(id_number)
    return wrapper


@validate_id_number
def interpret_id_number(id_number):
    return "The ID number is: " + id_number

#example
id_number = "1234567890123"
result = interpret_id_number(id_number)
print(result)

