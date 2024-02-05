# sed.py -  Python script to replace data via terminal commands in log.txt file.
# It will replace the time-stamp with the any of the last two words from the line,
# if any one of them are exclusively numbers. The change shall apply to the same file.


import re


def replace_timestamp(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()

        for i in range(len(lines)):
            words = lines[i].split()
            if len(words) >= 2:
                last_word = words[-1]
                second_last_word = words[-2]

                if re.match(r'^\d+$', last_word) or re.match(r'^\d+$', second_last_word):
                    # Replace timestamp with the last word or second last word
                    lines[i] = re.sub(r'\d{2}:\d{2}:\d{2}', last_word, lines[i])

        with open(file_path, 'w') as file:
            file.writelines(lines)

        print(f"Timestamps replaced successfully in {file_path}")

    except Exception as e:
        print(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    log_file_path = "log.txt"

    replace_timestamp(log_file_path)
