import os
import re
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mpl_dates
import openpyxl
from openpyxl.drawing.image import Image
import tkinter as tk
from tkinter import filedialog
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import seaborn as sns  # Import seaborn for creating heatmaps
import datetime


# Define the directory structure
master_folder = ""
output_folder=""

# Initialize lists to store data
original_names = []
extracted_values = []
filenames = []
years = []
months = []
days = []  # Define the 'days' list to store extracted day values

# Define a regular expression pattern to extract the numeric value after $
pattern = r'\$(\d+\.\d+)'

# Define a regular expression pattern to match filenames with $ symbol
filename_pattern = r'.*(\d{4})(\d{2})(\d{2}) \$.*\.pdf'

# Traverse through subfolders and files
for root, dirs, files in os.walk(master_folder):
    for file in files:
        if file.endswith(".pdf") and re.match(filename_pattern, file):
            full_path = os.path.join(root, file)
            if os.path.abspath(full_path) == os.path.abspath(master_folder):
                continue  # Skip PDF files directly under the master folder
            
            match = re.search(pattern, file)
            
            if match:
                value = float(match.group(1))
                original_names.append(file)
                extracted_values.append(value)
                filenames.append(os.path.basename(root) + "/" + file)
                
                # Extract year, month, and day from the filename
                filename_match = re.match(filename_pattern, file)
                if filename_match:
                    year = int(filename_match.group(1))
                    month = int(filename_match.group(2))
                    day = int(filename_match.group(3))
                else:
                    year = None
                    month = None
                    day = None
                
                years.append(year)
                months.append(month)
                days.append(day)

# Create a DataFrame
data = {
    "Fee category": ['Electricity'] * len(original_names),
    "Amount": extracted_values,
    "Filepath": filenames,
    "Year": years,
    "Month": months,
    "Day": days
}
df = pd.DataFrame(data)

# Reorder columns with Category as the first column
column_order = ["Fee category", "Amount", "Year", "Month", "Day", "Filepath"]
df = df[column_order]

# Save DataFrame to CSV
csv_filename = fr'{output_folder}/electricity_expenses.csv'
df.to_csv(csv_filename, index=False)

# Create windows for line chart and heatmap visualizations
line_chart_window = None
heatmap_window = None

# GUI to visualize line chart
'''def visualize_line_chart():
    global line_chart_window
    if line_chart_window is not None:
        line_chart_window.destroy()

    line_chart_window = tk.Toplevel()
    line_chart_window.title("Welcome to Le's family check out this Line Chart Visualization")

    df = pd.read_csv(csv_filename)
    monthly_total = df.groupby(["Year", "Month"])["Amount"].sum()

    # Convert year and month to datetime objects
    monthly_total.index = monthly_total.index.map(lambda x: datetime.datetime(x[0], x[1], 1))
    
    # Filter out years with no data
    valid_years = df["Year"].unique()
    monthly_total = monthly_total[monthly_total.index.year.isin(valid_years)]

    # Filter out years with no data
    valid_years = df["Year"].unique()
    monthly_total = monthly_total[monthly_total.index.year.isin(valid_years)]
    
    # Set the figure size to match HD1080 resolution (1920x1080)
    fig_width = 25  # inches
    fig_height = 10.8  # inches
    fig, ax = plt.subplots(figsize=(fig_width, fig_height))
    
    ax.plot(monthly_total.index, monthly_total.values, marker="o")
    ax.set_title("Monthly Electricity Expenses")
    ax.set_xlabel("Date")
    ax.set_ylabel("Total Expense")
    
    # Rotate x-axis labels for better readability
    plt.xticks(rotation=90)
    
    # Format x-axis tick labels to show only year and month (yyyy-mm)
    date_format = mpl_dates.DateFormatter('%Y-%m')
    ax.xaxis.set_major_formatter(date_format)
    
    # Ensure all x-axis ticks are displayed
    ax.xaxis.set_major_locator(plt.MaxNLocator(len(monthly_total.index)))
    
    canvas = FigureCanvasTkAgg(fig, master=line_chart_window)
    canvas_widget = canvas.get_tk_widget()
    canvas_widget.pack()

    canvas.draw()
'''

def visualize_heatmap():
    global heatmap_window
    if heatmap_window is not None:
        heatmap_window.destroy()

    heatmap_window = tk.Toplevel()
    heatmap_window.title("Welcome to Le's family check out this Heatmap Visualization")

    df = pd.read_csv(csv_filename)
    pivot_df = df.pivot_table(index="Year", columns="Month", values="Amount", aggfunc="sum")

    fig, ax = plt.subplots(figsize=(16, 9))  # Set the figure size with a 16:9 aspect ratio
    sns.heatmap(pivot_df, cmap="Reds", annot=True, fmt=".1f", linewidths=.5, ax=ax)
    ax.set_title("Monthly Electricity Expenses Heatmap")
    ax.set_xlabel("Month")
    ax.set_ylabel("Year")

    canvas = FigureCanvasTkAgg(fig, master=heatmap_window)
    canvas_widget = canvas.get_tk_widget()
    canvas_widget.pack()

    canvas.draw()

# Create the main window
window = tk.Tk()
window.title("Electricity Expenses Visualization")
window.geometry("600x400")  # Set the window size (width x height)

# Buttons to open a CSV file and visualize line chart or heatmap
'''open_button_line_chart = tk.Button(window, text="Open CSV and Visualize Line Chart", command=visualize_line_chart, height=10,width=30)
open_button_line_chart.pack(pady=20)'''

open_button_heatmap = tk.Button(window, text="Open CSV and Visualize Heatmap", command=visualize_heatmap,height=10, width=30)
open_button_heatmap.pack()

# Run the main event loop
window.mainloop()