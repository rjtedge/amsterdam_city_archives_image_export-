import requests
import json

# This is the primary input. You can find this when looking at the allscans page in the archives. eg. for the url https://archief.amsterdam/inventarissen/scans/334/5.1.1.22 the item path is 5.1.1.22
item_path = "5.1.1.22"

base_url = "https://webservices8.picturae.pro/archives/findingaid/334"
api_key = "eb37e65a-eb47-11e9-b95c-60f81db16c0e"
lang = "nl_NL"

url = f"{base_url}?apiKey={api_key}&lang={lang}&itemPath={item_path}"

response = requests.get(url)
data = response.json()

levels = len(item_path.split("."))
split = item_path.split(".")

thumbnail_urls = []  # Initialize an empty list to store thumbnail URLs

if levels == 2:
    print("level 2")
    level1 = int(split[0]) - 1
    for item in data["findingAid"]["tree"][level1]["children"]:
        if item["cpath"] == item_path:
            for x in item["scans"]:
                thumbnail_urls.append(x["thumbnailUrl"])

elif levels == 3:
    print("level 3")
    level1 = int(split[0]) - 1
    level2 = int(split[1]) - 1
    for item in data["findingAid"]["tree"][level1]["children"][level2]["children"]:
        if item["cpath"] == item_path:
            for x in item["scans"]:
                thumbnail_urls.append(x["thumbnailUrl"])

elif levels == 4:
    print("level 4")
    level1 = int(split[0]) - 1
    level2 = int(split[1]) - 1
    level3 = int(split[2]) - 1
    for item in data["findingAid"]["tree"][level1]["children"][level2]["children"][level3]["children"]:
        if item["cpath"] == item_path:
            for x in item["scans"]:
                thumbnail_urls.append(x["thumbnailUrl"])
                
elif levels == 5:
    print("level 5")
    level1 = int(split[0]) - 1
    level2 = int(split[1]) - 1
    level3 = int(split[2]) - 1
    level4 = int(split[3]) - 1
    for item in data["findingAid"]["tree"][level1]["children"][level2]["children"][level3]["children"][level4]["children"]:
        if item["cpath"] == item_path:
            for x in item["scans"]:
                thumbnail_urls.append(x["thumbnailUrl"])
else:
    print("error in code or item path")
modified_strings = []
for thumb in thumbnail_urls:
    # Using a loop
    modified_strings.append(thumb.replace("full/300,", "full/max"))
print(modified_strings)

# Specify the folder where you want to save the files
download_folder = item_path

# Create the folder if it doesn't exist
os.makedirs(item_path, exist_ok=True)

# Download each URL
for index, url in enumerate(modified_strings):
    response = requests.get(url)
    
    if response.status_code == 200:
        # Extract the filename from the URL and add a counter to make it unique
        filename = os.path.join(download_folder, f"{index+1}_{os.path.basename(url)}")
        
        # Save the content to a file
        with open(filename, "wb") as file:
            file.write(response.content)
        print(f"Downloaded: {url}")
    else:
        print(f"Failed to download: {url}")
