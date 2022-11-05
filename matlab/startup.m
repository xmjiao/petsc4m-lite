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

if exist('OCTAVE_VERSION', 'builtin') || ~usejava('jvm')
    % If running in Octave or in MATLAB without JVM, use mex files
    mexdir = fullfile(petsc4m_root, 'CRS', 'mex');
    if ~isfolder(mexdir); mkdir(mexdir); end
    addpath(mexdir);
else
    % If running with MATLAB with JVM, use exe files
    addpath(fullfile(petsc4m_root, 'CRS', 'exe'));
end

if isempty(getenv('NG_NOCOMPILE'))
    % Do not compile if NG_NOCOMPILE is defined
    build_petsc4m;
end

if exist('OCTAVE_VERSION', 'builtin') || ~usejava('jvm')
   init_petsc();
end

end
