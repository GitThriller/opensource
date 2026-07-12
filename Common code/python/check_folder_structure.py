import os

# Check the folder structure
eng_path = r'H:\A\ENG'
print("Checking folder structure in H:\\A\\ENG:\n")
print("Sample subdirectories:\n")
count = 0
for item in os.listdir(eng_path):
    item_path = os.path.join(eng_path, item)
    if os.path.isdir(item_path):
        # Count video files in this subfolder
        video_count = sum(1 for f in os.listdir(item_path) if f.lower().endswith(('.mp4', '.avi', '.mkv', '.flv', '.wmv', '.ts', '.mov')))
        print(f"  Folder: '{item}' - {video_count} videos")
        count += 1
        if count >= 30:
            break
