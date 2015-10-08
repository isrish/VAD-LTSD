%% This code is based on the following paper:
%   Ramırez, Javier, José C. Segura, Carmen Benıtez, Angel De La Torre, and Antonio Rubio.
%   "Efficient voice activity detection algorithms using long-term speech information."
%   Speech communication 42, no. 3 (2004): 271-287.

% Israel D. Gebru @ INRIA-PERCPETION
% 2015

classdef LTSD
    properties
        winsize
        window
        order
        amplitude
        avgnoise
        windownum
        alpha
        speechThr
    end
    methods (Access = public)
        function ltsds = compute(obj,signal)
            enframe = buffer(signal,obj.winsize,round(obj.winsize/2));
            obj.windownum = size(enframe,2);
            ltsds = zeros(obj.windownum,1);
            %Calculate the average noise spectrum amplitude based on 20 frames in the head parts of input signal.
            obj.avgnoise = compute_noise_avg_spectrum(obj,signal(1:obj.winsize*20)).^2;
            for l =1:obj.windownum
                [obj,ltsds(l)] = ltsd(obj,enframe,l,5);
            end
        end
        function [obj,ret] = ltsd(obj,signal,l,order) %  long-term spectral divergence Eqn(2)
            if(l < order || (l+order >= obj.windownum))
                ret =  0;
            else
                [obj,sp0]  = ltse(obj,signal,l,order);
                sp = sp0.^2./obj.avgnoise;
                ret = 10 * log10(sum(sp,1)./length(obj.avgnoise));                
                if(~isempty(obj.alpha)&& ret<obj.speechThr)
                    obj.avgnoise = obj.alpha * obj.avgnoise + (1-obj.alpha)*(sum(sp0,1)./length(obj.avgnoise));
                end
            end
        end
        function [obj,maxamp] = ltse(obj,signal,l,order) % long-term spectral envelope Eqn(1)
            NFFT2 = obj.winsize/2 + 1;
            maxmag = zeros(NFFT2,1);
            for idx=l-order:l+order
                [obj,amp] = get_amplitude(obj,signal,idx);
                maxamp = max(maxmag,amp);
            end
        end
        
        function res =  compute_noise_avg_spectrum(obj,signal)
            enframe = buffer(signal,obj.winsize,round(obj.winsize/2));
            wnum = size(enframe,2);
            NFFT2 = obj.winsize/2 + 1;
            avgamp = zeros(NFFT2,1);
            for l =1:wnum
                s =  enframe(:,l);
                Y = fft(s.*obj.window);
                avgamp = avgamp + abs(Y(1:NFFT2));
            end
            res = avgamp./wnum;
        end
        function obj = LTSD(varargin) %winsize,window,order,adap_rate,threshold
            if nargin>3
                obj.speechThr = varargin{5};
                obj.alpha = varargin{4};
            end
            obj.winsize = varargin{1};
            obj.window = varargin{2};
            obj.order = varargin{3};
            obj.amplitude = {};
            
        end
        function [obj,amp] = get_amplitude(obj,signal,l)
            if(length(obj.amplitude)>=(l+1))
                amp = obj.amplitude{l+1};
            else
                NFFT2 = obj.winsize/2 + 1;
                s = signal(:,l+1);
                Y = fft(s.*obj.window);
                amp  = abs(Y(1:NFFT2));
                obj.amplitude{l+1} = amp;
            end
        end
        
    end
end


