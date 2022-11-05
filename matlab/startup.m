function startup
% startup script for petsc4m_root

addpath(petsc4m_root);

% Load its own submodules last for higher priority
addpath(fullfile(petsc4m_root, 'utils'));
addpath(fullfile(petsc4m_root, 'sys'));
addpath(fullfile(petsc4m_root, 'sys/dpetsc'));
addpath(fullfile(petsc4m_root, 'KSP'));
addpath(fullfile(petsc4m_root, 'PC'));
addpath(fullfile(petsc4m_root, 'CRS'));

if use_mexfiles
    % If running in Octave or in MATLAB without desktop, use mex files
    mexdir = fullfile(petsc4m_root, 'CRS', 'mex');
    if ~isfolder(mexdir); mkdir(mexdir); end
    addpath(mexdir);
else
    % If running with MATLAB with desktop, use exe files
    addpath(fullfile(petsc4m_root, 'CRS', 'exe'));
end

if isempty(getenv('NG_NOCOMPILE'))
    % Do not compile if NG_NOCOMPILE is defined
    build_petsc4m;
end

if use_mexfiles
   init_petsc();
end

end
