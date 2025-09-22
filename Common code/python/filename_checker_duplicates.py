import os
import re

# Define the folder path you want to check
folder_path = ''

# Create a list to store folder and file names
folder_and_file_names = []

# Define the file extensions to consider
extensions = ['.ts', '.mp4', '.mov', '.mkv']

# Function to extract the desired name from a file name
def extract_name(filename):
    base_name, extension = os.path.splitext(filename)
    
    if extension in extensions:
        # Use regex to extract the name before '[' and include the extension
        match = re.search(r'(.+?)\s*\[', base_name)
        if match:
            return f"{match.group(1)}{extension}"
        else:
            return f"{base_name}{extension}"
    else:
        # Include the extension for files not in the extensions list
        return f"{base_name}{extension}"

# Iterate through the items (files and subfolders) in the folder
for item in os.listdir(folder_path):
    item_path = os.path.join(folder_path, item)
    if os.path.isfile(item_path):
        # It's a file, extract the name and add it to the list
        folder_and_file_names.append(extract_name(item))
    elif os.path.isdir(item_path):
        # It's a subfolder, add the subfolder name to the list
        folder_and_file_names.append(item)

# Print the total number of items checked
total_items_checked = len(folder_and_file_names)
print(f'Total Items Checked: {total_items_checked}')

# Create a dictionary to store item names and their counts
item_counts = {}
for item in folder_and_file_names:
    if item in item_counts:
        item_counts[item] += 1
    else:
        item_counts[item] = 1

# Print items with counts greater than 1 (duplicates)
print('Duplicate Items:')
for item, count in item_counts.items():
    if count > 1:
        print(f'- {item} (Count: {count})')
