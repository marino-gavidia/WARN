# WARN: Early Warning of Atrial Fibrillation Using Deep Learning

This repository contains the updated research code for predicting atrial fibrillation (AF) before onset from RR intervals using deep learning.

The project processes ECG-derived RR interval signals, generates recurrence plots, and trains a neural network to identify patterns associated with imminent AF episodes. This repository corresponds to the codebase aligned with the final peer-reviewed publication.

## Publication

If you use this code, please cite:

Gavidia, M., Zhu, H., Montanari, A. N., Fuentes, J., Cheng, C., Dubner, S., et al.  
**Early Warning of Atrial Fibrillation Using Deep Learning**.  
*Patterns*, 2024.  
DOI: 10.1016/j.patter.2024.100970

## Data

This repository includes a representative group of patients from the open-source [PAF Prediction Challenge Database](https://physionet.org/content/afpdb/1.0.0/) on PhysioNet for testing purposes.

- **Test set:** Available at [Zenodo](https://doi.org/10.5281/zenodo.10815811)  
- **Training and validation sets:** Access can be requested from the data providers as described in the publication  
- Labels for the test data are included in the `data` folder

## Dependencies

This code was tested with:
- Python 3.9.12
- TensorFlow 2.8
- MATLAB R2020a

## Project structure

- `data_processing.m`  
  Processes ECG data, extracts RR intervals, generates recurrence plots, and assigns labels.

- `train.py`  
  Trains the deep learning model.

- `main_predictions.py`  
  Runs inference on test data and visualizes prediction outputs.

## Usage

1. Prepare the data as described above  
2. Run the MATLAB preprocessing script: `data_processing.m`  
3. Train the model with: `python train.py`  
4. Run predictions with: `python main_predictions.py`

## Summary

The goal of this project is to provide an early warning system for atrial fibrillation using heart rhythm dynamics, with a focus on clinically meaningful prediction ahead of AF onset.
