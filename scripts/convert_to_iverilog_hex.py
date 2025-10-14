import sys
from PIL import Image


def image_to_verilog_hex(image_path, output_path):
    # Open the image and convert to grayscale
    img = Image.open(image_path).convert("L")
    width, height = img.size

    # Get pixel data
    pixels = list(img.getdata())

    # Write pixel data in hex format
    with open(output_path, "w") as f:
        for i in range(height):
            for j in range(width):
                pixel = pixels[i * width + j] & 0xFF
                f.write(f"{pixel:02X}\n")

    print(f"Hex file saved to {output_path}")


def main():
    if len(sys.argv) != 3:
        print(
            "Usage: python convert_to_iverilog_hex.py <input_image> <output_hex_file>"
        )
        sys.exit(1)
    image_to_verilog_hex(sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
