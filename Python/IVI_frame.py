payload_1 = "60 20 45 6C FE 3D 4B AA"
payload_2 = "40 12 6C AF 05 78 4A 04"

payload_1 = payload_1.split()
payload_2 = payload_2.split()

signals = [
    ["PassengerSeat", 0, 7, 3],
    ["TimeFormat", 5, 3, 1],
    ["ClimFP", 5, 7, 4]
]

def hex_to_binary(payload):
   return bin(int(payload, 16))[2:].zfill(8)

payload_1_bin = []
payload_2_bin = []

for hex1, hex2 in zip(payload_1, payload_2):
    payload_1_bin.append(hex_to_binary(hex1))
    payload_2_bin.append(hex_to_binary(hex2))
# print(payload_1_bin)
# print(payload_2_bin)

for signal in signals:
    signal_name, byte_position, bit_position, size = signal


    byte_1 = payload_1_bin[byte_position]
    bit_1 = 7-bit_position
    byte_2 = payload_2_bin[byte_position]
    bit_2 = 7-bit_position

    value_1 = int(byte_1[bit_1:bit_1+size], 2)
    value_2 = int(byte_2[bit_2:bit_2+size], 2)
    print("First frame for", signal_name, ":", value_1, "~ Second frame :", value_2)


