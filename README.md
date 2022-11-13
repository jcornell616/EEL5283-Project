# EEL5283 Project

Brain-Computer Interfaces (BCIs) are an emerging technology for medical applications such as neural rehabilitation for disabled individuals. BCIs allow for the processing of neural signals to either transduce an action or provide a feedback stimulus to the brain. For our project, we will consider the processing of Local Field Potential (LFP) signals to predict hand and arm movement captured by accelerometer data. We can use this predictive model to translate the thought of movement and resultant LFP into a variety of outcomes such as movement of a prosthetic, control of a cursor on a screen, or interaction in a Virtual Reality (VR) space, among other applications of the produced accelerometer data.

These particular outcomes are significant for a variety of applications: A prosthetic could be developed for individuals who have lost a limb; a cursor control system could help someone who has lost control or limited control of their limbs; commercial applications such VR could be developed.

The aim of our project is to develop a BCI which will predict the desired movement (i.e. accelerometer data) given the corresponding LFP data. We will compare two approaches to decoding LFP data, the first using the spectral power of different frequency bands, and the other using the temporal dynamics. These will be decoded using a Convolutional Neural Network (CNN) and Kernel Least Mean Squares (KLMS) filter, respectively.

## TO-DO

- [ ] Get access to data and get MATLAB script running, perform exploratory data analysis
- [ ] Write modified MATLAB script that performs preprocessing (lowpass filtering, downsampling) and splits into training and test
- [ ] Write python script that perfoms CNN preprocessing (convert data into spectrograms)
- [ ] Perform hyperparameter tuning for KLMS and train model
- [ ] Perform hyperparameter tuning for CNN and train model
- [ ] Evaluate models using test set and compare performances
- [ ] Write final paper and prepare presentation

## Pipeline

![pipeline](/images/project_pipeline.jpg?raw=true)