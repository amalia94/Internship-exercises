# 3 - Get all the episodes where "Gene" has appeared, and the location for him.

import requests


def get_character_info(character_name):
    response = requests.get(f'https://rickandmortyapi.com/api/character/?name={character_name}')
    data = response.json()

    if data['info']['count'] > 0:
        character = data['results'][0]  # Get the first character matching the name
        print(f"Name: {character['name']}")
        print(f"Location: {character['location']['name']}")
        print("Episode URLs:")
        for episode_url in character['episode']:
            print(episode_url)
    else:
        print(f"No character named {character_name} found.")


if __name__ == "__main__":
    get_character_info("Gene")
