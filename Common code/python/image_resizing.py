import tkinter as tk
from tkinter import filedialog
from PIL import Image

class PhotoResizerGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Photo Resizer")
        self.root.geometry("400x200")
        self.root.resizable(False, False)

        self.input_button = tk.Button(self.root, text="Select Photos to Resize", command=self.choose_photos)
        self.input_button.pack(pady=80)

        self.output_folder = ""

        self.root.mainloop()

    def choose_photos(self):
        # Prompt user to select photos to resize
        filetypes = [("Image Files", "*.png *.jpg *.jpeg")]
        photos = filedialog.askopenfilenames(initialdir=".", title="Select Photos to Resize", filetypes=filetypes)

        # Prompt user to select output folder
        self.output_folder = filedialog.askdirectory(initialdir=".", title="Select Output Folder")

        # Resize and save each photo to the output folder
        for photo in photos:
            # Open the photo
            with Image.open(photo) as img:
                # Resize the photo to 150x150 pixels
                img = img.resize((150, 150))

                # Save the resized photo to the output folder
                filename = photo.split("/")[-1]  # Get the filename
                output_path = f"{self.output_folder}/{filename}"  # Construct output path
                img.save(output_path)

        # Display a message box when the resizing is complete
        tk.messagebox.showinfo("Photo Resizer", "Resizing complete!")

gui = PhotoResizerGUI()
