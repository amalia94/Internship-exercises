start_time = "03-14 17:56:07.996"
end_time = "03-14 17:56:08.357"
file_path = "logcat_apps.txt"

result = []

try:
    with open(file_path, 'r') as file:
        lines = file.readlines()

    for line in lines:
        if start_time <= line[:18] <= end_time:
            words = line.split()
            if words:
                result.append(words[-1])
    print(result)

except FileNotFoundError:
    print("File not found.")
