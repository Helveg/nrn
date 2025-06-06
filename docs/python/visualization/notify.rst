.. _notify:

Notification
------------



.. function:: doEvents


    Syntax:
        ``n.doEvents()``


    Description:
        Deal with any pending events in the middle of a computation. 
        This also causes any previous flushes to make their effect felt on 
        the screen. 
         
        Faster than :func:`doNotify` since field editors are not updated. 

         

----



.. function:: doNotify


    Syntax:
        ``n.doNotify()``


    Description:
        All panels are updated so field editors show current values. 
        This is slower than :func:`doEvents` which does not check the field editors. 


