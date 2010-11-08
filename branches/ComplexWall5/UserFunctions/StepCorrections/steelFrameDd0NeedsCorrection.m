function needsCorrectionDD0 = steelFrameDd0NeedsCorrection(me)
needsCorrectionDD0 = false;

FzTol = me.getCfg('FzTol');
FzError = me.getDat('FzError');

if abs(FzError) > FzTol
    needsCorrectionDD0 = true;
end
end
