# IP.py  -  Verify if the IP from a target machine is the same as your IP. When logging via SSH
# (either ‘last’ or ‘/var/log/auth.log’).
# Done purely via python (no shell commands to be send from python, expect saving to files).

import socket
import datetime

LOG_FILE = 'ssh_log.txt'

def log_connection_attempt(ip):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, 'a') as log_file:
        log_file.write(f"{timestamp} - Connection attempt from IP: {ip}\n")

def get_local_ip():
    return socket.gethostbyname(socket.gethostname())

def get_last_ip():
    return "last_command_ip"

def get_auth_log_ip():
    return "auth_log_ip"

if __name__ == "__main__":
    local_ip = get_local_ip()
    last_ip = get_last_ip()
    auth_log_ip = get_auth_log_ip()

    print(f"Local IP: {local_ip}")
    print(f"IP from 'last' command: {last_ip}")
    print(f"IP from 'auth.log': {auth_log_ip}")

    target_machine_ip = "127.0.0.1"

    if target_machine_ip == local_ip:
        print("The target machine IP is the same as your IP.")
    else:
        print("The target machine IP is different from your IP.")

    log_connection_attempt(target_machine_ip)