import os

path = r'H:\A\ENG'
print('Root-level video files in H:\\A\\ENG:')
root_files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]
for f in root_files:
    if f.lower().endswith(('.mp4', '.avi', '.mkv', '.flv', '.wmv', '.ts', '.mov')):
        print('  ', f)
print('Total root videos:', sum(1 for f in root_files if f.lower().endswith(('.mp4', '.avi', '.mkv', '.flv', '.wmv', '.ts', '.mov'))))

print('\nSubfolders sample:')
subfolders = [f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]
for f in subfolders[:50]:
    print('  ', f)
print('Total subfolders:', len(subfolders))
