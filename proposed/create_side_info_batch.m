function[mat] = create_side_info_batch(subs, vals, short_idx, n_cols)
    
   mat = zeros(length(short_idx), n_cols);
   
   for i = 1:length(short_idx)
       id = short_idx(i);
       
       subs_id = find(subs(:,1) == id);
       
       for j = 1:length(subs_id)
           mat(i, subs(subs_id(j),2)) = vals(subs_id(j));
       end
   end
   

end