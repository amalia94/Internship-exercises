# 6 - List all the characters who are not Alive from episode 29.

import requests


def get_characters_from_episode(episode_id):
    url = f"https://rickandmortyapi.com/api/episode/{episode_id}"
    response = requests.get(url)
    data = response.json()
    return data['characters']


def get_character_details(character_url):
    response = requests.get(character_url)
    data = response.json()
    return data['name'], data['status']


def main():
    episode_id = 29
    characters = get_characters_from_episode(episode_id)
    not_alive_characters = []
    for character_url in characters:
        name, status = get_character_details(character_url)
        if status != 'Alive':
            not_alive_characters.append(name)

    # Enumerate and print the characters
    for i, name in enumerate(not_alive_characters, 1):
        print(f"{i}. {name}")


if __name__ == "__main__":
    main()
