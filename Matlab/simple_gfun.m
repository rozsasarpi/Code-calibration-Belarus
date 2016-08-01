% Simple, minimal limit state function

function g = simple_gfun(Q, C_Q, G, K_E, R, K_R)

g = K_R.*R - K_E.*(G + C_Q.*Q);

end