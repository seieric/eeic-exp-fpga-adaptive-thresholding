# Adaptive Thresholding on FPGA (DE10-Standard)

## Overview

This project implements an adaptive thresholding algorithm on an FPGA (DE10-Standard board) using Verilog HDL. The design utilizes a box filter to compute local thresholds for binarizing grayscale images.

## Results

| Git tag | Date | Fmax (pll) / MHz | Fmax (VGA_Ctrl) / MHz | ALMs needed | Cycles needed | Changelog |
| --- | --- | --- | --- | --- | --- | --- |
| v1.0 | 2025/10/23 | 58.49 | 198.33 | 275 | - |  |
| v1.1 | 2025/10/23 | 58.89 | 189.93 | 274 | - | しきい値メモリのwrenを廃止 |
| v1.2 | 2025/10/23 | 58.44 | 185.32 | 266 | - | カーネル座標計算における除算を置換 |
| v1.3 | 2025/10/23 | 87.66 | 199.96 | 220 | - | 平均値計算における除算を乗算とシフト演算で近似 |
| v2.0 | 2025/10/23 | 96.4 | 204.96 | 174 | - | しきい値メモリを使わずに直接2値化を行う |
| v3.0 | 2025/10/27 | 87.56 | 186.08 | 419 | - | 並列化（並列数4） |
| v3.1 | 2025/10/27 | 88 | 195.89 | 452 | 163845 | 処理に要するサイクル数を7セグLEDに表示 |
| v3.2 | 2025/10/27 | 97.66 | 192.31 | 283 | 327683 | 並列化（並列数2） |
| v3.3 | 2025/10/27 | 94.54 | 177.84 | 207 | 655362 | 並列化（並列数1） |
| v3.4 | 2025/10/27 | 72.52 | 187.16 | 792 | 93648 | 並列化（並列数7）・vramを1bitに |
| v3.5 | 2025/10/27 | 75.53 | 195.77 | 971 | 93648 | 並列化（並列数7）・vramを8bitに戻す |
| v3.6 | 2025/10/27 | 68.68 | 204.25 | 1057 | 93648 | overflow, underflowを防ぐ |
