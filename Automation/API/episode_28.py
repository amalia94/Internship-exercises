# 5 - From episode 28, list all the characters who have "Rick" in their name.

import requests


def get_characters_from_episode(episode_id):
    url = f"https://rickandmortyapi.com/api/episode/{episode_id}"
    response = requests.get(url)
    data = response.json()
    return data['characters']


def get_character_name(character_url):
    response = requests.get(character_url)
    data = response.json()
    return data['name']


def main():
    episode_id = 28
    characters = get_characters_from_episode(episode_id)
    rick_characters = []
    for character_url in characters:
        name = get_character_name(character_url)
        if 'Rick' in name:
            rick_characters.append(name)


    for i, name in enumerate(rick_characters, 1):
        print(f"{i}. {name}")


if __name__ == "__main__":
    main()
