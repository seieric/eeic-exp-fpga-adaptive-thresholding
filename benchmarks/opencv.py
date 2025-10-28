import cv2
import sys
import time
import numpy as np


def adaptive_thresholding_opencv(input_path, output_path):
    # 1. 画像の読み込み (グレースケール)
    src = cv2.imread(input_path, cv2.IMREAD_GRAYSCALE)

    if src is None:
        print(f"Error: Could not open or find the image: {input_path}", file=sys.stderr)
        sys.exit(1)

    # 2. Adaptive Thresholdingの適用と時間計測
    elapsed_time_secs = []
    for i in range(100):
        start_time = time.time()
        dst = cv2.adaptiveThreshold(
            src,
            255,
            cv2.ADAPTIVE_THRESH_MEAN_C,  # 平均値ベース
            cv2.THRESH_BINARY,
            3,  # カーネルサイズ
            2,  # C
        )
        end_time = time.time()
        elapsed_time_sec = end_time - start_time
        elapsed_time_secs.append(elapsed_time_sec)

    print(
        f"Time: mean: {np.mean(elapsed_time_secs):.6f} secs",
        f"std: {np.std(elapsed_time_secs):.6f} secs",
        f"min: {np.min(elapsed_time_secs):.6f} secs",
        f"max: {np.max(elapsed_time_secs):.6f} sec",
    )

    # 3. 画像の保存
    if not cv2.imwrite(output_path, dst):
        print(f"Error: Could not save the image: {output_path}", file=sys.stderr)
        sys.exit(1)

    print(f"Successfully processed and saved to: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            f"Usage: python {sys.argv[0]} <InputImageFilePath> <OutputImageFilePath>",
            file=sys.stderr,
        )
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    adaptive_thresholding_opencv(input_file, output_file)
