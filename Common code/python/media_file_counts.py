import os
import re
import sys

script_dir = os.path.dirname(os.path.abspath(__file__))
if script_dir in sys.path:
    sys.path.remove(script_dir)

import pandas as pd

def process_video_name(name):
    if name.startswith('['):
        return os.path.splitext(name)[0]
    name = os.path.splitext(name)[0]
    name = re.sub(r'\[.*\]', '', name)
    name = re.sub(r'\(.*\)', '', name)
    name = re.sub(r'\d{1,}', '', name)
    return name.strip()

def count_videos_in_folder(folder_path, process_names=False):
    video_counts = {}
    try:
        entries = os.listdir(folder_path)
    except PermissionError:
        print(f"Skipping inaccessible folder: {folder_path}")
        return video_counts

    for file_name in entries:
        if file_name.endswith(('.mp4', '.avi', '.mkv', '.flv', '.wmv','.ts','.mov')):
            name_to_count = process_video_name(file_name) if process_names else file_name
            video_counts[name_to_count] = video_counts.get(name_to_count, 0) + 1
    return video_counts

def extract_video_counts(master_folder_path):
    video_counts = count_videos_in_folder(master_folder_path, process_names=True)

    # Iterate through the subfolders
    try:
        items = os.listdir(master_folder_path)
    except PermissionError:
        print(f"Skipping inaccessible master folder: {master_folder_path}")
        return pd.DataFrame([], columns=['Folder_Name', 'Count'])

    for item in items:
        full_path = os.path.join(master_folder_path, item)
        
        # Check if it's a subfolder
        if os.path.isdir(full_path):
            # Count videos in the subfolder
            sub_count = count_videos_in_folder(full_path)
            video_counts[item] = sum(sub_count.values())

    video_data = list(video_counts.items())
    video_df = pd.DataFrame(video_data, columns=['Folder_Name', 'Count'])
    
    # Sort by folder name
    video_df.sort_values('Folder_Name', inplace=True)

    return video_df


folder_path = r'H:\A\ENG'
if not os.path.isdir(folder_path):
    raise FileNotFoundError(f"Folder does not exist: {folder_path}")

video_df = extract_video_counts(folder_path)

# Define the path to save the text file
save_path = os.path.join(script_dir, 'video_counts.tsv')

# Save the DataFrame as a text file
video_df.to_csv(save_path, sep='\t', index=False)

print(f"Video list saved to {save_path}")
