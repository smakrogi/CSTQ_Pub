function OutputDerivativeMatrix = NormalizeDerivative(DerivativeMatrix, derivDegree, sigma, tau)
% syntax: OutputDerivativeMatrix = NormalizeDerivative(DerivativeMatrix,
% derivDegree, sigma, tau);
% Apply gamma-normalization to derivatives in scale-space theory.

OutputDerivativeMatrix = sigma^(derivDegree(1)+derivDegree(2)) * tau^derivDegree(3) * DerivativeMatrix;

end