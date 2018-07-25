function [data_train, labels_train, data_test, labels_test] = load_preprocess_mnist()
%% TODO ensure this is consistent with common loaders
% assumes relative paths to the common directory
% assumes common directory on paty for access to load functions
% adds 1 to the labels to make them 1-indexed

data_train = loadMNISTImages('D:/Hoctap/MachineLearning/stanford_dl_ex-master/stanford_dl_ex-master/common/train-images-idx3-ubyte');
labels_train = loadMNISTLabels(['D:/Hoctap/MachineLearning/stanford_dl_ex-master/stanford_dl_ex-master/common/train-labels-idx1-ubyte']);
labels_train  = labels_train + 1;

data_test = loadMNISTImages('D:/Hoctap/MachineLearning/stanford_dl_ex-master/stanford_dl_ex-master/common/t10k-images-idx3-ubyte');
labels_test = loadMNISTLabels(['D:/Hoctap/MachineLearning/stanford_dl_ex-master/stanford_dl_ex-master/common/t10k-labels-idx1-ubyte']);
labels_test = labels_test + 1;

