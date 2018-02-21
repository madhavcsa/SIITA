function cost = compute_cost(X, A_Omega)
        %CALCFUNCTION Calculate the value of the objective function
        %   Wrapper function for calcFunction_mex.c
        %
        %   Computes the value of the objective Function
        %
        %       0.5 * || X_Omega - A_Omega ||^2
        %
        %   See also calcGradient
        
        %   GeomCG Tensor Completion. Copyright 2013 by
        %   Michael Steinlechner
        %   Questions and contact: michael.steinlechner@epfl.ch
        %   BSD 2-clause license, see LICENSE.txt
        
        cost = 0.5 * calcFunction_mex(A_Omega.subs', A_Omega.vals, ...
            X.G, X.U1', X.U2', X.U3');
    end
    