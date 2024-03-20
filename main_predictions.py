import tensorflow as tf
import h5py
import numpy as np
import pandas as pd
import os
import math
import matplotlib.pyplot as plt

def predict_and_plot(model, data_folder, output_folder, plot_folder, batch_size=100):
    """
    Performs prediction on test data and plots the results.

    Args:
    - model: Loaded TensorFlow model for prediction.
    - data_folder: Directory containing the test data files.
    - output_folder: Directory to save prediction results.
    - plot_folder: Directory to save plots of predictions.
    - batch_size: Batch size for predictions.
    """

    test_files = os.listdir(data_folder)
    
    # Ensure output and plot directories exist
    os.makedirs(output_folder, exist_ok=True)
    os.makedirs(plot_folder, exist_ok=True)
    
    for name_file in test_files:
        print(f"Processing {name_file}")
        with h5py.File(os.path.join(data_folder, name_file), 'r') as input_file:
            x = tf.convert_to_tensor(input_file["x"][:], np.uint8)
            y = input_file['y'][:, 0]
        
        len0 = len(y)
        indexes = range(math.ceil(len0 / batch_size))
        results = []

        for k in indexes:
            kk = list(range(k * batch_size, min((k + 1) * batch_size, len0)))
            batch_s = len(kk)
            img = tf.gather(x, kk)
            output = model.predict(img, batch_size=batch_s)
            label = y[kk]

            for vv, output_v in enumerate(output):
                results.append([output_v[0], output_v[1], output_v[2], int(label[vv])])

        # Create DataFrame and save to CSV
        df = pd.DataFrame(results, columns=['pre_af', 'AF', 'SR', "Label"])
        df.to_csv(os.path.join(output_folder, f"predict_{name_file}_.csv"), index=False)

        # Calculate and plot P_danger
        p_danger = 1 - df['SR'].rolling(window=7, min_periods=1).mean()
        time_seconds = np.arange(len(p_danger)) * 15 / 60  # Assuming 15 sec per sample

        plt.figure(figsize=(12, 8))
        plt.plot(time_seconds, p_danger, marker='o', linestyle='-', color='black', label='P_danger')
        plt.plot(time_seconds, df["Label"], marker='x', linestyle='--', color='red', label='AF')
        plt.title(f'WARN: {name_file.split(".")[0]}')
        plt.xlabel('Time (minutes)')
        plt.ylabel('P_danger')
        plt.legend()
        plt.grid(True)
        plt.savefig(os.path.join(plot_folder, f"{name_file.split('.')[0]}.jpeg"))
        plt.close()

if __name__ == '__main__':
    # Parameters
    batch_size = 100
    data_folder = "rp_data/"
    output_folder = "predictions/"
    plot_folder = "p_danger_plots/"

    # Load model
    model = tf.keras.models.load_model("NN_weights/WEIGHTS.hdf5")

    # Predict and plot for each file
    predict_and_plot(model, data_folder, output_folder, plot_folder, batch_size)
