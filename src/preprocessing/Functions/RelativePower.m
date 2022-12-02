function [RP] = RelativePower(signal,fs,band,frequency_band)
%{
Function for computing the Relative Power (RP) of a signal given the
following input parameters:
INPUT:
    signal: the signal itself.
    fs: the sampling frequency. 
    band: the minimum and the maximum frecuencies. Format => [f_min f_max].
    frequency_band: the different frequency bands that one wants to use.
    Example => [1 4;4 8;8 13;13 30;30 40]; (Hz)
OUTPUT:
    RelativePower: a vector with the RP of each frequency band.
PROJECT:  Research Master in signal theory and bioengineering - University of Valladolid
DATE: 09/11/2014
AUTHOR: Jesús Monge Álvarez
%}
%% Checking the ipunt parameters:
control = ~isempty(signal);
assert(control,'The user must introduce a signal (first inpunt).');
control = ~isempty(fs);
assert(control,'The user must introduce a sampling frequency (second inpunt).');
control = ~isempty(band);
assert(control,'The user must introduce a limit for the frequency domain (third inpunt).');
control = ~isempty(frequency_band);
assert(control,'The user must introduce a set of frequency bands (fourth inpunt).');
%% Processing:
% First, we get the Power Spectral Density (PSD):
N = length(signal);
PSD = (1/N)*abs(fftshift(fft(xcorr(signal,'biased'))));
f = linspace(-fs/2,fs/2,length(PSD));
% Second, we compute the absolute power:
%We get the positive index in the band-pass:
ind_band = logical((f >= band(1)) & (f <= band(2)));
num_bands = size(frequency_band,1);
RP = NaN(1,num_bands);
%For each frequency band considered:
for i = 1:num_bands
    %The positive indexes in the frequency band are looked for:
    ind_frequency_band = min(find(f >= frequency_band(i,1))):max(find(f <= frequency_band(i,2)));
    %We compute the absolute power in the frequency band considered:
    RP(i) = sum(PSD(ind_frequency_band));
end
% Finally, the Relative Power (RP) of each band is obtained:
RP = RP / sum(PSD(ind_band));