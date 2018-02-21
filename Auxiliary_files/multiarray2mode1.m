function X1 = multiarray2mode1(X)
    % Converts a multiarray to its mode1 unfolding
    %
    
    [n1, n2, n3] = size(X);
    
    X1 = reshape(X, n1, n2*n3);
    
end
