from PIL import Image

class ZXFontRenderer:
    def __init__(self, char_width=8, char_height=8, chars_per_row=16,
                 fg_color=(255, 255, 255), bg_color=(0, 0, 0)):
        self.char_width = char_width
        self.char_height = char_height
        self.chars_per_row = chars_per_row
        self.fg = fg_color
        self.bg = bg_color
        self.data = None

    def load(self, filename):
        with open(filename, "rb") as f:
            self.data = f.read()
        return self

    def render(self, margin=0):
        if self.data is None:
            raise ValueError("No se ha cargado ninguna fuente")

        num_chars = len(self.data) // self.char_height
        rows = (num_chars + self.chars_per_row - 1) // self.chars_per_row

        img_width = self.chars_per_row * (self.char_width + margin) + margin
        img_height = rows * (self.char_height + margin) + margin

        img = Image.new("RGB", (img_width, img_height), self.bg)
        pixels = img.load()

        for idx in range(num_chars):
            base_x = (idx % self.chars_per_row) * (self.char_width + margin) + margin
            base_y = (idx // self.chars_per_row) * (self.char_height + margin) + margin

            for row in range(self.char_height):
                byte = self.data[idx * self.char_height + row]
                for bit in range(self.char_width):
                    if byte & (0x80 >> bit):
                        pixels[base_x + bit, base_y + row] = self.fg

        return img

    def save(self, output_png, margin=0):
        img = self.render(margin=margin)
        img.save(output_png)
        return output_png
