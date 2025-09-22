import tkinter as tk
import random
import time

class NameDrawGUI:
    def __init__(self, filename, duration=1):
        with open(filename, 'r') as f:
            self.names = f.read().splitlines()
        self.duration = duration
        self.previous_names = set()
        self.root = tk.Tk()
        self.root.title('')
        self.canvas = tk.Canvas(self.root, width=800, height=600, bg='light grey')
        self.canvas.pack()
        self.texts = []
        self.draw_names()
        self.root.mainloop()

    def draw_names(self):
        if len(self.previous_names) == len(self.names):
            return
        self.canvas.delete(tk.ALL)
        self.texts = []
        while len(self.texts) < 40:
            name = random.choice(list(set(self.names) - self.previous_names))
            self.previous_names.add(name)
            x, y = self.get_random_pos()
            color = '#{0:06x}'.format(random.randint(0, 256**3))
            text = self.canvas.create_text(x, y, text=name, font=('OpenSansRegular', 15), fill=color)
            self.texts.append(text)
        for i in range(1000):
            self.move_names()
            self.canvas.update()
            time.sleep(0.02)
        name1, name2 = random.sample(list(self.previous_names), 2)
        self.canvas.delete(tk.ALL)
        self.canvas.create_text(400, 300, text=f"{name1} and {name2}", font=('OpenSansRegular', 30),fill='dark green')


    def move_names(self):
        for text in self.texts:
            dx = random.uniform(-5, 5)
            dy = random.uniform(-5, 5)
            self.canvas.move(text, dx, dy)

    def get_random_pos(self):
        x = random.randint(100, 700)
        y = random.randint(100, 500)
        return x, y

gui = NameDrawGUI("", duration=1)
