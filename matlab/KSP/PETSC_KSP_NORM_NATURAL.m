function val = PETSC_KSP_NORM_NATURAL
% Obtain PETSC constant KSP_NORM_NATURAL

val = petscGetEnum('KSP_NORM_NATURAL');
end
