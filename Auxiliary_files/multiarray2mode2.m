function X2 = multiarray2mode2(X)
    % Converts a multiarray to its mode2 unfolding
    %
    
    [n1, n2, n3] = size(X);
    
    X2 = reshape(permute(X, [2 1 3]), n2, n1*n3);
    
end
