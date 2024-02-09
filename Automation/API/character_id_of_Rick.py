# 1 - Get the Character id of Rick Sanchez.

import requests


def get_character_id(name):
    url = "https://rickandmortyapi.com/api/character"
    response = requests.get(url, params={"name": name})

    if response.status_code == 200:
        data = response.json()
        if data["results"]:
            return data["results"][0]["id"]

    return None


rick_id = get_character_id("Rick Sanchez")
print(f"The character ID of Rick Sanchez is {rick_id}.")
