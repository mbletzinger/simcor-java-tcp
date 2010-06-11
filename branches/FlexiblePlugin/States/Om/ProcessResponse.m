% =====================================================================================================================
% Class containing the calculations for derived DOFs.
%
% Members:
%  steps - InputFile instance
%  curStep - The current LbcbStep
%  nextStep - The next LbcbStep as calculated by this class
%
% $LastChangedDate: 2009-06-01 15:30:46 -0500 (Mon, 01 Jun 2009) $
% $Author: mbletzin $
% =====================================================================================================================
classdef ProcessResponse < OmState
    properties
        log = Logger('ProcessResponse');
    end
    methods
        function me = ProcessResponse()
            me = me@OmState();
        end
        function start(me)
            me.edCalculate();
            me.derivedDofCalculate();
        end
        function done = isDone(me)
            me.statusReady();
            done = 1;
        end
    end
    methods (Access='private')
        function edCalculate(me)
            scfg = StepConfigDao(me.cdp.cfg);
            if scfg.doEdCalculations
                %calculate elastic deformations
                for l = 1: me.cdp.numLbcbs()
                    ccps = me.dat.curStepData.lbcbCps{l};
                    pcps = {};
                    if isempty(me.dat.prevStepData) == false
                        pcps = me.dat.prevStepData.lbcbCps{l};
                    end
                    me.ed{l}.calculate(ccps,pcps);
                    %                     me.dat.curStepData.lbcbCps{l}.response.ed = ...
                    %                         me.dat.curStepData.lbcbCps{l}.response.lbcb;
                end
            end
        end
        function derivedDofCalculate(me)
            scfg = StepConfigDao(me.cdp.cfg);
            if scfg.doDdofCalculations
                me.dd.calculate(me.dat.curStepData);
            end
        end
    end
end