import sys
from PIL import Image

GAP = 10
GAP_COLOR = "black"
NAME = "screenshots.png"

images = [Image.open(path) for path in sys.argv[1:]]

width, height = images[0].size
total_width = width * len(images) + GAP * (len(images) - 1)

result = Image.new(
	"RGB",
	(total_width, height),
	GAP_COLOR
)

for i, image in enumerate(images):
	result.paste(image, ((width + GAP) * i, 0))

result.save(NAME)

print(f"Saved: {NAME}")