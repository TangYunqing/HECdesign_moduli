function [ModelB, validationRMSE] = trainModelB(trainingData)
% returns a trained regression model and its RMSE. This code recreates the
% model trained in Regression Learner app. Use the generated code to
% automate training the same model with new data, or to learn how to
% programmatically train models.
%
%  Input:
%      trainingData: a table containing the same predictor and response
%       columns as imported into the app.
%
%  Output:
%      ModelB: a struct containing the trained regression model for bulk 
%      modulus. The struct contains various fields with information about
%      the trained model.
%
%      ModelB.predictFcn: a function to make predictions of bulk modulus 
%      on new data.
%
%      validationRMSE: a double containing the RMSE. In the app, the
%       History list displays the RMSE for each model.
%
% Use the code to train the model with new data. To retrain your model,
% call the function from the command line with your original data or new
% data as the input argument trainingData.
%
% For example, to retrain a regression model trained with the original data
% set T, enter:
%   [ModelB, validationRMSE] = trainModelB(T)
%
% To make predictions with the returned 'ModelB' on new data T2, use
%   fitB = ModelB.predictFcn(T2)
%
% T2 must be a table containing at least the same predictor columns as used
% during training. For details, enter:
%   ModelB.HowToPredict

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'SBO', 'NETM', 'BL'};
predictors = inputTable(:, predictorNames);
response = inputTable.B;
isCategoricalPredictor = [false, false, false];

% Train a regression model
% This code specifies all the model options and trains the model.
regressionGP = fitrgp(...
    predictors, ...
    response, ...
    'BasisFunction', 'constant', ...
    'KernelFunction', 'exponential', ...
    'Standardize', true);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
gpPredictFcn = @(x) predict(regressionGP, x);
ModelB.predictFcn = @(x) gpPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
ModelB.RequiredVariables = {'BL', 'NETM', 'SBO'};
ModelB.RegressionGP = regressionGP;
ModelB.About = 'This struct is a trained model exported from Regression Learner R2020a.';
ModelB.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  Mfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''ModelB'', replacing "M"with the name of predicted modulus, e.g. "B". \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.');


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'SBO', 'NETM', 'BL'};
predictors = inputTable(:, predictorNames);
response = inputTable.B;
isCategoricalPredictor = [false, false, false];

% Perform cross-validation
partitionedModel = crossval(ModelB.RegressionGP, 'KFold', 10);

% Compute validation predictions
validationPredictions = kfoldPredict(partitionedModel);

% Compute validation RMSE
validationRMSE = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));
