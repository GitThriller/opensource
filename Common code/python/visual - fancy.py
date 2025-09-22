import os
import pandas as pd
import plotly.graph_objects as go
import numpy as np

def read_csv_files(folder):
    df_list = []
    for filename in os.listdir(folder):
        if filename.endswith(".csv"):
            filepath = os.path.join(folder, filename)
            df = pd.read_csv(filepath)
            df_list.append(df)
    return pd.concat(df_list, ignore_index=True)


def visualize_with_sunburst(df):
    min_year = df['Year'].min()
    max_year = df['Year'].max()
    df_grouped = df.groupby(["Year", "Fee category"])["Amount"].sum().reset_index()
    
    labels = []
    parents = []
    values = []
    colors = []
    texts = []
    
    fee_categories = df_grouped["Fee category"].unique()
    color_map = {fee: f"hsl({i * 360 // len(fee_categories)}, 70%, 70%)" for i, fee in enumerate(fee_categories)}

    # Sort years as integers
    unique_years = np.unique(df['Year'].values)
    
    for year in unique_years:
        year_total = df_grouped[df_grouped["Year"] == year]["Amount"].sum()
        
        labels.append(str(year))
        parents.append("")
        values.append(year_total)
        colors.append("grey")
        texts.append("")  # No text for years

        for fee_cat in fee_categories:
            fee_amount = df_grouped.loc[(df_grouped["Year"] == year) & (df_grouped["Fee category"] == fee_cat), "Amount"].sum()
            percentage = (fee_amount / year_total) * 100 if year_total > 0 else 0
            
            labels.append(f"{fee_cat} {year}")
            parents.append(str(year))
            values.append(fee_amount)
            colors.append(color_map[fee_cat])
            texts.append(f"{percentage:.2f}%")
    
    fig = go.Figure(go.Sunburst(
        labels=labels,
        parents=parents,
        values=values,
        branchvalues="total",
        marker=dict(colors=colors),
        text=texts,
        textinfo='label+text',
    ))

    fig.update_layout(margin=dict(l=0, r=0, b=0, t=0), title="Yearly Expenses by Category")
    fig.show()


master_folder = ""
df = read_csv_files(master_folder)
visualize_with_sunburst(df)
