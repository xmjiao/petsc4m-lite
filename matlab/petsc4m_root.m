function rt = petsc4m_root
% petsc4m_root root folder for petsc4m

persistent root__;

if isempty(root__)
    root__ = fileparts(which('petsc4m_root'));
end

rt = root__;

end
