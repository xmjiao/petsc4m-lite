function startup
% startup script for petsc4m_root

addpath(petsc4m_root);

% Load its own submodules last for higher priority
addpath(fullfile(petsc4m_root, 'utils'));
addpath(fullfile(petsc4m_root, 'KSP'));
addpath(fullfile(petsc4m_root, 'PC'));
addpath(fullfile(petsc4m_root, 'CRS'));
addpath(fullfile(petsc4m_root, 'sys/dpetsc'));

% Always add exe in the path as fall back
addpath(fullfile(petsc4m_root, 'CRS', 'exe'));

if isempty(getenv('NG_NOCOMPILE'))
    % Do not compile if NG_NOCOMPILE is defined
    build_pets4cm;
end

init_petsc();

end
