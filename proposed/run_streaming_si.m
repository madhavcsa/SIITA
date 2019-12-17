function [X, train_rmse, test_rmse, batch_test_rmse, time_info, batch_time_info, train_auc, test_auc] = run_mast_si(subs, vals, sz, test_data, opts, sideopts)
    % Runs the multi-aspect streaming tucker factorization with Side
    % Information
    % subs: double array of indices
    % vals: non-zero vals in the tensor
    %     subs_test, vals_test
    % sz: [n1 n2 n3], size of the tensor
    % sideopts.A - ([subs vals]): Side information along mode-1
    % sideopts.B - ([subs vals]): Side information along mode-2
    % sideopts.C - ([subs vals]): Side information along mode-3
    % opts.p : fraction of the main tensor observed per iteration
    % opts.r :[r1, r2, r3], rank of factorization
    % opts.batch: Metrics per batch
    % sideopts.A_cols
    % sideopts.B_cols
    % sideopts.C_cols% sideopts.A = A_si;
    % sideopts.A_cols = 10;
    %
    % sideopts.B = B_si;
    % sideopts.B_cols= 10;
    %
    % sideopts.C = C_si;
    % sideopts.C_cols = 10;
    
    
    
    %% Initial Setup
    n1 = sz(1);
    n2 = sz(2);
    n3 = sz(3);
    
    A_cols = 0;
    B_cols = 0;
    C_cols = 0;
    
    if ~isfield(opts, 'r'); opts.r = [5 5 5]; end
    if ~isfield(opts, 'maxepochs'); opts.maxepoch = 10; end
    if isfield(opts, 'p')
        p = opts.p;
    else
        p = 0.1; %default fraction
    end
    if ~isfield(opts, 'alpha_step'); opts.alpha_step = 0.9; end
    if ~isfield(opts, 'computeAUC'); opts.computeAUC = false; end
    
    if ~isfield(opts, 'K')
        K = 5; 
    else
        K = opts.K;
    end
    
    
    if isfield(sideopts, 'A')
        A = sideopts.A;
        A_cols = sideopts.A_cols;
    end
    
    if isfield(sideopts, 'B')
        B = sideopts.B;
        B_cols = sideopts.B_cols;
    end
    
    if isfield(sideopts, 'C')
        C = sideopts.C;
        C_cols = sideopts.C_cols;
    end
    
    batch_wise = 0;
    if isfield(opts, 'batch') && opts.batch; batch_wise = 1; end
    
    %batches = create_batches(subs, vals, n1, n2, n3, p);
    
    batches = create_streaming_batches(subs, vals, n1, n2, n3);
    
    r = opts.r;
    maxepochs = opts.maxepochs;
    
    if isfield(opts, 'lambda_1'); regopts.lambda_1 = opts.lambda_1; end
    if isfield(opts, 'lambda_2'); regopts.lambda_2 = opts.lambda_2; end
    if isfield(opts, 'lambda_3'); regopts.lambda_3 = opts.lambda_3; end
    if isfield(opts, 'lambda_g'); regopts.lambda_g = opts.lambda_g; end
    
    gamma = opts.gamma;
    train_data.subs = subs;
    train_data.vals = vals;
    
    test_subs_vals = [test_data.subs test_data.vals];
    
    %% Running the model
    
    % Initialize the Variables
    if A_cols > 0
        vars.U1 = rand(A_cols, r(1));
    else
        vars.U1 = [];
    end
    
    if B_cols > 0
        vars.U2 = rand(B_cols, r(2));
    else
        vars.U2 = [];
    end
    
    if C_cols > 0
        vars.U3 = rand(C_cols, r(3));
    else
        vars.U3 = [];
    end
    
    vars.G = tenrand(r);
    
    test_rmse = [];
    train_rmse = [];
    test_auc = [];
    train_auc = [];
    
    time_info = [];
    batch_time_info = [];
    batch_test_rmse = [];
    
    
    
    
    for myepoch = 1:maxepochs
        
        gamma = opts.alpha_step * gamma;
        if batch_wise == 0
            batches_epoch = randperm(length(batches));
        else
            batches_epoch = 1:length(batches);
            batch_test_rmse_epoch = [];
        end
        
        epoch_batch_times = [];
        mytime = tic(); % Start time
        
        for i = 1:length(batches)
            
            b = batches_epoch(i);
            batch = batches{b};
            if batch_wise ==1 ; batch_test_time = []; end
            
            subs_b = batch(:,1:3);
            vals_b = batch(:,4);
            [omega_b, Y_b, short_idx1, short_idx2, short_idx3] = create_omega_batch_size(subs_b, vals_b);
            
            
            if isfield(sideopts, 'A')
                A_b = create_side_info_batch(A(:,1:2), A(:,3), short_idx1, A_cols);
                sideopts_batch.A = A_b;
            end
            if isfield(sideopts, 'B')
                B_b = create_side_info_batch(B(:,1:2), B(:,3), short_idx2, B_cols);
                sideopts_batch.B = B_b;
            end
            if isfield(sideopts, 'C')
                C_b = create_side_info_batch(C(:,1:2), C(:,3), short_idx3, C_cols);
                sideopts_batch.C = C_b;
            end
            
            batch_time = tic();
            vars = mast_si(subs_b, vals_b, vars, Y_b, omega_b, r, short_idx1, short_idx2, short_idx3, gamma, sideopts_batch, regopts, K);
            epoch_batch_times = [epoch_batch_times; toc(batch_time)];
            
            % Get batch wise test_rmse if option is set
            if batch_wise == 1
                test_time = tic();
                test_rmse_batch = compute_rmse_batch(short_idx1, short_idx2, short_idx3, test_subs_vals, A, B, C, vars);
                batch_test_rmse_epoch = [batch_test_rmse_epoch; test_rmse_batch];
                batch_test_time = [batch_test_time; toc(test_time)];
            end
        end
        
        if batch_wise == 0
            time_info = [time_info; toc(mytime)]; % Store time per epoch.
        else
            time_info = [time_info; toc(mytime) - cumsum(batch_test_time)];
            batch_test_rmse(myepoch, :) = batch_test_rmse_epoch;
        end
        
        batch_time_info(myepoch, :) = epoch_batch_times;
        
        % Test per epoch
        if A_cols > 0
            A_mat = sparse(A(:,1), A(:,2), A(:,3));
            X.U1 = A_mat * vars.U1;
        else
            X.U1 = vars.U1;
        end
        
        if B_cols > 0
            B_mat = sparse(B(:,1), B(:,2), B(:,3));
            X.U2 = B_mat * vars.U2;
        else
            X.U2 = vars.U2;
        end
        
        if C_cols > 0
            C_mat = sparse(C(:,1), C(:,2), C(:,3));
            X.U3 = C_mat * vars.U3;
        else
            X.U3 = vars.U3;
        end
        X.G = double(vars.G);
        
        % Rmse Computation
        train_error = compute_cost(X, train_data);
        rmse_epoch = sqrt(2 * train_error/ size(vals,1));
        train_rmse = [train_rmse; rmse_epoch];
        
        test_error = compute_cost(X, test_data);
        rmse_epoch = sqrt(2* test_error/size(test_data.vals,1));
        test_rmse =  [test_rmse; rmse_epoch];
        
        
        if opts.computeAUC
            train_preds = compute_preds(X, train_data);
            train_auc = [train_auc; mycomputeAUC(train_preds, vals )];
            test_preds = compute_preds(X, test_data);
            test_auc = [test_auc; mycomputeAUC(test_preds, test_data.vals )];
           fprintf('[Epoch %d] Train Error %e, Test Error %e, TrainAUC %e, TestAUC %e\n', myepoch, train_error(end), test_error(end), train_auc(end), test_auc(end));
        else
           fprintf('[Epoch %d] Train Error %e, Test Error %e\n', myepoch, train_error(end),test_error(end));
            
        end
    end
    
    % Make the cumulative time available
    
    time_info = cumsum(time_info);
        
end
