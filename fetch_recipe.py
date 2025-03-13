import requests
import json
import urllib.parse
import os  # To work with the file system

# ✅ Replace with your actual Edamam API credentials
APP_ID = "720e210d"
APP_KEY = "446497202cda0b4ee6b1754ba948c3ac"
USER_ID = "ginraidee"  # ✅ Add your Edamam User ID

# ✅ Specify the cuisine type in the query (e.g., "thai", "italian", "mexican")
# Leave it empty to fetch all cuisine types, or specify one for filtering
cuisine_type = ""  # Set this to the cuisine type you want, like 'thai', 'asian', or leave it empty for all cuisines

# ✅ Encode query to prevent errors
query = urllib.parse.quote("thai")  # Use your desired query here, like 'chicken'

# ✅ Define how many recipes to fetch per request
recipes_per_page = 10

# ✅ Ensure the directories exist for both JSON and images
json_dir = "assets/fetchMenu"
image_dir = "assets/fetchMenu"
if not os.path.exists(json_dir):
    os.makedirs(json_dir)  # Create the directory if it doesn't exist
if not os.path.exists(image_dir):
    os.makedirs(image_dir)  # Create the directory for images if it doesn't exist

# ✅ Define the file path for the JSON
json_file_path = os.path.join(json_dir, "recipe_output.json")

# ✅ Load existing data from the JSON file if it exists
existing_recipes = []
if os.path.exists(json_file_path):
    with open(json_file_path, "r", encoding="utf-8") as file:
        existing_data = json.load(file)
        existing_recipes = [recipe['recipe']['label'] for recipe in existing_data['hits']]

# ✅ Initialize starting index and ending index for pagination
start_index = 0
new_recipes_added = False

# Loop to fetch multiple pages of recipes (10 recipes per page)
while True:
    # Calculate the 'from' and 'to' parameters for the API request
    from_index = start_index
    to_index = start_index + recipes_per_page - 1

    # Construct API URL with pagination
    if cuisine_type:  # Only add the cuisineType filter if it's specified
        url = f"https://api.edamam.com/search?q={query}&app_id={APP_ID}&app_key={APP_KEY}&cuisineType={cuisine_type}&from={from_index}&to={to_index}"
    else:
        url = f"https://api.edamam.com/search?q={query}&app_id={APP_ID}&app_key={APP_KEY}&from={from_index}&to={to_index}"

    # ✅ Fetch data
    response = requests.get(url, headers={"Edamam-Account-User": USER_ID})

    # ✅ Check the status code and API response
    if response.status_code == 200:
        data = response.json()

        # If we have results, process each recipe
        if data['hits']:
            # Download images for each recipe (even duplicates)
            for recipe in data['hits']:
                image_url = recipe['recipe'].get('image')
                if image_url:
                    # Extract image filename from URL
                    image_name = recipe['recipe']['label'].replace(" ", "_") + ".jpg"
                    image_path = os.path.join(image_dir, image_name)

                    # Download and save the image
                    try:
                        img_response = requests.get(image_url)
                        if img_response.status_code == 200:
                            with open(image_path, "wb") as img_file:
                                img_file.write(img_response.content)
                            print(f"Image for '{recipe['recipe']['label']}' saved to {image_path}")
                        else:
                            print(f"Failed to download image for '{recipe['recipe']['label']}'")
                    except Exception as e:
                        print(f"Error downloading image for '{recipe['recipe']['label']}': {e}")

            # Filter out duplicates from the new data
            new_recipes = [
                recipe for recipe in data['hits']
                if recipe['recipe']['label'] not in existing_recipes
            ]
            
            if new_recipes:
                # Add new unique recipes to existing data
                existing_data['hits'].extend(new_recipes)
                new_recipes_added = True

                # Save the updated data to the JSON file
                with open(json_file_path, "w", encoding="utf-8") as file:
                    json.dump(existing_data, file, indent=4)

                print(f"New data added and saved to {json_file_path}")

            else:
                print("No new recipes to add, all recipes are duplicates.")
        
        # If there are less than 10 recipes in the current page, stop fetching
        if len(data['hits']) < recipes_per_page:
            break

        # Update the start index for the next iteration
        start_index += recipes_per_page
    else:
        print(f"Error: {response.status_code}")
        print(response.text)  # Prints the full error message from Edamam
        break

# If no new recipes were added, notify the user
if not new_recipes_added:
    print("No new recipes added.")
