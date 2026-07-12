import os

# List first 20 files from ENG folder
eng_path = r'H:\A\ENG'
print("Sample files from H:\\A\\ENG:\n")
count = 0
for root, dirs, files in os.walk(eng_path):
    for file in files:
        if file.lower().endswith(('.mp4', '.avi', '.mkv', '.flv', '.wmv', '.ts', '.mov')):
            print(f"  {file}")
            count += 1
            if count >= 20:
                break
    if count >= 20:
        break

print(f"\nTotal scanned: {count}")
