function [matricesGradients, matrixGradients, biasGradients, ...
          deltaLeft, deltaRight] = ...
      ComputeTensorLayerGradients(a, b, matrices, matrix, bias, delta)
% function tensorLayerOutput = ComputeTensorLayer(a, b, classifierMatrices, classifierMatrix, classifierBias)
% From Socher et al ICML 13

tensorInnerOutput = ComputeInnerTensorLayer(a, b, matrices, matrix, bias);
tensorDeriv = SigmoidDeriv(tensorInnerOutput);

[outDim, inDim] = size(matrix);
inDim = inDim / 2;

matricesGradients = zeros(inDim , inDim * inDim);
matrixGradients = zeros(outDim, 2 * inDim);

% Calculate third order tensor gradients
for i = 1:outDim
    Cols = (inDim*(i - 1))+1:(inDim*i);
    matricesGradients(:,Cols) = (tensorDeriv(i) * delta(i)) .* (a * b');
end
    
% Calculate matrix gradients for tensor layer
for i = 1:outDim
    matrixGradients(i, :) = (tensorDeriv(i) * delta(i)) .* [a; b];
end

% Calculate vector gradients for tensor layer
biasGradients = (tensorDeriv .* delta);

% Calculate deltas to pass down

delta = biasGradients;

innerTensorLayerMatrix = zeros(inDim, outDim);
for i = 1:outDim
    Cols = (inDim*(i - 1))+1:(inDim*i);
    innerTensorLayerMatrix(:, i) = matrices(:,Cols) * b;
end
thirdTerm = innerTensorLayerMatrix + matrix(:, 1:inDim)';
deltaLeft = (thirdTerm * (delta .* tensorDeriv));

innerTensorLayerMatrix = zeros(inDim, outDim);
for i = 1:outDim
    Cols = (inDim*(i - 1))+1:(inDim*i);
    innerTensorLayerMatrix(:, i) = a' * matrices(:,Cols);
end
thirdTerm = innerTensorLayerMatrix + matrix(:, inDim+1:2*inDim)';    
deltaRight = (thirdTerm * (delta .* tensorDeriv));

end