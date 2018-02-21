function[batches] = create_streaming_batches(subs, vals, n1, n2, n3)
% Use this to simulate streaming scenario. In this scenario, tensor only %grows in the third mode.
    % [n1 n2 n3]: Size of the full tensor
    % sr : Sampling ratio, default = 10%
    % opts.A - [subs, vals] : Side information along mode-1
    % opts.B - [subs, vals] : Side information along mode-2
    % opts.C - [subs, vals] : Side infromation along mode-3
    
    batches = {};
    batch_id = 1;
    
    subs_vals = [subs vals];    
    
    for slice = 1:n3
        idx = find(slice-1 < subs_vals(:,3) <= slice);
        batch = subs_vals(idx(:),:);
        
        if(size(batch,1) > 0)
            batches{batch_id} = batch;
            batch_id = batch_id + 1;
        end
    end
    
end