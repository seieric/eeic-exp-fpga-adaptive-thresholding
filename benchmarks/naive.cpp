#include <iostream>
#include <string>
#include <vector>
#include <cmath>
#include <iomanip>
#include <opencv2/opencv.hpp>
#include <algorithm> // std::min, std::max のために必要

using namespace cv;
using namespace std;

// 設定定数
const int C = 2; // 平均値から引く定数
const int KERNEL_SIZE = 3;
const int KERNEL_HALF = KERNEL_SIZE / 2; // 1

// 境界を超えた座標を最も近い境界値にクリッピングする関数
int clip(int val, int min_val, int max_val) {
    return std::max(min_val, std::min(val, max_val));
}

int main(int argc, char** argv) {
    // 1. 引数確認
    if (argc != 3) {
        cerr << "Usage: " << argv[0] << " <InputImageFilePath> <OutputImageFilePath>" << endl;
        return 1;
    }

    string input_path = argv[1];
    string output_path = argv[2];

    // 2. 画像をグレースケールで読み込み
    Mat src = imread(input_path, IMREAD_GRAYSCALE);

    if (src.empty()) {
        cerr << "Error: Could not open or find the image: " << input_path << endl;
        return 1;
    }

    // 3. 出力用画像の準備
    Mat dst = Mat::zeros(src.size(), src.type());

    // 時間計測用ベクター
    vector<double> execution_times;
    
    cout << "Running boundary-clipped 3x3 adaptive thresholding 100 times..." << endl;

    // 100回実行のループ
    for (int run = 0; run < 100; run++) {
        // 時間計測開始
        int64 start = getTickCount();

        // 4. 境界処理対応の3x3適応的二値化の実装
        
        const int rows = src.rows;
        const int cols = src.cols;
        const int max_y = rows - 1;
        const int max_x = cols - 1;

        // 画像の全ピクセルを走査
        for (int y = 0; y < rows; ++y) {
            // 出力画像ポインタ
            uchar* p_dst = dst.ptr<uchar>(y);

            for (int x = 0; x < cols; ++x) {
                
                // 3x3カーネル内の9つの画素値を直接合計 (ループ不使用)
                long long sum = 0;
                
                // 9つの画素位置を計算し、境界でクリッピングする
                
                // (y-1, x-1) -> (y+1, x+1) の9つの座標を定義
                
                // 上の行 (y-1)
                int y_prev = clip(y - 1, 0, max_y);
                sum += src.at<uchar>(y_prev, clip(x - 1, 0, max_x));
                sum += src.at<uchar>(y_prev, clip(x, 0, max_x));
                sum += src.at<uchar>(y_prev, clip(x + 1, 0, max_x));
                
                // 現在の行 (y)
                int y_curr = clip(y, 0, max_y); // y は常に境界内なのでこれは不要だが、統一性のため
                sum += src.at<uchar>(y_curr, clip(x - 1, 0, max_x));
                sum += src.at<uchar>(y_curr, clip(x, 0, max_x)); // 中央の画素
                sum += src.at<uchar>(y_curr, clip(x + 1, 0, max_x));
                
                // 下の行 (y+1)
                int y_next = clip(y + 1, 0, max_y);
                sum += src.at<uchar>(y_next, clip(x - 1, 0, max_x));
                sum += src.at<uchar>(y_next, clip(x, 0, max_x));
                sum += src.at<uchar>(y_next, clip(x + 1, 0, max_x));

                // 平均値の計算 (カーネルサイズ 3x3 = 9)
                double mean = (double)sum / 9.0;
                
                // 閾値の決定: T = 平均値 - C
                double threshold_val = mean - C;

                // 二値化処理 (THRESH_BINARY)
                if (src.at<uchar>(y, x) > threshold_val) {
                    p_dst[x] = 255;
                } else {
                    p_dst[x] = 0;
                }
            }
        }

        // 時間計測終了
        int64 end = getTickCount();
        
        double elapsed_time_sec = (double)(end - start) / getTickFrequency();
        execution_times.push_back(elapsed_time_sec);
    }

    // 5. 実行時間の統計計算
    double sum = 0.0;
    double min_time = execution_times[0];
    double max_time = execution_times[0];
    
    for (double time : execution_times) {
        sum += time;
        if (time < min_time) min_time = time;
        if (time > max_time) max_time = time;
    }
    
    double mean = sum / 100.0;
    
    // 標準偏差の計算
    double variance_sum = 0.0;
    for (double time : execution_times) {
        variance_sum += (time - mean) * (time - mean);
    }
    double std_dev = sqrt(variance_sum / 100.0);
    
    // 6. 統計情報の表示
    cout << "\n=== Execution Time Statistics (100 runs) ===" << endl;
    cout << "Mean: " << fixed << setprecision(6) << mean << " seconds" << endl;
    cout << "Std:  " << fixed << setprecision(6) << std_dev << " seconds" << endl;
    cout << "Min:  " << fixed << setprecision(6) << min_time << " seconds" << endl;
    cout << "Max:  " << fixed << setprecision(6) << max_time << " seconds" << endl;

    // 7. 画像の保存
    if (!imwrite(output_path, dst)) {
        cerr << "Error: Could not save the image: " << output_path << endl;
        return 1;
    }

    cout << "Successfully processed and saved to: " << output_path << endl;
    return 0;
}