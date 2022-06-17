import tensorflow as tf
import h5py
from tensorflow.keras.callbacks import ModelCheckpoint,EarlyStopping
from tensorflow.keras.optimizers import Adam
import random
import numpy as np
import pandas as pd
import os
from sklearn.utils import class_weight


def generator(Data_folder,files,batch_size): 
    last_file=1
    while True:
        if not(last_file):
            for current_file in files:
                with h5py.File(Data_folder+current_file, 'r') as hf:
                    x= tf.convert_to_tensor(hf["x"] )
                    y= tf.convert_to_tensor(hf["y"])
                for ii in range(int(len(y)/batch_size)):
                    yield x[ii*batch_size:(ii+1)*batch_size], y[ii*batch_size:(ii+1)*batch_size] 
            last_file=1
        else:
            random.shuffle(files)
            last_file=0            

def get_model():
    model = tf.keras.applications.EfficientNetV2S(
        include_top=False,
        weights=None,
        input_tensor=tf.keras.layers.Input(shape=(224, 224,1))
    )
    output = model.layers[-1].output
    output= tf.keras.layers.GlobalAveragePooling2D()(output)
    output= tf.keras.layers.Dropout(0.2)(output)
    output=tf.keras.layers.Dense(3, activation="softmax")(output)
    model_out = tf.keras.models.Model(inputs=model.input, outputs=output) 
    model_out.compile(Adam(learning_rate=lr), loss='categorical_crossentropy',metrics=['accuracy','AUC'])
    return model_out

def get_data(Data_folder,batch_size):
    
    files=np.array( os.listdir(Data_folder))
    indx=list( range(len(files)))
    random.shuffle(indx)
    split=int(len(indx) *0.6) 
    split2=int(len(indx) *0.8) 
    train=indx[:split]
    val=indx[split:split2] 
    test=indx[split2:] 
    Y = np.empty((0,3), int)
    Y_f=np.array([]);
    for data_input in files:
        with h5py.File(Data_folder+data_input, 'r') as hf:
            Y= np.append(Y, hf["y"][:],axis=0)
            Y_f=np.append(Y_f,  len(hf["y"][:]))      
    Y = np.argmax(Y, axis=1)
    class_weights=class_weight.compute_class_weight(class_weight='balanced',classes=np.unique(Y ),y=Y)
    d_class_weights = dict(enumerate(class_weights))
    train_f= np.array( files[train])
    val_f=np.array( files[val])
    test_f=np.array(files[test])
    step_train=int(sum(Y_f[train])/batch_size)
    step_val=int(sum(Y_f[val])/batch_size)
    return d_class_weights,train_f,val_f,test_f,step_train,step_val
     
    
if __name__ == '__main__':

    # # Parameters
    batch_size=8 
    epochs=100
    lr=1e-5
    n_split=5
    Data_folder="rp_data/"

    # # Optimization settings
    reduce_lr = tf.keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.1, patience=4, min_lr=1e-7)
    es = EarlyStopping(monitor='val_loss', mode='min', verbose=1, patience=8)
    checkpoint = ModelCheckpoint("WEIGHTS.hdf5", monitor='val_loss', verbose=1, save_best_only=True, mode='min')
    callbacks_list = [reduce_lr,checkpoint,es]   
    
    # # # Get Data
    d_class_weights,train_f,val_f,test_f,step_train,step_val = get_data(Data_folder,batch_size)


    # # # Train model    
    model= get_model()
    history_train=model.fit(
        generator(Data_folder,train_f,batch_size), steps_per_epoch=step_train,
        class_weight=d_class_weights,
        epochs=epochs,
        validation_data=generator(Data_folder,val_f,batch_size), validation_steps=step_val,
        callbacks=callbacks_list,
        verbose=2)
          
    # # # Load model
    model = tf.keras.models.load_model("WEIGHTS.hdf5")
    # # # Predict
    for name_file in test_f:
        input_file = h5py.File(Data_folder + name_file, 'r')   
        x= tf.convert_to_tensor(input_file["x"][:], np.uint8)
        output = np.array(model.predict(x,len(x)))
        pd.DataFrame(output).to_csv("predict_"+name_file+".csv",header=None, index=None)

    