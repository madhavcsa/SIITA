function [T1, T2, T3] = tensor_matricization(T)
    
    dim = T.size;
    if length(dim) == 2
        T1 = double(T);
        T2 = double(T);
        T3 = double(T);
    else
    T1 = double(tenmat(T,1));
    T2 = double(tenmat(T,2));
    T3 = double(tenmat(T,3));        
    end
end