class ReadLinuxCommands:
    def __init__(self, linux_cmd):
        self.linux_cmd = linux_cmd

    def display_content(self):
        try:
            with open(self.linux_cmd, 'r') as file:
                content = file.read()
                print(content)
        except FileNotFoundError:
            print("File not found.")

# Usage example
file_reader = ReadLinuxCommands("linux_cmd")
file_reader.display_content()

