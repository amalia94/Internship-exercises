import requests
import json

response = requests.get('https://api.github.com')

# If the response was successful, no Exception will be raised
response.raise_for_status()

# Access the content of the response
json_response = response.json()

# Use json.dumps to print the response in a pretty format
print(json.dumps(json_response, indent=4))