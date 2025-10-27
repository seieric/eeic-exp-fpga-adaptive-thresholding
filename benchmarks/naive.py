import cv2
import sys
import time
import numpy as np

# 設定定数
BLOCK_SIZE = 3  # 3x3のカーネル
C = 2  # 平均値から引く定数


def adaptive_thresholding_naive(input_path, output_path):
    # 1. 画像の読み込み (グレースケール)
    src = cv2.imread(input_path, cv2.IMREAD_GRAYSCALE)

    if src is None:
        print(f"Error: Could not open or find the image: {input_path}", file=sys.stderr)
        sys.exit(1)

    # 2. Adaptive Thresholdingの適用と時間計測

    elapsed_time_secs = []
    for i in range(100):
        start_time = time.time()
        dst = adaptive_threshold(src)
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


def adaptive_threshold(image: np.ndarray) -> np.ndarray:
    """OpenCVのADAPTIVE_THRESH_MEAN_Cをほぼ純粋Pythonで実装したもの。
    numpyの関数をほぼ使わず、境界処理はループ内で行う。
    """
    assert image.ndim == 2, "image must be 2D"
    kernel_size = 3
    C = 2

    height, width = image.shape
    r = kernel_size // 2

    # 出力配列（初期値ゼロ）
    image_binary = np.zeros((height, width), dtype=np.uint8)

    # 各画素について局所平均を求める
    for i in range(height):
        for j in range(width):
            sum_val = 0.0
            count = 0

            # カーネル内の画素を走査
            for dy in range(-r, r + 1):
                for dx in range(-r, r + 1):
                    y = i + dy
                    x = j + dx

                    # パディング: 範囲外の場合は端の画素を参照
                    if y < 0:
                        y = 0
                    elif y >= height:
                        y = height - 1
                    if x < 0:
                        x = 0
                    elif x >= width:
                        x = width - 1

                    sum_val += float(image[y, x])
                    count += 1

            mean_val = sum_val / count

            # しきい値判定
            if float(image[i, j]) > (mean_val - C):
                image_binary[i, j] = 255

    return image_binary


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            f"Usage: python {sys.argv[0]} <InputImageFilePath> <OutputImageFilePath>",
            file=sys.stderr,
        )
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    adaptive_thresholding_naive(input_file, output_file)
