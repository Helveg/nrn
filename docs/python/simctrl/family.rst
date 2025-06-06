.. index:: makeFamily (HOC function)

.. _family:


Family
------

     
For several values of a variable, execute an action. 
Basically just a form for specifying a for loop. 

Usage: ``n.makeFamily()`` constructs a Family and maps it to the screen. The Family 
instance is destroyed when its window is dismissed. 

.. image:: ../images/makeFamily.png
    :align: center
 
The slider value ranges from start to end. Due to the length of time it 
generally takes to complete an action it is best to use the middle button 
to select a value with the slider. Dragging the slider button or using 
it too rapidly will cause many action requests to be ignored since a 
slider event taking place while handling the previous event is prevented 
from executing the action recursively. The occasionally has the unintended 
effect of missing the last action when one releases the mouse button. 
 
Menu items: 
 
start end numbersteps: 
    Beginning and final values of the loop variable. The number of steps 
    includes these limiting values so should be at least 2 but if it is 1 then 
    the loop reduces to only the start value. 
 
Variable: 
    Pops up a SymChooser for selection of a variable name. 
    The Family object cannot work without a variable since there is no default. 
 
Action: 
    Pops up a stringchooser for selection of the body of the loop. The default 
    run() action is typically what is desired. 
 
Run: 
    Starts the loop 
 
Stop -- Now: 
    Stops the loop even in the middle of the action. (The ``stdrun.hoc`` ``run()``
    action regularly checks the ``stop_run`` variable.) 
 
Stop -- Atendofaction: 
    Waits for the current action to finish before stopping. 
 
Cont: 
    Starts the action with the next value of the variable. 
    (If the previous action was stopped in the middle, 
    that action is not restarted where it left off.) 

.. note::

    This is function is defined as part of ``stdrun.hoc`` which is loaded automatically as part of
    ``from neuron import gui``, which is required to ensure the GUI is interactive across different
    ways of running NEURON.

.. note::

    This dialog may also be opened from the GUI via
    :menuselection:`Tools --> Miscellaneous --> Family --> Family`

.. _execcommand:

ExecCommand
-----------

.. image:: ../images/ExecCommand.png
    :align: center

Usage: ``n.ExecCommand()`` or :menuselection:`Tools --> Miscellaneous --> Family --> Command`

Specify a command and execute it. 

.. note::

    This is function is defined as part of ``stdrun.hoc`` which is loaded automatically as part of
    ``from neuron import gui``, which is required to ensure the GUI is interactive across different
    ways of running NEURON.


.. _gathervec:

GatherVec
---------

Open with :menuselection:`Vector --> Gather Values` or to open programmatically import GUI support, load the library, and then call the function:

.. code::

    from neuron import n, gui
    n.load_file('gatherv.hoc')
    n.makeGatherVec()

.. image:: ../images/GatherVec.png
    :align: center

Press "Record" button and plot a new point consisting 
of the values for specified `x` and `y` variables. (`x` or `y` crosshair values 
are good candidates for the `y` variable and a run parameter is a good 
candidate for the `x` variable. Then one does a run, selects a point with 
crosshairs, and presses the record button on the GatherValues tool) 
     

.. _vectorplay:

VectorPlay
----------

Open with :menuselection:`Vector --> Play` or to open programmatically import GUI support, load the library, and then call the function:

.. code::

    from neuron import n, gui
    n.load_file('vplay.hoc')
    n.makeVectorPlay()

.. image:: ../images/VectorPlay.png
    :align: center

Copy a vector from the clipboard and play it into some 
chosen (from a Symchooser) variable name. There is button to connect 
and disconnect (return the default value to the variable) the vector. 
 
.. _vecwrap:

VecWrap
-------

Open with :menuselection:`Vector --> Display` or to open programmatically import GUI support, load the library, and then call the function:

.. code::

    from neuron import n, gui
    n.load_file('vecwrap.hoc')
    n.makeVecWrap()

.. image:: ../images/VecWrap.png
    :align: center

Copy vector(s) from the clipboard and do various 
manipulations: Discard left of crosshair, discard right of crosshair, 
crosshair point becomes origin. Obviously rudimentary but this egg 
may hatch into something. 
 

