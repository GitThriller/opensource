import openpyxl

wb = openpyxl.load_workbook(r'C:\Users\erikg\OneDrive\Documents\zzz\Entertainment.xlsx')
ws = wb['ENG']

# Fix rows 2-10 with the correct formula pattern
for row in range(2, 11):
    # Formula should be: =IF(COUNTIF(ENG!A$2:A[row-1],A[row])>1,"Duplicate in ENG","")
    formula = f'=IF(COUNTIF(ENG!A$2:A{row-1},A{row})>1,"Duplicate in ENG","")'
    ws[f'C{row}'].value = formula

wb.save(r'C:\Users\erikg\OneDrive\Documents\zzz\Entertainment.xlsx')
print("Fixed formulas in rows 2-10")
