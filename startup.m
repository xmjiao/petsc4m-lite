function startup
% startup script for petsc4m_root

addpath(petsc4m_root);

% Load its own submodules last for higher priority
addpath(fullfile(petsc4m_root, 'utils'));
addpath(fullfile(petsc4m_root, 'sys'));
addpath(fullfile(petsc4m_root, 'KSP'));
addpath(fullfile(petsc4m_root, 'PC'));

if exist('OCTAVE_VERSION', 'builtin') || ~usejava('jvm') && ~isempty(getnenv('LD_PRELOAD'))
    % If running in Octave or in MATLAB without JVM and with LD_PRELOAD, use mex files
    addpath(fullfile(petsc4m_root, 'mex'));
else
    % If running with MATLAB with JVM or without LD_PRELOAD, use exe files
    addpath(fullfile(petsc4m_root, 'exe'));
end

if isempty(getenv('NG_NOCOMPILE'))
    % Do not compile if NG_NOCOMPILE is defined
    build_petsc4m;
end

end
