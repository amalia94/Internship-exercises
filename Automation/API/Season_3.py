# 7 - List all the Species and filter them by types that appear in Season3,
# and if the species is different from Human,list their name based on the Species/Types.

import requests

def get_episode_data(episode_id):
    api_episode = "https://rickandmortyapi.com/api/episode/"
    episode_url = f"{api_episode}{episode_id}"
    response = requests.get(episode_url)
    return response.json()

def get_character_data(character_url):
    response = requests.get(character_url)
    return response.json()

def get_species_list(episode_ids):
    species_list = []
    for episode_id in episode_ids:
        episode_data = get_episode_data(episode_id)
        characters = episode_data.get("characters", [])
        for character_url in characters:
            character_data = get_character_data(character_url)
            species = character_data.get("species")
            character_type = character_data.get("type")
            character_name = character_data.get("name")
            if species and character_type and character_name and species not in ['Human', 'Humanoid']:
                species_list.append({"species": species, "type": character_type, "name": character_name})
    return species_list

def print_species_list(species_list):
    print("Non-Human and Non-Humanoid species types that appear in Season 3:")
    for species_data in species_list:
        print(f'Name: {species_data["name"]}\nSpecies: {species_data["species"]}\nType: {species_data["type"]}\n{"-"*50}')

episode_ids = [22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
species_list = get_species_list(episode_ids)
print_species_list(species_list)

