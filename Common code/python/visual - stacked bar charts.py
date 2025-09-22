import os
import pandas as pd
import matplotlib.pyplot as plt
import tkinter as tk
from tkinter import Tk, Button

# Read CSV files and create a unified DataFrame
def read_csv_files(folder):
    df_list = []
    for filename in os.listdir(folder):
        if filename.endswith(".csv"):
            filepath = os.path.join(folder, filename)
            df = pd.read_csv(filepath)
            df_list.append(df)
    return pd.concat(df_list, ignore_index=True)

# Create a global variable for the figure
visualization_figure = None

# Dynamic visualization based on the data
def visualize_data(df):
    global visualization_figure
    
    if visualization_figure is not None:
        # Clear the existing figure
        plt.close(visualization_figure)
    
    visualization_figure = plt.figure(figsize=(16, 9))  # Adjust the dimensions for 16:9 ratio

    # Dynamically determine the year range from the data
    min_year = df['Year'].min()
    max_year = df['Year'].max()
    all_years = range(min_year, max_year + 1)
    
    df_grouped = df.groupby(["Year", "Fee category"])["Amount"].sum().reset_index()
    fee_categories = df_grouped["Fee category"].unique()
    
    # Stacked bar chart
    bottom_values = {year: 0 for year in all_years}
    for fee_cat in fee_categories:
        amounts = []
        for year in all_years:
            amount = df_grouped.loc[(df_grouped["Year"] == year) & (df_grouped["Fee category"] == fee_cat), "Amount"].sum()
            amounts.append(amount)
            bottom_values[year] += amount
        plt.bar(all_years, amounts, bottom=[bottom_values[year] - amounts[i] for i, year in enumerate(all_years)], label=fee_cat)

    plt.xticks(all_years)
    plt.xlabel('Year')
    plt.ylabel('Total Amount')
    plt.title('Yearly Expenses by Category')

def show_visualization():
    df = read_csv_files(master_folder)
    visualize_data(df)
    plt.show()

# Directly specify the folder
master_folder = ""

root = Tk()
root.title("")

# Set the initial window size (width x height)
initial_window_size = "800x600"  # Adjust the dimensions as needed
root.geometry(initial_window_size)

# Create a button to trigger the visualization
visualize_button = Button(root, text="Stacked Bar Chart Visualization", command=show_visualization, height=10, width=30)
visualize_button.pack()

root.mainloop()
