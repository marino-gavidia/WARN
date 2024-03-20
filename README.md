# WARN: Early Warning of Atrial Fibrillation Using Deep Learning

This repository provides scripts and libraries for training a neural network model that can predict atrial fibrillation from RR intervals. Processing ECG data into RR intervals, generating recurrence plots (RP) and labelling them based on the presence of atrial fibrillation.

## Citation

Please cite the following work if you use this code or data:

Gavidia, M., Zhu, H., Montanari, A. N., Fuentes, J., Cheng, C., Dubner, S., ... & Goncalves, J.
Early Warning of Atrial Fibrillation Using Deep Learning. Patterns, 2024.


## Data

The data folder contains a group of patients from the open-source [PAF Prediction Challenge Database](https://physionet.org/content/afpdb/1.0.0/) on PhysioNet. This dataset can be used to test predictions, with the labels included in the data folder.

- **Test set:** Available at [Zenodo](https://doi.org/10.5281/zenodo.10815811). Labels are included in the `data` folder.
- **Training and Validation sets:** Access can be requested from Xiaoyun Yang at yangxiaoyun321@126.com.

## Getting Started

### Dependencies

- Python 3.9.12
- TensorFlow 2.8
- MATLAB R2020a

Ensure you have the above dependencies installed before proceeding with executing the program scripts.

### Executing Program

1. **Data Processing (`data_processing.m`):**
   - Generates data for training and testing.
   - Processes ECG signals to generate recurrence plots (RPs) and labels them for atrial fibrillation presence.

2. **Model Training (`train.py`):**
   - Script for training the neural network model.

3. **Making Predictions (`main_predictions.py`):**
   - Performs predictions on test data and visualizes the results.

## Usage Example

To train the model and make predictions, follow these steps:

1. Prepare your data according to the instructions in the Data section.
2. Run the data processing script in MATLAB: data_processing.m
3. Train the model with the training script: python train.py
4. Perform predictions and generate plots: python main_predictions.py

