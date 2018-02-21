function [preds, vals] = compute_preds(X, A_Omega)
        %CALCGRADIENT Calculate the euclid. gradient of the obj. function
        %   Wrapper function for calcGradient_mex.c
        %
        %   Computes the euclid. gradient of the objective function
        %
        %         X_Omega - A_Omega
        %
        %   between a sparse tensor A_Omega and a Tucker tensor X.
        %
        %   We finally compute the predictions.
        
        %   GeomCG Tensor Completion. Copyright 2013 by
        %   Michael Steinlechner
        %   Questions and contact: michael.steinlechner@epfl.ch
        %   BSD 2-clause license, see LICENSE.txt
        
        vals = calcGradient_mex(A_Omega.subs', A_Omega.vals, ...
            X.G, X.U1', X.U2', X.U3');
        preds = vals + A_Omega.vals;
    end