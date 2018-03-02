function [vars] = mast_si(subs, vals, vars, Y_b, omega, r, short_idx1, short_idx2, short_idx3, gamma, opts, regopts, K)
    
    
    
    lambda_1 = 0.1;
    lambda_2 = 0.1;
    lambda_3 = 0.1;
    lambda_g = 0.1;
    
    
    
    if isfield(regopts, 'lambda')
        lambda_1 = regopts.lambda_1;
        lambda_2 = regopts.lambda_2;
        lambda_3 = regopts.lambda_3;
        lambda_g = regopts.lambda_g;
    end
        
    if isfield(opts, 'A') &&  isfield(opts, 'B') && isfield(opts, 'C')
        for k = 1:K
            A_t = opts.A;
            B_t = opts.B;
            C_t = opts.C;

            U1 = vars.U1;
            U2 = vars.U2;
            U3 = vars.U3;
            G  = vars.G;
            [G1, G2, G3] = tensor_matricization(G);


            AU1 = A_t * U1;
            BU2 = B_t * U2;
            CU3 = C_t * U3;

            X = ttensor(G, {AU1, BU2, CU3});

            Res = Y_b - double(X).* omega; % residual

            R = tensor(Res, size(X));

            [R1, R2, R3] = tensor_matricization(R);

            grad_U1 = - A_t' * R1 * kron(CU3, BU2) * G1' + 2*lambda_1 * U1;        
            grad_U2 = - B_t' * R2 * kron(CU3, AU1) * G2' + 2*lambda_2 * U2;        
            grad_U3 = - C_t' * R3 * kron(BU2, AU1) * G3' + 2*lambda_3 * U3;
            grad_G  = - double(ttensor(R, {AU1', BU2', CU3'})) + 2*lambda_g * double(G);

            vars.U1 = U1 - gamma * grad_U1;
            vars.U2 = U2 - gamma * grad_U2;
            vars.U3 = U3 - gamma * grad_U3;
            vars.G  = tensor(double(G)  - gamma * grad_G);

        end
    end
            
end