function startup
% startup script for petsc4m_root

try
    % Run startup only if PETSc was configured properly
    run(fullfile(petsc4m_root, 'utils', 'obtain_petsc_cc'));
catch
    return
end

addpath(petsc4m_root);

% Load its own submodules last for higher priority
addpath(fullfile(petsc4m_root, 'utils'));
if exist('OCTAVE_VERSION', 'builtin')
    addpath(fullfile(petsc4m_root, 'utils', 'octave'));
end
addpath(fullfile(petsc4m_root, 'KSP'));
addpath(fullfile(petsc4m_root, 'PC'));
addpath(fullfile(petsc4m_root, 'CRS'));
addpath(fullfile(petsc4m_root, 'sys/dpetsc'));

% Always add exe in the path as fall back
addpath(fullfile(petsc4m_root, 'CRS', 'exe'));

if isempty(getenv('NG_NOCOMPILE'))
    % Do not compile if NG_NOCOMPILE is defined
    build_petsc4m;
end

init_petsc();

end
