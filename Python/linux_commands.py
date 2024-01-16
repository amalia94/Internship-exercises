import os

directory_name = "linux_directory"
if os.path.exists(directory_name):
    print("linux_directory - already exists.")
else:
    os.mkdir(directory_name)
    print("linux_directory - created successfully.")


class LinuxCommandSender:
    def __init__(self):
        pass

    def send_command(self, command):
        os.system(command)

    def list_directory(self, directory):
        command = f'ls {directory}'
        self.send_command(command)

    def change_directory(self, directory):
        command = f"cd {directory}"
        self.send_command(command)

    def create_directory(self, directory):
        command = f"mkdir {directory}"
        self.send_command(command)

    def remove_directory(self, directory):
        command = f"rm -r {directory}"
        self.send_command(command)


command_sender = LinuxCommandSender()


class Home:
    pass


class Files:
    pass


command_sender.list_directory("/home/amalia")
command_sender.change_directory("/home/amalia/Downloads")
command_sender.create_directory("new_directory2")