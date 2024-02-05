# name_changer.py - Create a .py script that navigates through files in a directory and rename
# all files with all capital letters.
# The script shall create the following folder/file structure.
# It will replace with capital letters (only first and last letter of name),
# only folders/ directories and files with no extension.

import os


def rename_files(directory):
    messages = []
    for root, dirs, files in os.walk(directory):
        for item in dirs + files:
            if '.' not in item:
                old_path = os.path.join(root, item)
                base, ext = os.path.splitext(item)
                if ext == '':
                    new_name = base[0].upper() + base[1:-1].upper() + base[-1].upper() if len(base) > 2 else base.upper()
                    new_path = os.path.join(root, new_name)

                    if old_path != new_path:
                        os.rename(old_path, new_path)
                        messages.append(f"The file without extension '{item}' has been modified.")

    return messages


if __name__ == "__main__":
    target_directory = r"C:\Users\agiurgea\PycharmProjects\Internship-exercises\Automation"
    result_messages = rename_files(target_directory)

    for message in result_messages:
        print(message)


