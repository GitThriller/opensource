import os
import re
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
    for file_name in os.listdir(folder_path):
        if file_name.endswith(('.mp4', '.avi', '.mkv', '.flv', '.wmv','.ts','.mov')):
            name_to_count = process_video_name(file_name) if process_names else file_name
            video_counts[name_to_count] = video_counts.get(name_to_count, 0) + 1
    return video_counts

def extract_video_counts(master_folder_path):
    video_counts = count_videos_in_folder(master_folder_path, process_names=True)

    # Iterate through the subfolders
    for item in os.listdir(master_folder_path):
        full_path = os.path.join(master_folder_path, item)
        
        # Check if it's a subfolder
        if os.path.isdir(full_path):
            # Count videos in the subfolder
            video_counts[item] = sum(count_videos_in_folder(full_path).values())

    video_data = list(video_counts.items())
    video_df = pd.DataFrame(video_data, columns=['Folder_Name', 'Count'])
    
    # Sort by folder name
    video_df.sort_values('Folder_Name', inplace=True)

    return video_df


folder_path = ''
video_df = extract_video_counts(folder_path)

# Define the path to save the text file
save_path = ""

# Save the DataFrame as a text file
video_df.to_csv(save_path, sep='\t', index=False)

print(f"Video list saved to {save_path}")
