import colorama
from colorama import Fore
colorama.init(autoreset=True)  # colored text output

signals = [
    {'name': 'LDW_AlertStatus', 'byte': 2, 'bit': 5, 'size': 2, 'new_value': 2},
    {'name': 'LCA_OverrideDisplay', 'byte': 5, 'bit': 2, 'size': 1, 'new_value': 1},
    {'name': 'DW_FollowUpTimeDisplay', 'byte': 4, 'bit': 7, 'size': 6, 'new_value': 45}
]

frames = [
    "80 00 00 00 00 00 00 00",
    "40 00 00 10 00 00 00 00",
    "FF 60 00 00 02 00 00 00",
    "21 20 00 00 02 00 00 00",
    "80 00 00 00 00 00 00 00",
    "80 00 00 00 00 00 00 00"
]


def update_frame(frame, signal):
    # remove spaces from the frame
    frame = frame.replace(" ", "")

# convert hex string to binary string
    binary_frame = bin(int(frame, 16))[2:].zfill(64)

# extract the portion of the frame that corresponds to the signal
    start = 64 - (signal['byte'] * 8 + signal['bit'] + signal['size'])
    end = start + signal['size']
    signal_value = bin(signal['new_value'])[2:].zfill(signal['size'])

# extract the original signal value
    original_value = int(binary_frame[start:end], 2)

# update the signal in the frame
    updated_frame = binary_frame[:start] + signal_value + binary_frame[end:]

# convert the binary string back to hex
    updated_frame_hex = hex(int(updated_frame, 2))[2:].zfill(16)

    return original_value, updated_frame_hex


# print the original frames
for frame in frames:
    print(f"{Fore.LIGHTCYAN_EX}Original frame:{Fore.LIGHTYELLOW_EX} {frame.upper()}")

# iterate through frames and update signals
for i, frame in enumerate(frames):
    if i < len(signals):
        original_value, frames[i] = update_frame(frame, signals[i])
        print(
            f"{Fore.RED}Original {signals[i]['name']} {Fore.BLUE}value: {original_value}")
        print(
            f"{Fore.YELLOW}Updated {signals[i]['name']} {Fore.GREEN}value: {signals[i]['new_value']}")

# print the updated frames
for updated_frame in frames:
    print(f"{Fore.LIGHTCYAN_EX}Updated frame: {Fore.LIGHTYELLOW_EX}{updated_frame.upper()}")
