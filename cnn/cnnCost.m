function [cost, grad, preds] = cnnCost(theta,images,labels,numClasses,...
                                filterDim,numFilters,poolDim,pred)
% Calcualte cost and gradient for a single layer convolutional
% neural network followed by a softmax layer with cross entropy
% objective.
%                            
% Parameters:
%  theta      -  unrolled parameter vector
%  images     -  stores images in imageDim x imageDim x numImages
%                array
%  numClasses -  number of classes to predict
%  filterDim  -  dimension of convolutional filter                            
%  numFilters -  number of convolutional filters
%  poolDim    -  dimension of pooling area
%  pred       -  boolean only forward propagate and return
%                predictions
%
%
% Returns:
%  cost       -  cross entropy cost
%  grad       -  gradient with respect to theta (if pred==False)
%  preds      -  list of predictions for each example (if pred==True)


if ~exist('pred','var')
    pred = false;
end;

imageDim = size(images,1); % height/width of image
numImages = size(images,3); % number of images

%% Reshape parameters and setup gradient matrices

% Wc is filterDim x filterDim x numFilters parameter matrix
% bc is the corresponding bias

% Wd is numClasses x hiddenSize parameter matrix where hiddenSize
% is the number of output units from the convolutional layer
% bd is corresponding bias
[Wc, Wd, bc, bd] = cnnParamsToStack(theta,imageDim,filterDim,numFilters,...
                        poolDim,numClasses);

% Same sizes as Wc,Wd,bc,bd. Used to hold gradient w.r.t above params.
Wc_grad = zeros(size(Wc));
Wd_grad = zeros(size(Wd));
bc_grad = zeros(size(bc));
bd_grad = zeros(size(bd));

%%======================================================================
%% STEP 1a: Forward Propagation
%  In this step you will forward propagate the input through the
%  convolutional and subsampling (mean pooling) layers.  You will then use
%  the responses from the convolution and pooling layer as the input to a
%  standard softmax layer.

%% Convolutional and (mean) pooling Layer
%  For each image and each filter, convolve the image with the filter, add
%  the bias and apply the sigmoid nonlinearity.  Then subsample the 
%  convolved activations with mean pooling.  Store the results of the
%  convolution in activations and the results of the pooling in
%  activationsPooled.  You will need to save the convolved activations for
%  backpropagation.
convDim = imageDim-filterDim+1; % dimension of convolved output
outputDim = (convDim)/poolDim; % dimension of subsampled output


% convDim x convDim x numFilters x numImages tensor for storing activations
activations = zeros(convDim,convDim,numFilters,numImages);

%%% MY CODE HERE %%%
% Here we perform convolution
for imageNum = 1 : numImages
    for filterNum = 1 : numFilters
        filter = Wc(:,:, filterNum);
        im = squeeze(images(:,:,imageNum));
        
        % Flip the feature matrix because of the definition of convolution
        filter = rot90(squeeze(filter),2);
        
        activations(:,:,filterNum, imageNum) = sigmoid(conv2(im,filter,'valid') + bc(filterNum));          
    end
end

% activations = cnnConvolve(filterDim, 
%%% MY CODE HERE %%%

% outputDim x outputDim x numFilters x numImages tensor for storing
% subsampled activations
activationsPooled = zeros(outputDim,outputDim,numFilters,numImages);

%%% MY CODE HERE %%%
% Here we perform mean pooling
mask = ones(poolDim,poolDim);
% The averaging is done in the mask
mask = mask ./ size(mask(:),1);
idx = 1 : poolDim : convDim;
for imageNum = 1 : numImages
    for filterNum = 1 : numFilters
        % Convolution        
        mask = rot90(squeeze(mask),2);
        convolved = conv2(activations(:,:, filterNum, imageNum),mask,'valid');               
        % Subsampling
        activationsPooled(:, :, filterNum, imageNum) = convolved(idx, idx);                 
    end
end
%%% MY CODE HERE %%%

% Reshape activations into 2-d matrix, hiddenSize x numImages,
% for Softmax layer
activationsPooled = reshape(activationsPooled,[],numImages);

%% Softmax Layer
%  Forward propagate the pooled activations calculated above into a
%  standard softmax layer. For your convenience we have reshaped
%  activationPooled into a hiddenSize x numImages matrix.  Store the
%  results in probs.

% numClasses x numImages for storing probability that each image belongs to
% each class.
probs = zeros(numClasses,numImages);

%%% MY CODE HERE %%%

temp = exp(bsxfun(@plus, Wd * activationsPooled, bd));
sumTemp = sum(temp,1);
probs = bsxfun(@rdivide, temp, sumTemp);


%%% MY CODE HERE %%%
%%======================================================================
%% STEP 1b: Calculate Cost
%  In this step you will use the labels given as input and the probs
%  calculate above to evaluate the cross entropy objective.  Store your
%  results in cost.

cost = 0; % save objective into cost

%%% MY CODE HERE %%%
groundTruth = sparse(labels,1 : numImages,1,numClasses, numImages); 
logged = groundTruth .* log(probs);


cost = -1 * sum(logged(:)) ;
cost = cost / numImages;
%%% MY CODE HERE %%%

% Makes predictions given probs and returns without backproagating errors.
if pred
    [~,preds] = max(probs,[],1);
    preds = preds';
    grad = 0;
    return;
end;

%%======================================================================
%% STEP 1c: Backpropagation
%  Backpropagate errors through the softmax and convolutional/subsampling
%  layers.  Store the errors for the next step to calculate the gradient.
%  Backpropagating the error w.r.t the softmax layer is as usual.  To
%  backpropagate through the pooling layer, you will need to upsample the
%  error with respect to the pooling layer for each filter and each image.  
%  Use the kron function and a matrix of ones to do this upsampling 
%  quickly.

%%% MY CODE HERE %%%
% delta_Softmax = zeros(numClasses,1);
delta_Softmax = zeros(numClasses, numImages);
delta_Softmax = -1 * (groundTruth - probs);

delta_convolution = zeros(convDim, convDim, numFilters, numImages);

for imageNum = 1 : numImages   
    delta_pool = reshape(Wd' * delta_Softmax(:,imageNum),outputDim, outputDim,numFilters);  
    for filterNum = 1 : numFilters        
        delta_convolution(:,:,filterNum, imageNum) = (1/poolDim^2) * ...
            kron(delta_pool(:,:,filterNum),ones(poolDim)) .* activations(:,:,filterNum, imageNum) ...
            .* (1 - activations(:,:, filterNum, imageNum));        
    end
end
%%% MY CODE HERE %%%

%%======================================================================
%% STEP 1d: Gradient Calculation
%  After backpropagating the errors above, we can use them to calculate the
%  gradient with respect to all the parameters.  The gradient w.r.t the
%  softmax layer is calculated as usual.  To calculate the gradient w.r.t.
%  a filter in the convolutional layer, convolve the backpropagated error
%  for that filter with each image and aggregate over images.

%%% MY CODE HERE %%%
for imageNum = 1 : numImages
    Wd_grad = Wd_grad + delta_Softmax(:,imageNum) * activationsPooled(:,imageNum)';
end
bd_grad = sum(delta_Softmax,2);

for filterNum = 1 : numFilters
    for imageNum = 1 : numImages    
        im = images(:,:,imageNum);        
        filter = rot90(squeeze(delta_convolution(:,:,filterNum, imageNum)),2);
        Wc_grad(:,:,filterNum) = Wc_grad(:,:,filterNum) + conv2(im,filter,'valid');
        selected = delta_convolution(:,:,filterNum,imageNum);
        bc_grad(filterNum,:) = bc_grad(filterNum,:) + sum(selected(:));
    end 
end

Wc_grad = Wc_grad ./ numImages;
bc_grad = bc_grad ./ numImages;
Wd_grad = Wd_grad ./ numImages;
bd_grad = bd_grad ./ numImages;

%%% MY CODE HERE %%%
%% Unroll gradient into grad vector for minFunc
grad = [Wc_grad(:) ; Wd_grad(:) ; bc_grad(:) ; bd_grad(:)];

end
