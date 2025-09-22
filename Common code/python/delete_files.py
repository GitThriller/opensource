import os

def delete_files_with_suffix(folder_path, suffix):
    """Deletes all files within the specified folder that end with the given suffix.

    Args:
        folder_path (str): The path to the folder containing the files to delete.
        suffix (str): The file extension to check for (e.g., ".csv 2.zip").
    """

    for filename in os.listdir(folder_path):
        if filename.endswith(suffix):
            file_path = os.path.join(folder_path, filename)
            os.remove(file_path)
            print(f"Deleted file: {file_path}")

# Specify the folder path and the file suffix to target
folder_path = r'' # Replace with the actual path to your folder
suffix = ""

delete_files_with_suffix(folder_path, suffix)