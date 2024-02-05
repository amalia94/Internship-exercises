# cpu.py - Create a .py script to display every 1s, processor and ram usage.
# Use colors: green < 50%, yellow: 50%-75%, red >75%. (use packages/tools for both Linux and Python)

import os
import psutil
import time


def get_color(value, thresholds):
    if value < thresholds[0]:
        return "\033[92m"  # CPU verde
    elif thresholds[0] <= value < thresholds[1]:
        return "\033[93m"  # RAM galben
    else:
        return "\033[91m"  # rosu


def display_usage():
    while True:
        cpu_usage = psutil.cpu_percent(interval=1)
        ram_usage = psutil.virtual_memory().percent

        cpu_color = get_color(cpu_usage, [50, 75])  # verde
        ram_color = get_color(ram_usage, [50, 75])  # galben

        os.system('cls' if os.name == 'nt' else 'clear')  # Clear screen for Linux and Windows compatibility

        print(f"CPU Usage: {cpu_color}{cpu_usage:.2f}%\033[0m")
        print(f"RAM Usage: {ram_color}{ram_usage:.2f}%\033[0m")

        breakpoint()

        time.sleep(1)


if __name__ == "__main__":
    display_usage()
