% =====================================================================================================================
% Class which calculates the position of an LBCB platform based on external
% sensors
%
% Members:
%   base - position of the sensor base bin in LBCB coordinates
%   plat - position of the sensor platform bin in LBCB coordinates
%   perturbations - The amount of displacement applied to a difference
%   calculation.
%   jacobian - matrix which transforms calculated sensor length differences
%   based on the perturbation applied.
%
%
% $LastChangedDate: 2009-05-31 07:19:36 -0500 (Sun, 31 May 2009) $
% $Author: mbletzin $
% =====================================================================================================================
classdef ElasticDeformationCalculations < handle
    properties
        base = [];
        plat = [];
        previousLengths = [];
        currentLengths = [];
        jacobian = [];
        calcPlatCtr = [];
        MeasPltCtr = [];
        perturbations = [];
        potTol = [];
        activeDofs = [];
        correctionDeltas = zeros(6,1);
    end
    methods
        function me = ElasticDeformationCalculations(cfg,isLbcb1)
            me.loadConfig(cfg,isLbcb1);
        end
        
        % calculate LBCB position based on external sensor readings.
        calculate(me, curLbcbCP,prevLbcbCP)
        lengths = dof2act(me,deltas,v0,p0,q0)
        loadConfig(me,cfg,isLbcb1)
        newStep(me)
    end
end