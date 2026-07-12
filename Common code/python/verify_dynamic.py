import openpyxl

wb = openpyxl.load_workbook(r'C:\Users\erikg\OneDrive\Documents\zzz\Entertainment.xlsx')
ws = wb['ENG']

print("Sample formulas after update:\n")
for i in [2, 5, 10, 100, 500]:
    print(f"Row {i}: {ws[f'C{i}'].value}")
