import pandas as pd
import os

# Input folder path
input_folder = r""

# Get all Excel files in the input folder
excel_files = [file for file in os.listdir(input_folder) if file.endswith('.xlsx')]

# Initialize a dictionary to store unique row counts
unique_row_counts = {}

# Process each file
for file in excel_files:
    file_path = os.path.join(input_folder, file)
    try:
        # Read the Excel file
        if file == "":
            # Debug: Check if the sheet name is correct
            df = pd.read_excel(file_path, sheet_name='Data', header=1)
            print(f"Debug: First few rows of {file}:\n", df.head())  # Debugging output
        else:
            df = pd.read_excel(file_path, header=1)
        
        # Check if 'Workbook Name' column exists
        if 'Workbook Name' not in df.columns:
            print(f"Error: 'Workbook Name' column not found in {file}")
            continue
        
        # Calculate unique row count based on 'Workbook Name'
        unique_count = df.drop_duplicates(subset=['Workbook Name']).shape[0]
        
        # Store the result
        unique_row_counts[file] = unique_count
    except Exception as e:
        print(f"Error processing file {file}: {e}")

# Print the unique row counts for each file
print("Unique row counts based on 'Workbook Name':")
for file, count in unique_row_counts.items():
    print(f"{file}: {count}")