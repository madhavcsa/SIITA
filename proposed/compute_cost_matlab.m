function[cost] = compute_cost_matlab(X, test_data)
% Computes the cost
% 0.5 * ||X_test - Test ||^2
    U1 = X.U1;
    U2 = X.U2;
    U3 = X.U3;
    G = tensor(X.G);
    
    subs = test_data.subs;
    vals = test_data.vals;
    
    cost = 0;
    for id=1:length(vals)
        i = subs(id, 1);
        j = subs(id, 2);
        k = subs(id, 3);
        
        u1 = U1(i,:);
        u2 = U2(j,:);
        u3 = U3(k,:);
        
        predicted_val = ttm(G, {u1, u2, u3});
        predicted_val = double(predicted_val);
        
        cost = cost + (predicted_val - vals(id))^2;
    end
    
    cost = 0.5 * cost;
    
end