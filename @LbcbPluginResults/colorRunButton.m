function  colorRunButton(me,bs)
    hndl = me.handles.RunHold;
    switch bs
        case 'ON'
            set(hndl,'BackgroundColor','g');
            set(hndl,'FontWeight','bold');
            set(hndl,'Value',1);
        case 'OFF'
            set(hndl,'BackgroundColor','w');
            set(hndl,'FontWeight','normal');
            set(hndl,'Value',0);
        case 'BROKEN'
            set(hndl,'BackgroundColor','y');
            set(hndl,'FontWeight','normal');
            set(hndl,'Value',0);
        otherwise
    end
end