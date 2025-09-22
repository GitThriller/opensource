import json
import csv
import re

# Function to extract all string values within single quotes from SQL data
def extract_string_values(sql_content):
    return re.findall(r"'(.*?)'", sql_content)

# Function to check if a single value exists in JSON data
def value_exists_in_json(value, json_data):
    return value in str(json_data)

# Function to check if a single value exists in CSV data
def value_exists_in_csv(value, csv_data):
    for row in csv_data:
        if value in row:
            return True
    return False

# Read and parse the SQL file
sql_file_path = r''
with open(sql_file_path, 'r') as sql_file:
    sql_content = sql_file.read()

# Extract all string values from SQL content
sql_string_values = extract_string_values(sql_content)

# Read and parse the JSON file
json_file_path = r''
with open(json_file_path, 'r') as json_file:
    json_data = json.load(json_file)

# Check each string value against the JSON data
for value in sql_string_values:
    if not value_exists_in_json(value, json_data):
        print(f"Value '{value}' does not exist in JSON file.")


'''for value in sql_string_values:
    if value_exists_in_json(value, json_data):
        print(f"Value '{value}' exists in JSON file.")
    else:
        print(f"Value '{value}' does not exist in JSON file.")'''


# Read and parse the CSV file
csv_file_path = r''
with open(csv_file_path, 'r') as csv_file:
    csv_reader = csv.reader(csv_file,delimiter='|')
    csv_data = list(csv_reader)

    # Check each string value against the CSV data and report only if it does not exist
    for value in sql_string_values:
        if not value_exists_in_csv(value, csv_data):
            print(f"Value '{value}' does not exist in CSV file.")