function X3 = multiarray2mode3(X)
    % Converts a multiarray to its mode2 unfolding
    %
    
    [n1, n2, n3] = size(X);
    
    X3 = reshape(permute(X, [3 1 2]), n3, n1*n2);
    
end
