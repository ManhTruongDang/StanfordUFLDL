function [ cost, grad, pred_prob] = supervised_dnn_cost( theta, ei, data, labels, pred_only)
%SPNETCOSTSLAVE Slave cost function for simple phone net
%   Does all the work of cost / gradient computation
%   Returns cost broken into cross-entropy, weight norm, and prox reg
%        components (ceCost, wCost, pCost)

%% default values
po = false;
if exist('pred_only','var')
  po = pred_only;
end;

%% reshape into network
stack = params2stack(theta, ei);
numHidden = numel(ei.layer_sizes) - 1;
hAct = cell(numHidden+1, 1);
gradStack = cell(numHidden+1, 1);

%% forward prop
%%% YOUR CODE HERE %%%
if strcmp(ei.activation_fun,'logistic') 
    h = @(x) 1./ (1 + exp(x)); % Activation function
    gr = @(x) h(x) .* (1 - h(x)); % Derivative of the activation function 
end

K = numel(unique(labels));
err = cell(numel(ei.layer_sizes) + 1, 1);
for i = 1 : numel(ei.layer_sizes)   
    err{i} = zeros(size(stack{i}.b,1) , 1);
end
err{numel(ei.layer_sizes) + 1} = zeros(K,1);

J = 0; % Loss function
numData = size(data,2);


k = (1 : K)';
a = cell(numel(ei.layer_sizes), 1);
for l = 1 : numel(ei.layer_sizes)    
    a{l} = zeros(size(stack{l}.b)); 
    gradStack{l} = [];
    gradStack{l}.W = zeros(size(stack{l}.W));
    gradStack{l}.b = zeros(size(stack{l}.b));    
    hAct{l} = h;
    if l == numel(ei.layer_sizes)
        hAct{l} = @(x) softmax(x);
    end
    
end
numCorrect = 0;

for i = 1 : numData
    % Forward pass
    a{1} = data(:,i);    
    for l = 1 : numel(ei.layer_sizes)        
        z = stack{l}.W * a{l} + stack{l}.b;          
        if l < numel(ei.layer_sizes)
            a{l + 1} = h(z);        
        else
            a{l + 1} = exp(z); % Softmax function
            a{l + 1} = a{l + 1} ./ sum(a{l + 1});            
        end        
        %J = J - norm(stack{l}.W,'fro')^2;
    end
    % Prediction
    
    [~,prediction] =  max(a{numel(ei.layer_sizes) + 1});
    
    pred_prob(:,i) = a{numel(ei.layer_sizes) + 1};
    if po == false        
        numCorrect = numCorrect + (labels(i) == prediction );
    end
        
    
    if po == false
        J = J + log(a{numel(ei.layer_sizes) + 1}(labels(i))) ;        
    end
    % Backward pass
    l = numel(ei.layer_sizes) + 1;    
    if po == false
        
        err{l} = err{l} -((labels(i) == k) - a{numel(ei.layer_sizes) + 1} );      
%         for l = numel(ei.layer_sizes) : 1
%             if l > 1
%                 err{l} = -(stack{l}.W' * err{l + 1}) * gr(a{l}) ;
%             end
%             % Gradient for the weights and bias
%             gradStack{l}.W = gradStack{l}.W + err{l + 1} * a{l}';
%             gradStack{l}.b = gradStack{l}.b + err{l + 1};
%         end
    end
    %% compute weight penalty cost and gradient for non-bias terms
    
end

 if po
     ;
 else
               
        for l = numel(ei.layer_sizes) : - 1: 1
            
            if l > 1            
                
                err{l} = 0 -(stack{l}.W' * err{l + 1}) .* gr(a{l}) ;
            end
            fprintf('Shit!!!\n');
            % Gradient for the weights and bias
            gradStack{l}.W =  err{l + 1} * a{l}';
            gradStack{l}.b =  err{l + 1};
            l
            size(gradStack{l}.W)
            size(gradStack{l}.b)
%             gradStack{l}.W
%             gradStack{l}.b
        end
end


ceCost = J;
wCost = 0;
pCost = 0;
cost = ceCost + wCost + pCost;


%% return here if only predictions desired.
if po
    cost = -1; ceCost = -1; wCost = -1; numCorrect = -1;
    grad = [];  
    return;
end;

%% compute cost
%%% YOUR CODE HERE %%%

%% compute gradients using backpropagation
%%% YOUR CODE HERE %%%

%% compute weight penalty cost and gradient for non-bias terms
%%% YOUR CODE HERE %%%

%% reshape gradients into vector
[grad] = stack2params(gradStack);
end



