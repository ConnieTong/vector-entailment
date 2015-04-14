% Want to distribute this code? Have other questions? -> sbowman@stanford.edu
function [ trainDataset, testDatasetsCell, trainingLengths ] = LoadAllDatasets(wordMap, relationMap, hyperParams)
% Load and combine all of the training and test data.
% This is slow. And can probably be easily improved if it matters.

% trainFilenames: Load these files as training data.
% testFilenames: Load these files as test data.
% splitFilenames: Split these files into train and test data.

% relationIndices: An optional matrix with three rows, one each for 
% train/test/split, indicating which set of relations the dataset uses.

if hyperParams.sentimentMode
    loadFileFn = @LoadSentimentData;
else
    loadFileFn = @LoadEntailmentData;
end

if hyperParams.fragmentData
    trainDataset = hyperParams.trainFilenames;
else
    trainDataset = [];
end
testDatasets = {};
relationIndex = 1;

trainingLengths = [];

for i = 1:length(hyperParams.trainFilenames)
    Log(hyperParams.statlog, ['Loading training dataset ', hyperParams.trainFilenames{i}]);
    if isfield(hyperParams, 'relationIndices')
        relationIndex = hyperParams.relationIndices(1, i);
    end

    if ~hyperParams.fragmentData
        dataset = loadFileFn(hyperParams.trainFilenames{i}, wordMap, relationMap, ...
                                  hyperParams, false, relationIndex);
        trainDataset = [trainDataset; dataset];
        trainingLengths = [trainingLengths; length(dataset)];
    else
        loadFileFn(hyperParams.trainFilenames{i}, wordMap, relationMap, hyperParams, true, relationIndex);
    end
        
end

for i = 1:length(hyperParams.testFilenames)
    if isfield(hyperParams, 'relationIndices')
        relationIndex = hyperParams.relationIndices(2, i);
    else
        relationIndex = 1;
    end

    Log(hyperParams.statlog, ['Loading test dataset ', hyperParams.testFilenames{i}]);
    dataset = loadFileFn(hyperParams.testFilenames{i}, wordMap, relationMap, hyperParams, false, relationIndex);
    testDatasets = [testDatasets, {dataset}];
end

for i = 1:length(hyperParams.splitFilenames)
    if isfield(hyperParams, 'relationIndices')
        relationIndex = hyperParams.relationIndices(3, i);
    else
        relationIndex = 1;
    end

    Log(hyperParams.statlog, ['Loading split dataset ', hyperParams.splitFilenames{i}]);
    dataset = loadFileFn(hyperParams.splitFilenames{i}, wordMap, relationMap, hyperParams, false, relationIndex);

    lengthOfTestPortion = ceil(length(dataset) * hyperParams.testFraction);
    startOfTestPortion = 1 + (hyperParams.foldNumber - 1) * lengthOfTestPortion;
    endOfTestPortion = min(hyperParams.foldNumber * lengthOfTestPortion, length(dataset));
    
    testPortion = dataset(startOfTestPortion:endOfTestPortion);
    testDatasets = [testDatasets, {testPortion}];
    
    if ~(isfield(hyperParams, 'specialAndOrMode') && i > ((2 * hyperParams.specialAndOrMode) + 1))
        firstTrainPortion = dataset(1:(startOfTestPortion - 1));
        secondTrainPortion = dataset(endOfTestPortion + 1:length(dataset));
        trainPortion = [firstTrainPortion; secondTrainPortion];
        trainDataset = [trainDataset; trainPortion];
        trainingLengths = [trainingLengths; length(dataset)];
    else
        Log(hyperParams.statlog, ['Discarding train portion of split dataset ', hyperParams.splitFilenames{i}]);
    end
end

datasetNames = [hyperParams.testFilenames, hyperParams.splitFilenames];
testDatasetsCell = {datasetNames, testDatasets};