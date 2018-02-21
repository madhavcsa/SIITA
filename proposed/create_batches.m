function[batches] = create_batches(subs, vals, n1, n2, n3, sr)
    % [n1 n2 n3]: Size of the full tensor
    % sr : Sampling ratio, default = 10%
    % opts.A - [subs, vals] : Side information along mode-1
    % opts.B - [subs, vals] : Side information along mode-2
    % opts.C - [subs, vals] : Side infromation along mode-3
    
    
    step_size1 = round(n1 * sr);
    step_size2 = round(n2 * sr);
    step_size3 = round(n3 * sr);
    
    if step_size1 == 0; step_size1 = 1; end
    if step_size2 == 0; step_size2 = 1; end
    if step_size3 == 0; step_size3 = 1; end
    
    subs_vals = [subs vals];
    
    used = [];
    
    ind1 = step_size1;
    ind2 = step_size2;
    ind3 = step_size3;
    
    exit_flag = 0;
    
    batches = {};
    batch_id = 1;
    
    while(exit_flag == 0)
        
        subs_vals_temp_1 = find(subs_vals(:,1) <= ind1);
        subs_vals_temp_2 = find(subs_vals(:,2) <= ind2);
        subs_vals_temp_3 = find(subs_vals(:,3) <= ind3);
        
        subs_vals_temp = intersect(subs_vals_temp_1, subs_vals_temp_2);
        subs_vals_temp = intersect(subs_vals_temp, subs_vals_temp_3);
        
        subs_vals_temp = setdiff(subs_vals_temp , used);
        
        batch = subs_vals(subs_vals_temp(:), :);
        
        if size(batch,1) >0
            batches{batch_id} = batch;
            batch_id = batch_id + 1;
        end
        
        %temp_ids = subs_vals_temp';
        used = [subs_vals_temp' used];
        
        if(ind1 == n1 && ind2 == n2 && ind3 == n3)
            exit_flag = 1;
        else
            ind1 = ind1+step_size1;
            if ind1>=n1
                ind1 = n1;
            end
            
            ind2 = ind2+step_size2;
            if ind2>=n2
                ind2 = n2;
            end
            
            ind3 = ind3 + step_size3;
            if ind3 >= n3
                ind3 = n3;
            end
        end
        
    end
    
end