% Want to distribute this code? Have other questions? -> sbowman@stanford.edu
function deriv = TanhDeriv (in, out)
% Compute the gradient of the tanh nonlinearity.

% TODO: Redefine in terms of the output vector -- faster.

if nargin > 1
 	deriv = 1 - out.^2;
else
	deriv = sech(in).^2;
end

end
