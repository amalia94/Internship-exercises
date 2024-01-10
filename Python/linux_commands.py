class ReadLinuxCommands:
    def __init__(self, linux_cmd):
        self.linux_cmd = linux_cmd

    def display_content(self):
        try:
            with open(self.linux_cmd, 'r') as file:
                lines = file.readlines()
                first_10_lines = lines[:10]
                for line in first_10_lines:
                    print(line.strip())
        except FileNotFoundError:
            print("File not found.")


file_reader = ReadLinuxCommands("linux_cmd")
file_reader.display_content()

