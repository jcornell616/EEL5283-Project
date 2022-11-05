# EEL5283-Project

ReadMe will be used to set agendas and organize work.

## Proposal

Based on the feedback I give you on your pre-proposal, rewrite the proposal to include:

a) Background and Significance  

b) Preliminary studies  

c) Research Design and Methods 

d) Milestones, Metrics of Success and Timeline  

You should introduce the area of investigation, explain the “big picture” or significance of the specific 
problem that you will tackle, provide a list of the particular questions you intend to address in your 
experiments/simulation, and the methods you will use to conduct these experiments/simulations. It is very 
important to include all the details about how the data you will be working with has been/will be collected. 

Limit: 7 pages (not including references), Single spacing, one-inch margins, 12-pt font size Arial font. 

* Note: I think background/significance can just be copied from pre-proposal. We can add a quite a bit for the preliminary studies section from the papers weve found.

### Data acquisition:

* Data is provided by Dr. Oweiss's lab
* Data stored in spreadsheet, each trial must be hand selected to enable for processing
* MATLAB script used to process each enabled trial and organize/display neural data
* Two channels of LFP

### Pre-processing:

* Data will need to be filter (low pass with cutoff at 300 Hz)
* Data can be downsampled to reduce computational cost
* Dimensionality reduction probably won't be necessary due to low channel count

### Decoding:

* See papers for different decoding methods
* LFP is not spike-based but continuous-time signal
* Can either decode the pre-processed signal as-is, or do feature engineering to map to feature space
* Common technique is to look at powers of different frequency bands
* Can try KLMS on time-series signal
* Hyperparameter tuning will be based off which decoding methodology we use

### Evaluation:

* Use error between predicted accelerometer data and actual accelerometer data
* Should have some error benchmarks we want models to meet
* Should have benchmark for model-runtimes

### Timeline:
* Idk just make something up lmao
