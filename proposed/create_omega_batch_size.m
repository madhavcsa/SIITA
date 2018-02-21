function [omega, Y, idx_1, idx_2, idx_3] = create_omega_batch_size(subs, vals)
    
    idx_1 = unique(subs(:,1));
    idx_2 = unique(subs(:,2));
    idx_3 = unique(subs(:,3));
    
    % d1 X d2 X d3 : dimensions of the tensor  in the current batch.
    
    d1 = length(idx_1);
    d2 = length(idx_2);
    d3 = length(idx_3);
    
    omega = zeros(d1, d2, d3);
    Y     = zeros(d1, d2, d3);
    
    for jj = 1:length(vals)
        
        i = subs(jj,1);
        j = subs(jj,2);
        k = subs(jj,3);
        
        i = find(idx_1 == i);
        j = find(idx_2 == j);
        k = find(idx_3 == k);
        
        omega(i,j,k) = 1;
        Y(i,j,k) = vals(jj);
    end
    
end