import openpyxl

wb = openpyxl.load_workbook(r'C:\Users\erikg\OneDrive\Documents\zzz\Entertainment.xlsx')
ws = wb['ENG']

print("Verification - Fixed formulas:\n")
for i in range(2, 11):
    print(f"Row {i}: {ws[f'C{i}'].value}")
