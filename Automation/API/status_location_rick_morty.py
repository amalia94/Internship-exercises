# 2- Get the current status and location of Rick Sanchez and Morty Smith.

import requests


def get_character_info(name):
    url = "https://rickandmortyapi.com/api/character"
    response = requests.get(url, params={"name": name})

    if response.status_code == 200:
        data = response.json()
        if data["results"]:
            character = data["results"][0]
            return character["status"], character["location"]["name"]

    return None, None


rick_status, rick_location = get_character_info("Rick Sanchez")
morty_status, morty_location = get_character_info("Morty Smith")

print(f"Rick Sanchez is currently {rick_status} and is located at {rick_location}.")
print(f"Morty Smith is currently {morty_status} and is located at {morty_location}.")
