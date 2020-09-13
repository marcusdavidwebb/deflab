%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The shifted deflation operator presented in doi:10.1137/140984798.   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef ShiftedDeflation < handle
    properties
        power
        shift
        roots
        parameters
        innerProductMatrix
    end
    
    methods
        function self = ShiftedDeflation(power, shift, roots, innerProductMatrix, parameters)
            self.power = power;
            self.shift = shift;
            self.roots = roots;
            self.parameters = parameters;
            self.innerProductMatrix = innerProductMatrix;
        end
       
        function out = normSquared(self, y, root, ~)
            % Inner product matrix is necessary to compute correct norm 
            % induced by function space
            out = (y - root)' * self.innerProductMatrix * (y - root);
        end
        
        function out = derivativeNormSquared(~, y, root)
            % Derivative is in the dual space, hence should be a row vector
            out = 2 * (y - root)';
        end
        
        function m = evaluate(self, y)
            m = 1;
            for iter = 1:length(self.roots)
                normsq = self.normSquared(y, self.roots{iter}, self.parameters);
                factor = normsq^(-self.power/2) + self.shift;
                m = m * factor;
            end
        end
        
        function deta = derivative(self, y)
            if isempty(self.roots)
                deta = sparse(1,length(y)); % dual vector
            else
                p = self.power;
                numberOfRoots = length(self.roots);
                factors = zeros(1,numberOfRoots);
                dfactors = zeros(1,numberOfRoots);
                dnormsqs = cell(1,numberOfRoots);
                normsqs = cell(1,numberOfRoots);
                
                for iter = 1:length(self.roots)
                    normsqs{iter} = self.normSquared(y, self.roots{iter});
                    dnormsqs{iter} = self.derivativeNormSquared(y, self.roots{iter});
                end
                
                for iter = 1:length(normsqs)
                    factor = normsqs{iter}^(-p/2) + self.shift;
                    dfactor = (-p/2) * normsqs{iter}^((-p/2.0) - 1.0);
                    
                    factors(iter) = factor;
                    dfactors(iter) = dfactor;
                    
                end
                
                eta = prod(factors);
                deta = sparse(1,length(y)); % dual vector
                
                for iter = 1:length(self.roots)
                    deta = deta + (eta/factors(iter))*dfactors(iter) * dnormsqs{iter};
                end
                
            end
        end
    end
    
end