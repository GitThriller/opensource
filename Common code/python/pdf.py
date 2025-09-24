import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import tabula
import pandas as pd
import PyPDF2
import os
import re

class ANZBankStatementReader:
    def __init__(self, root):
        self.root = root
        self.root.title("ANZ Bank Statement Reader")
        self.root.geometry("800x600")
        
        self.file_path = tk.StringVar()
        self.df = None
        
        # UI Elements
        tk.Label(root, text="Select an ANZ PDF Bank Statement:").pack(pady=10)
        
        tk.Button(root, text="Browse", command=self.browse_file).pack(pady=5)
        tk.Entry(root, textvariable=self.file_path, width=70).pack(pady=5)
        
        tk.Button(root, text="Parse Statement", command=self.parse_statement, bg="lightblue").pack(pady=10)
        
        # Table to display results
        self.tree = ttk.Treeview(root, columns=("Date", "Description", "Debit", "Credit", "Balance"), show="headings", height=20)
        self.tree.heading("Date", text="Date")
        self.tree.heading("Description", text="Description")
        self.tree.heading("Debit", text="Debit")
        self.tree.heading("Credit", text="Credit")
        self.tree.heading("Balance", text="Balance")
        
        # Scrollbar for table
        scrollbar = ttk.Scrollbar(root, orient=tk.VERTICAL, command=self.tree.yview)
        self.tree.configure(yscroll=scrollbar.set)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=10, pady=10)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Status label
        self.status = tk.Label(root, text="Ready to parse ANZ statement...", fg="green")
        self.status.pack(pady=5)
    
    def browse_file(self):
        file = filedialog.askopenfilename(filetypes=[("PDF files", "*.pdf")])
        if file:
            self.file_path.set(file)
    
    def parse_statement(self):
        if not self.file_path.get():
            messagebox.showerror("Error", "Please select a PDF file first.")
            return
        
        try:
            self.status.config(text="Parsing ANZ statement... (This may take a moment)", fg="orange")
            self.root.update()
            
            # Try tabula for table extraction
            tables = tabula.read_pdf(self.file_path.get(), pages="all", multiple_tables=True, stream=True)
            
            if tables:
                # Concatenate all tables and clean
                self.df = pd.concat(tables, ignore_index=True)
                
                # Filter rows with ANZ date format (dd/mm/yy or dd/mm/yyyy)
                self.df = self.df.dropna()  # Drop empty rows
                self.df = self.df[self.df.astype(str).apply(lambda x: x.str.contains(r'\d{2}/\d{2}/\d{2,4}', na=False).any(), axis=1)]
                
                # ANZ-specific column mapping
                col_map = {}
                cols = self.df.columns.str.lower().str.strip()
                if 'date' in cols.str.cat(sep='|'):
                    col_map[self.df.columns[cols.str.contains('date')][0]] = 'Date'
                if 'description' in cols.str.cat(sep='|') or 'narration' in cols.str.cat(sep='|'):
                    col_map[self.df.columns[cols.str.contains('description|narration')][0]] = 'Description'
                if 'amount' in cols.str.cat(sep='|'):
                    col_map[self.df.columns[cols.str.contains('amount')][0]] = 'Amount'
                if 'balance' in cols.str.cat(sep='|') or 'running balance' in cols.str.cat(sep='|'):
                    col_map[self.df.columns[cols.str.contains('balance|running balance')][0]] = 'Balance'
                
                self.df = self.df.rename(columns=col_map)
                
                # Split 'Amount' into 'Debit' and 'Credit'
                if 'Amount' in self.df.columns:
                    self.df['Debit'] = self.df['Amount'].apply(lambda x: -x if x < 0 else 0)
                    self.df['Credit'] = self.df['Amount'].apply(lambda x: x if x > 0 else 0)
                    self.df = self.df.drop(columns=['Amount'])
                
                # Clean descriptions (remove extra spaces, ANZ-specific codes)
                if 'Description' in self.df.columns:
                    self.df['Description'] = self.df['Description'].str.replace(r'\s+', ' ', regex=True).str.strip()
                    self.df['Description'] = self.df['Description'].str.replace(r'(EFTPOS|BPAY|OSKO)\s*\d+', '', regex=True)
                
                # Select relevant columns
                avail_cols = ['Date', 'Description', 'Debit', 'Credit', 'Balance']
                self.df = self.df[[col for col in avail_cols if col in self.df.columns]]
                
                # Convert numeric columns
                for col in ['Debit', 'Credit', 'Balance']:
                    if col in self.df.columns:
                        self.df[col] = pd.to_numeric(self.df[col], errors='coerce')
                
                # Save to CSV
                csv_path = self.file_path.get().replace('.pdf', '_ANZ_parsed.csv')
                self.df.to_csv(csv_path, index=False)
                
            else:
                # Fallback to PyPDF2 for text extraction
                self.extract_text_fallback()
            
            self.display_results()
            self.status.config(text=f"Parsed successfully! Saved to {os.path.basename(csv_path)}", fg="green")
            
        except Exception as e:
            self.status.config(text=f"Error: {str(e)}", fg="red")
            messagebox.showerror("Error", f"Failed to parse: {str(e)}\nEnsure Java is installed for tabula or the PDF is text-based. For scanned PDFs, install Tesseract.")
    
    def extract_text_fallback(self):
        """Basic text extraction for non-table PDFs (less accurate)."""
        with open(self.file_path.get(), 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            text = ""
            for page in reader.pages:
                text += page.extract_text() + "\n"
        
        # ANZ-specific regex (dd/mm/yy or dd/mm/yyyy, description, amount, balance)
        pattern = r'(\d{2}/\d{2}/\d{2,4})\s+(.+?)\s+(-?[\d,]+\.\d{2})\s+(-?[\d,]+\.\d{2})'
        matches = re.findall(pattern, text)
        
        if matches:
            self.df = pd.DataFrame(matches, columns=['Date', 'Description', 'Amount', 'Balance'])
            # Split Amount into Debit/Credit
            self.df['Debit'] = self.df['Amount'].str.replace(',', '').astype(float).apply(lambda x: -x if x < 0 else 0)
            self.df['Credit'] = self.df['Amount'].str.replace(',', '').astype(float).apply(lambda x: x if x > 0 else 0)
            self.df = self.df.drop(columns=['Amount'])
            # Clean descriptions
            self.df['Description'] = self.df['Description'].str.replace(r'\s+', ' ', regex=True).str.strip()
            self.df['Description'] = self.df['Description'].str.replace(r'(EFTPOS|BPAY|OSKO)\s*\d+', '', regex=True)
        else:
            self.df = pd.DataFrame()
            self.status.config(text="No transactions found. PDF may be scanned—install Tesseract for OCR.", fg="orange")
    
    def display_results(self):
        # Clear table
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        if self.df is not None and not self.df.empty:
            for _, row in self.df.iterrows():
                self.tree.insert("", "end", values=(
                    row.get('Date', ''),
                    row.get('Description', '')[:50] + '...' if len(str(row.get('Description', ''))) > 50 else row.get('Description', ''),
                    f"${row.get('Debit', 0):,.2f}" if pd.notna(row.get('Debit')) else '',
                    f"${row.get('Credit', 0):,.2f}" if pd.notna(row.get('Credit')) else '',
                    f"${row.get('Balance', 0):,.2f}" if pd.notna(row.get('Balance')) else ''
                ))
        else:
            self.tree.insert("", "end", values=("", "No transactions extracted", "", "", ""))

if __name__ == "__main__":
    root = tk.Tk()
    app = ANZBankStatementReader(root)
    root.mainloop()