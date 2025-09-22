import os
import pandas as pd
from tkinter import Tk, filedialog, simpledialog, messagebox

def select_excel_file():
    """Open a file dialog to select an Excel file."""
    file_path = filedialog.askopenfilename(
        title="Select an Excel File",
        filetypes=[("Excel Files", "*.xlsx *.xls")]
    )
    return file_path

def select_worksheet(file_path):
    """Prompt the user to select a worksheet if multiple exist."""
    try:
        sheets = pd.ExcelFile(file_path).sheet_names
        if len(sheets) == 1:
            return sheets[0]
        else:
            return simpledialog.askstring(
                "Select Worksheet",
                f"Available worksheets: {', '.join(sheets)}\nEnter the worksheet name:"
            )
    except Exception as e:
        messagebox.showerror("Error", f"Failed to read worksheets: {e}")
        return None

def select_header_row(file_path, sheet_name):
    """Prompt the user to specify the header row."""
    try:
        df_preview = pd.read_excel(file_path, sheet_name=sheet_name, header=None, nrows=5)
        preview_text = df_preview.to_string(index=False, header=False)
        header_row = simpledialog.askinteger(
            "Select Header Row",
            f"Preview of the first 5 rows:\n\n{preview_text}\n\nEnter the row number (1-based) where the headers are located:"
        )
        return header_row - 1 if header_row else None  # Convert to 0-based index
    except Exception as e:
        messagebox.showerror("Error", f"Failed to preview the file: {e}")
        return None

def select_column(df, file_name):
    """Prompt the user to select a column from the DataFrame."""
    columns = df.columns.tolist()
    return simpledialog.askstring(
        "Select Column",
        f"Columns in {file_name}: {', '.join(columns)}\nEnter the column name to compare:"
    )

def clean_column(df, column_name):
    """Remove leading and trailing spaces from a column."""
    df[column_name] = df[column_name].astype(str).str.strip()
    return df

def main():
    # Initialize Tkinter
    root = Tk()
    root.withdraw()  # Hide the root window

    # Step 1: Select Base File
    messagebox.showinfo("Step 1", "Select the Base Excel File")
    base_file = select_excel_file()
    if not base_file:
        return
    base_sheet = select_worksheet(base_file)
    if not base_sheet:
        return
    base_header_row = select_header_row(base_file, base_sheet)
    if base_header_row is None:
        return
    base_df = pd.read_excel(base_file, sheet_name=base_sheet, header=base_header_row)
    base_column = select_column(base_df, "Base File")
    if base_column not in base_df.columns:
        messagebox.showerror("Error", f"Column '{base_column}' not found in Base File.")
        return
    base_df = clean_column(base_df, base_column)

    # Step 2: Select Target File
    messagebox.showinfo("Step 2", "Select the Target Excel File")
    target_file = select_excel_file()
    if not target_file:
        return
    target_sheet = select_worksheet(target_file)
    if not target_sheet:
        return
    target_header_row = select_header_row(target_file, target_sheet)
    if target_header_row is None:
        return
    target_df = pd.read_excel(target_file, sheet_name=target_sheet, header=target_header_row)
    target_column = select_column(target_df, "Target File")
    if target_column not in target_df.columns:
        messagebox.showerror("Error", f"Column '{target_column}' not found in Target File.")
        return
    target_df = clean_column(target_df, target_column)

    # Step 3: Perform Comparison
    base_values = set(base_df[base_column].dropna())
    target_values = set(target_df[target_column].dropna())

    # Records in Target but not in Base
    in_target_not_base = target_df[~target_df[target_column].isin(base_values)]

    # Records in Base but not in Target
    in_base_not_target = base_df[~base_df[base_column].isin(target_values)]

    # Step 4: Export Results
    output_folder = os.path.join(os.getcwd(), "Output Files")
    os.makedirs(output_folder, exist_ok=True)
    output_path = os.path.join(output_folder, "Comparison_Result.xlsx")

    with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
        in_target_not_base.to_excel(writer, sheet_name="In Target Not Base", index=False)
        in_base_not_target.to_excel(writer, sheet_name="In Base Not Target", index=False)

    messagebox.showinfo("Success", f"Comparison complete! Results saved to:\n{output_path}")

if __name__ == "__main__":
    main()