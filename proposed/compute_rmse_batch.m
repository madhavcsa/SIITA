function[test_rmse_batch] = compute_rmse_batch(short_idx1, short_idx2, short_idx3, test_subs_vals, A, B, C, vars)

    mode1 = max(short_idx1); 
    mode2 = max(short_idx2); 
    mode3 = max(short_idx3);
                
    % Retrieve test batch for Cumulative test_rmse
    test_subs_vals_temp1 = find(test_subs_vals(:,1) <= mode1);
    test_subs_vals_temp2 = find(test_subs_vals(:,2) <= mode2);
    test_subs_vals_temp3 = find(test_subs_vals(:,3) <= mode3);
    
    test_subs_vals_batch = intersect(test_subs_vals_temp1,test_subs_vals_temp2);
    test_subs_vals_batch = intersect(test_subs_vals_batch, test_subs_vals_temp3);
    
    test_data_batch.subs = test_subs_vals(test_subs_vals_batch(:),1:3);
    test_data_batch.vals = test_subs_vals(test_subs_vals_batch(:),4);
    
    A_batch = find(A(:,1) <= mode1);
    B_batch = find(B(:,1) <= mode2);
    C_batch = find(C(:,1) <= mode3);
    
    A_batch = A(A_batch(:),:);
    B_batch = B(B_batch(:),:);
    C_batch = C(C_batch(:),:);
    
    A_batch_mat = sparse(A_batch(:,1), A_batch(:,2), A_batch(:,3), mode1 ,size(vars.U1,1));
    B_batch_mat = sparse(B_batch(:,1), B_batch(:,2), B_batch(:,3), mode2, size(vars.U2,1));
    C_batch_mat = sparse(C_batch(:,1), C_batch(:,2), C_batch(:,3), mode3, size(vars.U3,1));
    
    X_batch.U1 = A_batch_mat * vars.U1;
    X_batch.U2 = B_batch_mat * vars.U2;
    X_batch.U3 = C_batch_mat * vars.U3;
    X_batch.G  = vars.G.data;
    
    test_error_batch = compute_cost(X_batch, test_data_batch);
    
    if test_error_batch ~= 0
        test_rmse_batch = sqrt(2 * test_error_batch/ size(test_subs_vals_batch,1));    
    else
        test_rmse_batch = 0;
    end
                
end