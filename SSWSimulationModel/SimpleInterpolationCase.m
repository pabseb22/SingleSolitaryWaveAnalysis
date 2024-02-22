% Provided data
pois = [0.1, 0.2, 0.3, 0.4, 0.5];
mody = [5e6, 25e6, 50e6, 100e6, 200e6 , 300e6];
values = [
    0.002347835	0.001995579	0.001782002	0.001569458	0.001371817 0.001271817;
    0.00233944	0.001984344	0.001771177	0.001559638	0.001363179 0.001263179;
    0.002324646	0.001964893	0.001752445	0.001542674	0.001348356 0.001248356;
    0.00230234	0.001935833	0.001724757	0.001517768	0.001326559 0.001226559;
    0.002270078	0.001895021	0.00168607	0.001483211	0.001296426 0.001196426 
];

% Specify the desired Poisson's ratio for interpolation
desiredPoisson = 0.48;
% Specify the desired TOF value for interpolation
desiredTOF = 0.001603;

% Perform linear interpolation for the desired Poisson's ratio
interp_values = interp1(pois, values, desiredPoisson, 'linear', 'extrap');

% Display the interpolated values for the desired Poisson's ratio
disp(['Interpolated values for Poisson''s ratio ' num2str(desiredPoisson) ':']);
disp(interp_values);

% Perform linear interpolation for the desired Poisson's ratio along columns
interp_mody_values = interp1(interp_values, mody, desiredTOF, 'linear', 'extrap');

% Display the interpolated modulus for the desired TOF value
disp(['Interpolated Modulus for TOF desired ' num2str(desiredTOF) ':']);
disp(interp_mody_values/1e6); % Displaying in MegaPascals for better readability
