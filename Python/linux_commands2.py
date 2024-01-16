import os

print("Command 1 - pwd")
print("Command 2 - ls")
print("Command 3 - cd")
print("Command 4 - mkdir")
print("Command 5 - rename file")

choose_command = input("Choose your bash command")

match choose_command:
    case "1":
        os.system("pwd")

    case "2":
        os.system("ls")

    case "3":
        os.system("cd")

    case "4":
        os.system("mkdir")

    case "5":
        os.system("rename file")

    case "6":
        create_new_dir = input("Create a new directory")
        rename_file = input("Rename an existing file")
        list_details = input("Show details from this file")



