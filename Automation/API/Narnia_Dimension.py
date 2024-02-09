# 4 - List all the characters who are alive and appeared in the "Narnia Dimension", regardless of episode or season.

import requests


def get_alive_characters_in_narnia_dimension():
    url = 'https://rickandmortyapi.com/api/character'
    alive_characters_in_narnia_dimension = []

    while url:
        response = requests.get(url)
        data = response.json()

        for character in data['results']:
            if character['status'].lower() == 'alive' and character['location']['name'].lower() == 'narnia dimension':
                alive_characters_in_narnia_dimension.append(character['name'])

        url = data['info']['next']

    return alive_characters_in_narnia_dimension


def main():
    characters = get_alive_characters_in_narnia_dimension()

    if characters:
        print("The following characters are alive and have appeared in the Narnia Dimension:")
        for character in characters:
            print(character)
    else:
        print("No characters found who are alive and have appeared in the Narnia Dimension.")


if __name__ == "__main__":
    main()
