import pandas as pd
import tkinter as tk
from tkinter import filedialog
import os

def process_and_group_data():
    """
    Loads a CSV file from a pivot table, cleans it, and groups it to create unique records.
    """
    # Set up the root Tkinter window
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    # Ask the user to select a CSV file
    csv_path = filedialog.askopenfilename(
        title="Select a CSV file to process",
        filetypes=[("CSV files", "*.csv")]
    )

    if not csv_path:
        print("No file selected. Exiting.")
        return

    try:
        # Load the CSV file into a pandas DataFrame
        df = pd.read_csv(csv_path)
    except Exception as e:
        print(f"Error loading CSV file: {e}")
        return

    # --- Data Cleaning and Transformation ---

    # Define the columns we will be working with
    cost_centre_col = 'Cost Centre Code'
    grouping_cols = ['Business / EA Group', 'Offering Porfolio', 'Offering']
    agg_col = 'Cost Centre Name'
    
    required_cols = grouping_cols + [cost_centre_col, agg_col]

    # Check if all required columns exist
    missing_cols = [col for col in required_cols if col not in df.columns]
    if missing_cols:
        print(f"The following required columns are missing from the file: {', '.join(missing_cols)}")
        return

    # 1. Remove "Total" rows from the pivot table output
    df[cost_centre_col] = df[cost_centre_col].astype(str)
    df = df[~df[cost_centre_col].str.contains("Total", na=False, case=False)]

    # 2. Take the last 5 digits of the Cost Centre Code
    df[cost_centre_col] = df[cost_centre_col].str.strip().str[-5:]

    # 3. Group by the specified columns and aggregate the Cost Centre Name
    # We reset the index to turn the grouped output back into a DataFrame
    result_df = df.groupby(grouping_cols + [cost_centre_col]).agg(
        **{agg_col: pd.NamedAgg(column=agg_col, aggfunc='max')}
    ).reset_index()


    # --- Save the result ---

    # Ask the user where to save the cleaned Excel file
    output_path = filedialog.asksaveasfilename(
        title="Save the cleaned data as",
        defaultextension=".xlsx",
        filetypes=[("Excel files", "*.xlsx")],
        initialfile="cleaned_profit_centre_data.xlsx",
        initialdir=os.path.dirname(csv_path)
    )

    if not output_path:
        print("Save cancelled. Exiting.")
        return

    try:
        # Save the result to an Excel file
        result_df.to_excel(output_path, index=False)
        print(f"Cleaned data saved to {output_path}")
    except Exception as e:
        print(f"Error saving Excel file: {e}")


if __name__ == "__main__":
    process_and_group_data()
