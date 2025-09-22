import os
import re
from pathlib import Path

# Configuration
# --------------------
delimiter = "\t"
delimiters_before = 32
delimiters_after = 235
input_path = Path("")
output_path = Path("")
multi_line_limit = 10 # change this limit when there is a huge block of empty rows
# --------------------

escaped_delimiter = re.escape(delimiter)
delimiter_pre_string = f'([^{escaped_delimiter}]*){escaped_delimiter}'
delimiter_post_string = f'{escaped_delimiter}([^{escaped_delimiter}]*)'

regexString = "^" + (delimiter_pre_string * delimiters_before) + \
    "(.*)" + (delimiter_post_string * delimiters_after) + "$"

print("DISCLAIMER: Make sure you check row counts after this and do spot checks on the imported data to make sure nothing has been lost")

for filename in [f for f in input_path.glob('*') if f.is_file()]:
    rd = open(filename, 'r', newline='\r\n', errors='replace')
    out = open(output_path / filename.name, 'w+',
               errors='replace', encoding='utf-8')

    lineNo = 0
    fileDict = {}

    while True:
        line = rd.readline()
        lineNo += 1
        attempt_count = 1

        if not line:
            break

        new_line = ''
        matches = re.search(regexString, line.replace(
            '\r\n', '').replace('\n', '').replace('\r', ''))

        # If the match failed, it might be an unexpected newline in the file
        # Keep trying to add the next line until we match or hit the limit set in config
        while matches is None and attempt_count < multi_line_limit:
            attempt_count += 1
            line += rd.readline()
            lineNo += 1
            matches = re.search(regexString, line.replace(
                '\r\n', '').replace('\n', '').replace('\r', ''))
            if matches is not None:
                print(
                    f'{filename}: Line {lineNo} did not match regex but we fixed it')

        for group_index in range(1, matches.re.groups + 1):
            new_line += matches.group(group_index) if group_index != delimiters_before + \
                1 else matches.group(group_index).replace(delimiter, ' ').replace('"', '”')

            if (group_index != matches.re.groups):
                new_line += delimiter

        out.write(new_line[:-1] + '\n')
    out.close()
    rd.close()