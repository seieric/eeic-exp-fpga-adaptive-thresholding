import sys
import numpy as np
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


def thresholds_to_verilog_hex(image_path, output_path):
    # Open the image and convert to grayscale
    pil_img = Image.open(image_path).convert("L")
    width, height = pil_img.size

    img = np.array(pil_img, dtype=np.float32)

    padded_img = np.pad(img, pad_width=1, mode="edge")

    # Prepare an array to hold the threshold values
    thresholds = np.zeros((height, width), dtype=np.uint8)

    # Calculate the mean of the 3x3 neighborhood for each pixel
    for i in range(height):
        for j in range(width):
            neighborhood = padded_img[i : i + 3, j : j + 3]
            mean_value = np.mean(neighborhood)
            thresholds[i, j] = int(mean_value)

    # Write threshold values in hex format
    with open(output_path, "w") as f:
        for i in range(height):
            for j in range(width):
                threshold = thresholds[i, j] & 0xFF
                f.write(f"{threshold:02X}\n")

    print(f"Threshold hex file saved to {output_path}")


def main():
    if len(sys.argv) != 3:
        print(
            "Usage: python convert_to_iverilog_hex.py <input_image> <output_hex_file>"
        )
        sys.exit(1)
    thresholds_to_verilog_hex(sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
