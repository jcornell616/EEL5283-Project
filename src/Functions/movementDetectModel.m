function auroc = movementDetectModel(X, Y)
num_trial = length(Y);

Indx = randperm(num_trial);
% trueACCM = Yaccm(Indx,:);
%nF = size(Xfeatures,3); % number of features
% train set
ntrainTrial = ceil(num_trial/2); % number of training trials
ntestTrial = length(Indx)-ntrainTrial;
clear trainX; clear trainY; clear testX; clear testY;
trainX = [];trainY = [];testX = [];testY = [];

for i = 1:ntrainTrial
    
    trainX = [trainX, X{Indx(i)}']; %numtrials x fft data points x 5 bands
    trainY = [trainY, Y{Indx(i)}']; %numtrials x fft data points
   % keyboard
end
% Test set
for i = (ntrainTrial+1):num_trial
    testX = [testX, X{Indx(i)}']; %numtrials x fft data points x 5 bands
    testY = [testY, Y{Indx(i)}']; %numtrials x fft data points
end


% classification model
clear ldaModel;
ldaModel = fitcdiscr(trainX',trainY');
%% model test
clear Ypred; clear scorePred; clear errlda;
[Ypred,scorePred,~] = predict(ldaModel,testX');
errlda = sum( Ypred~=testY)./length(testY);
%keyboard;
clear X; clear Y; clear T; clear auc;
[dummyX,dummyY,dummyT,auroc] = perfcurve(testY,scorePred(:,2),'1');

end
