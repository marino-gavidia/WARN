import tensorflow as tf
from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping, ReduceLROnPlateau
from tensorflow.keras.optimizers import Adam
import numpy as np
import os
import random
from sklearn.utils import class_weight
import h5py

def generator(data_folder, files, batch_size):
    """
    Generator for loading and yielding batches of data from HDF5 files.

    Args:
    - data_folder: Path to the folder containing the data files.
    - files: List of file names to include in the generator.
    - batch_size: Size of the batches to generate.

    Yields:
    - Batches of (x, y) where x is the input data and y is the label.
    """
    while True:
        random.shuffle(files)
        for current_file in files:
            with h5py.File(os.path.join(data_folder, current_file), 'r') as hf:
                x = tf.convert_to_tensor(hf["x"])
                y = tf.convert_to_tensor(hf["y"])
                for i in range(0, len(y), batch_size):
                    yield x[i:i+batch_size], y[i:i+batch_size]

def get_model(input_shape=(224, 224, 1), lr=1e-5):
    """
    Constructs and compiles the neural network model.

    Args:
    - input_shape: Shape of the input data.
    - lr: Learning rate for the optimizer.

    Returns:
    - Compiled TensorFlow model.
    """
    base_model = tf.keras.applications.EfficientNetV2S(
        include_top=False,
        weights=None,
        input_shape=input_shape
    )
    x = base_model.output
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    x = tf.keras.layers.Dropout(0.2)(x)
    predictions = tf.keras.layers.Dense(3, activation="softmax")(x)
    model = tf.keras.Model(inputs=base_model.input, outputs=predictions)
    model.compile(optimizer=Adam(learning_rate=lr),
                  loss='categorical_crossentropy',
                  metrics=['accuracy', 'AUC'])
    return model

def get_data(data_folder, batch_size):
    """
    Prepares the data for training, validation, and testing.

    Args:
    - data_folder: Path to the folder containing the data files.
    - batch_size: Batch size for data processing.

    Returns:
    - Dictionary of class weights.
    - Train, validation, and test file lists.
    - Step sizes for training and validation.
    """
    files = np.array(os.listdir(data_folder))
    np.random.shuffle(files)
    split = int(len(files) * 0.7)
    split2 = int(len(files) * 0.8)

    train_files = files[:split]
    val_files = files[split:split2]
    test_files = files[split2:]

    y = []
    for data_input in files:
        with h5py.File(os.path.join(data_folder, data_input), 'r') as hf:
            y.extend(np.argmax(hf["y"][:], axis=1))
    class_weights = class_weight.compute_class_weight(
        class_weight='balanced',
        classes=np.unique(y),
        y=y
    )
    d_class_weights = dict(enumerate(class_weights))

    step_train = sum(len(hf["y"]) for hf in (h5py.File(os.path.join(data_folder, f), 'r') for f in train_files)) // batch_size
    step_val = sum(len(hf["y"]) for hf in (h5py.File(os.path.join(data_folder, f), 'r') for f in val_files)) // batch_size

    return d_class_weights, train_files, val_files, test_files, step_train, step_val

if __name__ == '__main__':
    # Parameters
    batch_size = 8
    epochs = 100
    lr = 1e-5
    data_folder = "rp_data/"

    # Get Data
    d_class_weights, train_f, val_f, test_f, step_train, step_val = get_data(data_folder, batch_size)

    # Model & Training
    model = get_model(lr=lr)
    callbacks_list = [
        ReduceLROnPlateau(monitor='val_loss', factor=0.1, patience=4, min_lr=1e-7),
        ModelCheckpoint("NN_weights/WEIGHTS_new_training.hdf5", monitor='val_loss', save_best_only= True, 
        mode='min', verbose=1),
        EarlyStopping(monitor='val_loss', mode='min', patience=8, verbose=1)
    ]
    
    # Train the model
    history = model.fit(
        generator(data_folder, train_f, batch_size),
        steps_per_epoch=step_train,
        class_weight=d_class_weights,
        epochs=epochs,
        validation_data=generator(data_folder, val_f, batch_size),
        validation_steps=step_val,
        callbacks=callbacks_list,
        verbose=2
    )


