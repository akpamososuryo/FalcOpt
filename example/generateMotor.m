function generateMotor(par)

% options
eps = 1e-3;                 % tolerance
stepSize = 8;               % step size of gradient step (alpha)
merit_function = 0;         % merit function
debug = 2;                  % level of debug
ref = true;                 % to track a desired time-varying reference
contractive = false;        % no constractive constraints
terminal = false;           % no terminal constraints
gradients = 'casadi';
real = 'double';

%% Dynamics of the system
dynamics = @(x,u) model_upd(x,u,par.Ts);


%% code generation ( with 4 different ways to generate derivatives)
switch gradients
    case {'casadi','matlab'}
        
        % first option: Automatic differentiation via CasADi to generate derivatives
        info = falcopt.generateCode(dynamics,par.N,par.nx,par.nu, par.Q, par.P, par.R,...
            'constraints_handle', par.constraint,'nn',par.nn, 'gradients', gradients,...
            'box_lowerBound',par.umin, 'box_upperBound', par.umax,...
            'contractive',contractive, 'terminal', terminal, ...
            'debug',debug,'merit_function', merit_function,...
            'trackReference',ref,'eps',eps,'precision', real,...
            'name', 'Motor_example_FalcOpt', 'gendir', 'generatedCode');
        
    case 'manual'
        
        % third option: specify derivatives by hand
        external_jacobian_x = @Jacobian_x;
        external_jacobian_u = @Jacobian_u;
        external_jacobian_n = @(u) u;
        
        info = falcopt.generateCode(dynamics,par.N,par.nx,par.nu, par.Q, par.P, par.R,...
            'constraints_handle', par.constraint,'nn',par.nn, 'gradients', gradients,...
            'box_lowerBound',par.umin, 'box_upperBound', par.umax,...
            'contractive',contractive, 'terminal', terminal, ...
            'debug',debug,'merit_function', merit_function, 'stepSize', stepSize,...
            'trackReference',ref,'eps',eps,'precision', real,...
            'name', 'Motor_example_FalcOpt', 'gendir', 'FalcOpt',...
            'external_jacobian_x',external_jacobian_x,'external_jacobian_u',external_jacobian_u,'external_jacobian_n',external_jacobian_n);
        
    case 'ccode'
        
        % fourth option: write C code that evaluates the model and the
        % jacobians and their structure (only for experienced users)
        [jac_x_struct,jac_u_struct,jac_n_struct, K_n] = jacobian_structure(par);   % function returning structure of jacobians
        
        info = falcopt.generateCode(dynamics,par.N,par.nx,par.nu, par.Q, par.P, par.R,...
            'nn',par.nn,'contractive',contractive, 'terminal', terminal, 'gradients', gradients, ...
            'debug',debug,'merit_function', merit_function, 'stepSize', stepSize,...
            'trackReference',ref,'eps',eps,'precision', real,...
            'box_lowerBound',par.umin, 'box_upperBound', par.umax,...
            'jac_x_struct',jac_x_struct,'jac_u_struct',jac_u_struct,...
            'jac_n_struct', jac_n_struct, 'K_n', K_n,...
            'name', 'Motor_example_FalcOpt', 'gendir', 'FalcOpt');
end
end

