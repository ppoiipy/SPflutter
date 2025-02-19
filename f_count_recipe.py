import json
import os

# Path to the JSON file
json_file_path = "assets/fetchMenu/recipe_output.json"

# Check if the file exists
if os.path.exists(json_file_path):
    # Open and load the JSON data
    with open(json_file_path, "r", encoding="utf-8") as file:
        data = json.load(file)
    
    # Count the number of recipes in the 'hits' list
    recipe_count = len(data['hits'])
    print(f"There are {recipe_count} recipes in {json_file_path}")
else:
    print(f"The file {json_file_path} does not exist.")
