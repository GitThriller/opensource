import os

def move_files_to_archive(folder_path, suffix, archive_folder):
    """Moves all files within the specified folder that end with the given suffix to an archive folder.

    Args:
        folder_path (str): The path to the folder containing the files to move.
        suffix (str): The file extension to check for (e.g., ".csv 2.zip").
        archive_folder (str): The path to the archive folder for storing the moved files.
    """

    for filename in os.listdir(folder_path):
        if filename.endswith(suffix):
            file_path = os.path.join(folder_path, filename)
            archive_file_path = os.path.join(archive_folder, filename)

            # Create archive folder if it doesn't exist
            os.makedirs(archive_folder, exist_ok=True)

            try:
                # Move the file
                os.rename(file_path, archive_file_path)
                print(f"Moved file: {file_path} to {archive_file_path}")
            except (FileNotFoundError, FileExistsError) as e:
                print(f"Error moving file: {filename}")
                print(f"{e}")

# Specify the folder path, file suffix, and archive folder
folder_path = r'' # Replace with the actual path to your folder
suffix = ""
archive_folder = r''  # Replace with the actual path to your archive folder

move_files_to_archive(folder_path, suffix, archive_folder)