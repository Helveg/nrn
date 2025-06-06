.. _nmodl_neuron_extension:

.. _nmodltoneuron:

NEURON Extension to NMODL
-------------------------

This section describes the special ``NEURON`` block that has been added to
the standard model description language in order to allow translation of 
a model into a form suitable for linking with ``NEURON``.
 
The keyword ``NEURON`` introduces a special block which contains statements
that tell NMODL how to organize the variables for access at the ``NEURON``
user level. It declares: 

-   Which names are to be treated as range variables. 
-   Which names are to be treated as global variables. 
-   The names of all the ions used in the model and how the corresponding 
    concentrations, current, and reversal potential are to be treated. 
-   The suffix to be used for all variables in the model so that they 
    do not conflict with variables in other models. 
-   Whether the model is for a point process such as a synapse or 
    a distributed process with density along an entire section such as a channel 
    density. 
-   Which names will be connected to external variables. (See "Importing 
    variables from other mechanisms".) 

The syntax is (each statement can occur none or more times) : 

NEURON
~~~~~~


Description:
    .. code-block::

        NEURON{ 
           SUFFIX name
           RANGE range1, ...
           GLOBAL global1, ...
           NONSPECIFIC_CURRENT nonspec1, ...
           ELECTRODE_CURRENT elec1, ...
           USEION name [READ read1, ...] [WRITE write1, ...] [VALENCE real] [REPRESENTS ontology_id]
           POINT_PROCESS ... 
           POINTER pointer1, ...
           BBCOREPOINTER bbcore1, ...
           RANDOM ranvar1, ...
           EXTERNAL external1, ...
           THREADSAFE
           REPRESENTS ontology_id
        } 



SUFFIX
######


Description:
    .. code-block::

        NEURON {
            SUFFIX _name
        }

    The suffix, "``_name``" is appended to all variables, functions, and 
    procedures that are accessible from the user level of ``NEURON``. If the ``SUFFIX``
    statement is absent, the file name is used as the suffix (with the addition 
    of an underscore character).  If there is a :ref:`mech` statement, 
    that name 
    is used as the suffix.  Suffixes prevent overloading of names at the user 
    level of ``NEURON``.  At some point in the future I may add something similar
    to the access statement which will allow the omission of the suffix for a 
    specified mechanism. 
    Note that suffixes are not used within the model 
    description file itself. If the SUFFIX *name* is the word, "``nothing``", 
    then no suffix is used for 
    variables, functions, and procedures explicitly declared in the :file:`.mod` file. 
    However, the mechanism name will be the base file name. 
    This is useful if you know that no conflict of names 
    will exist or if the :file:`.mod` file is primarily used to create functions callable 
    from ``NEURON`` by the user and you want to specify those function names exactly.


RANGE
#####


Description:
    .. code-block::

        NEURON {
            RANGE range1, ...
        }

    These names will be become range variables. Do not add suffixes here. 
    The names should also be declared in the normal ``PARAMETER`` or ``ASSIGNED`` 
    statement outside 
    of the ``NEURON`` block.  Parameters that do not appear in a ``RANGE``
    statement will become global variables. 
    Assigned variables that do not appear in this statement or in the
    ``GLOBAL`` statement will be hidden from the user.
    When a mechanism is inserted in 
    a section, the values of these range variables are set to the values 
    specified in the normal ``PARAMETER`` statement outside the
    ``NEURON`` block. 


GLOBAL
######


Description:
    .. code-block::

        NEURON {
            GLOBAL global1, ...
        }

    These names, which should be declared elsewhere as ``ASSIGNED`` or ``PARAMETER``
    variables, 
    become global variables instead of range variables.  Notice here that 
    the default for a ``PARAMETER`` variable is to become a global variable whereas 
    the default for an ``ASSIGNED`` variable is to become hidden at the user level. 


.. nonspecific_current:

NONSPECIFIC_CURRENT
###################


Description:
    .. code-block::

        NEURON {
            NONSPECIFIC_CURRENT nonspec1, ...
        }

    This signifies that we are calculating local currents which get added 
    to the total membrane current but will not contribute to any particular 
    ionic concentration.  This current should be assigned a value 
    after any ``SOLVE`` statement but before the end of the ``BREAKPOINT`` block. 
    This name will be hidden at the user level unless it appears in a
    ``RANGE`` statement.


ELECTRODE_CURRENT
#################


Description:
    .. code-block::

        NEURON {
            ELECTRODE_CURRENT elec1, ...
        }

    The ELECTRODE_CURRENT statement has two important consequences: positive values of the current
    will depolarize the cell (in contrast to the hyperpolarizing effect of positive transmembrane
    currents), and when the extracellular mechanism is present there will be a change in the
    extracellular potential ``vext``.
    ``TODO``: Add existing example mod file (iclamp1.mod)


USEION
######


Description:
    .. code-block::

        NEURON {
            USEION name [READ read1, ...] [WRITE write1, ...] [VALENCE real] [REPRESENTS ontology_id]
        }

    This statement declares that a  specific ionic species will be used within 
    this model. The built-in 
    HH channel uses the ions ``na`` and ``k``. Different models which deal with 
    the same ionic species should use the same names so that total concentrations 
    and currents can be computed consistently. The ion, ``Na``, is different from 
    ``na``.  The example models using calcium call it, ``ca``. If an ion is 
    declared, suppose it is called, 
    ``ion``, then a separate mechanism is internally created 
    within ``NEURON``, denoted by ``ion``, and automatically inserted whenever
    the "using" mechanism is inserted.  The variables of the mechanism 
    called ``ion`` are 
    outward total current carried by this ion, ``iion``; internal and 
    external concentrations of this ion, ``ioni`` and ``iono``; and 
    reversal potential of this ion, ``eion``.  These ion range variables do 
    NOT have suffixes. 
    Prior to 9/94 the reversal potential was not automatically calculated 
    from the Nernst equation but, if it was *used* it had to be set by 
    the user or by an assignment in some mechanism (normally the Nernst equation). 
    The usage of ionic concentrations and reversal potential has been changed 
    to more naturally reflect their physiological meaning while remaining 
    reasonably efficient computationally. 
     
    The new method governs the behaviour of the reversal potential and 
    concentrations with respect to their treatment by the GUI (whether 
    they appear in PARAMETER, ASSIGNED, or STATE panels; indeed, whether they 
    appear at all in these panels) and when the reversal potential 
    is automatically computed from the concentrations using the Nernst 
    equation. The decision about what style to use happens on a per section 
    basis and is determined by the set of mechanisms inserted within the 
    section. The rules are defined in the reference to the function 
    ion_style(). Three cases are noteworthy. 

READ
````

    Assume only one model is inserted in a section. 

    .. code-block::

        	USEION ca READ eca 

    Then eca will be treated as a PARAMETER and cai/cao will not 
    appear in the parameter panels created by the gui. 
     
    Now insert another model at the same section that has 

    .. code-block::

        	USEION ca READ cai, cao 

    Then 1) eca will be "promoted" to an ASSIGNED variable, 2) cai/cao 
    will be treated as constant PARAMETER's, and 3) eca will be computed 
    from the Nernst equation when finitialize() is called. 

WRITE
`````

    Lastly, insert a final model at the same location in addition to the 
    first two. 

    .. code-block::

        	USEION ca WRITE cai, cao 

    Then  eca will still be treated as an ASSIGNED variable but will be 
    computed not only by finitialize but on every call to fadvance(). 
    Also cai/cao will be initialized to the global variables 
    cai0_ca_ion and cao0_ca_ion respectively and treated as STATE's by the 
    graphical interface. 
     
    

 
    The idea is for the system to automatically choose a style which is 
    sensible in terms of dependence of reversal potential on concentration 
    and remains efficient. 
     
    

 
    Since the nernst equation is now automatically used as needed it is 
    necessary to supply the valence (charge carried by the ion) except for 
    the privileged ions: na, k, ca which have the VALENCE 1, 1, 2 respectively. 
     
    

 
    Only the ion names ``na``, ``k``, and ``ca`` are initialized to a 
    physiologically meaningful value --- and those may not be right for 
    your purposes.  Concentrations and reversal potentials should be considered 
    parameters unless explicitly calculated by some mechanism. 

VALENCE
```````

    The ``READ`` list of a ``USEION`` specifies those ionic variables which 
    will be used to calculate other values but is not calculated itself. 
    The ``WRITE`` list of a ``USEION`` specifies those ionic variables which 
    will be calculated within this mechanism. Normally, a channel will read 
    the concentration or reversal potential variables and write a current. 
    A mechanism that calculates concentrations will normally read a current 
    and write the intracellular and/or extracellular; it is no longer necessary 
    to ever write the reversal potential as that will be automatically computed 
    via the nernst equation. 
    It usually does not make sense to both read and 
    write the same ionic concentrations. 
    It is possible to READ and WRITE currents. 
    One can imagine,  a large calcium 
    model which would ``WRITE`` all the ion variables (including current) 
    and READ the ion current. 
    And one can imagine 
    models which ``READ`` some ion variables and do not ``WRITE`` any. 
    It would be an error if more than one mechanism at the same location tried 
    to WRITE the same concentration. 
     
    

 
    A bit of implementation specific discussion may be in order here. 
    All the statements after the ``SOLVE`` statement in the
    ``BREAKPOINT`` block are 
    collected to form a function which is called during the construction of 
    the charge conservation matrix equation.  This function is called 
    several times in order to compute the current and conductance  to be added 
    into the matrix equation.  This function is never called if you are not 
    writing any current.  The ``SOLVE`` statement is executed after the new voltages 
    have been computed in order to integrate the states over the time step, ``dt``. 
    Local static variables get appropriate copies of the proper ion variables 
    for use in the mechanism. Ion variables get updated on exit from these 
    functions such that WRITE currents are added to ion currents. 

REPRESENTS
``````````

    See ``REPRESENTS`` statement.

.. point_process:

POINT_PROCESS
#############


Description:
    .. code-block::

        NEURON {
            POINT_PROCESS ...
        }

        
    Point models are used for synapses, electrode stimuli, etc.
    They are distinguished from standard mechanisms in that instead of inserting
    the mechanism into a section and accessing parameters via range variables,
    point mechanisms are created as interpreter objects, eg.


    .. code-block::
        none

            objref stim
            stim = new IClamp(x)
        

    Values are accessed via the standard object syntax, eg. ``stim.amp = 2``.
    Since standard mechanisms are considered in terms of density,
    the appropriate current units for standard mechanisms are mA/cm2 and conductance units are mho/cm2.
    However, point process current units are nA and conductance units are umho.
    These conventions ensure that the simulation is independent of the number of segments in a section
    (assuming the number of segments is large enough so spatial discretization error is small).

    At the NEURON user level, all variables and functions associated with a POINT_PROCESS
    are accessed via the normal object syntax. A point process, call it ``pnt`` is inserted into (or moved to)
    the currently specified section at location, ``0 < x < 1``, with the function, ``pnt.loc(x)``. See :meth:`pnt.get_loc`
    
    If a point process is created with no argument then it is not located anywhere.
    If an argument is present and there is a currently accessed section then the point process is placed there.
    At this time, point processes are placed at the center of the nearest segment.

    ``pnt.has_loc()`` returns 1 if the point process is located in a section and returns 0 if not located.
    If a point process has no location then attempts to access its variables or get its location will
    produce an error message. See :meth:`pnt.has_loc`
    
    One finds the location of a point process via the function,  ``x = pnt.get_loc()``. See :meth:`pnt.get_loc` 

    
    The function returns the x location at the center of the segment where the process was placed and pushes the section name onto the stack so that it becomes the currently accessed section. The stack must be popped with pop_section() at a subsequent time. BE SURE TO POP THE SECTION STACK! This can be a dangerous function in the sense that if the stack is not popped, then section access is completely screwed up.

    The POINT_PROCESS mechanism can be used to implement classes written in c/c++ for use by the interpreter.
    To aid in this the special block CONSTRUCTOR is called when a point process is created with the ``new``  command in the interpreter.
    Just before the memory associated with a point process instance is freed the users DESTRUCTOR block (if any) is called.

    .. seealso:: 
        :ref:`mech`


POINTER
#######


Description:
    .. code-block::

        NEURON {
            POINTER pointer1, ...
        }

    These names are pointer references to variables outside the model. 
    They should be declared in the body of the description as normal variables 
    with units and are used exactly like normal variables. The user is responsible 
    for setting these pointer variables to actual variables at the 
    hoc interpreter level. Actual variables are normal variables in other 
    mechanisms, membrane potential, or any hoc variable. 
    See :ref:`below<pointer_communication>` for how this 
    connection is made. If a POINTER variable is ever used without being 
    set to the address of an actual variable, ``NEURON`` may crash with a memory
    reference error, or worse, produce wrong results. Unfortunately the errors 
    that arise can be quite subtle. For example, if you set a POINTER correctly 
    to a mechanism variable in section a. And then change the number of segments in 
    section a, the POINTER will be invalid because the memory used by 
    section a is freed and might be used for a totally different purpose. It 
    is up to the user to reconnect the POINTER to a valid actual variable. 


BBCOREPOINTER
#############


Description:
    .. code-block::

        NEURON {
            BBCOREPOINTER bbcore1, ...
        }

    See: :ref:`Memory Management for POINTER Variables`

    ``TODO``: Add description (?) and existing example mod file (provided by link)

.. _nmodlrandom:

RANDOM
######

Description:
    .. code-block::

        NEURON {
            RANDOM ranvar1, ...
        }

    These names refer to random variable streams that are automatically
    associated with nrnran123 generators. Such nrnran123 generators are also used, for example to implement
    :meth:`Random.Random123`
    These names are analogous to range variables in that the streams are distinct for every mechanism instance
    of a POINT_PROCESS, ARTIFICIAL_CELL, or instance of a density mechanism in a segment of a cable section.
    Each stream exists for the lifetime of the mechanism instance. While a stream exists, its properties can
    be changed from the interpreter.

    Prior to the introduction of this keyword, random streams required a POINTER variable and
    fairly elaborate VERBATIM blocks
    to setup the streams and manage  the stream properties from HOC or Python so that each stream was
    statistically independent of all other streams.
    
    From the interpreter, the ranvar1 stream properties are assigned and evaluated using standard
    range variable syntax where mention of ranvar1 returns a :class:`~NMODLRandom` object that wraps the stream
    and provides method calls to get and set the three stream ids and the starting sequence number.

    When a stream is instantiated, its identifier triplet is default initialized to
    (1, :meth:`mpiworldrank <ParallelContext.id_world>`, ++internal_id3)
    so all streams are statistically independent (at launch time, internal_id3 = 0).
    However since the identifier triplet depends on the order of
    construction, it is recommended for parallel simulation reproducibility that triplets be algorithmically specified
    at the interpreter level. And see :meth:`Random.Random123_globalindex`.

    At present, the list of random_... methods available for use within mod files (outside of VERBATIM blocks) are:

        * random_setseq(ranvar1, uint34_value)
        * random_setids(ranvar1, id1_uint32, id2_uint32, id3_uint32)
        * x = random_uniform(ranvar1) : uniform 0 to 1 -- minimum value is 2.3283064e-10 and max value is 1-min
        * x = random_uniform(ranvar1, min, max)
        * x = random_negexp(ranvar1) : mean 1.0 -- min value is 2.3283064e-10, max is 22.18071
        * x = random_negexp(ranvar1, mean)
        * x = random_normal(ranvar1) : mean 1.0, std 1.0
        * x = random_normal(ranvar1, mean, std)
        * x = random_ipick(ranvar1) : range 0 to 2^32-1
        * x = random_dpick(ranvar1)
  

EXTERNAL
########


Description:
    .. code-block::

        NEURON {
            EXTERNAL external1, ...
        }

    These names, which should be declared elsewhere as ``ASSIGNED``
    or ``PARAMETER``
    variables allow global variables in other models or ``NEURON`` c files to be
    used in this model. That is, the definition of this variable must appear 
    in some other file. Note that if the definition appeared in another mod file 
    this name should explicitly contain the proper suffix of that model. 
    You may also call functions from other models (but do not ignore the warning; 
    make sure you declare them as 

    .. code-block::

        extern double fname_othermodelsuffix(); 

    in a ``VERBATIM`` block and use them with the proper suffix. 


THREADSAFE
##########

Description:
    .. code-block::

        NEURON {
            THREADSAFE
        }

    See: :ref:`Multithreaded paralellization` and :ref:`Thread Safe MOD Files`

    ``TODO``: Add description and existing example mod file

REPRESENTS
##########

Description:
    .. code-block::

        NEURON {
            REPRESENTS ontology_id
        }

    Optionally provide CURIE (Compact URI) to annotate what the species represents
    e.g. ``CHEBI:29101`` for sodium(1+).

    ``TODO``: Add existing example mod file (src/nrnoc/hh.mod)



BEFORE / AFTER
~~~~~~~~~~~~~~

Description:
    .. code-block::

        BEFORE <INITIAL/BREAKPOINT/STEP> {
           ...
        }

        AFTER <INTIAL/SOLVE> {
           ...
        }

    - ``BEFORE INITIAL`` executes just before any :ref:`INITIAL` blocks of any mod file execute (but after all the type ``0`` of :ref:`FInitializeHandler` are called).
    - ``AFTER INITIAL`` executes just after the :ref:`INITIAL` blocks of all mod files execute (but before all the type ``1`` of :ref:`FInitializeHandler` are called).
    - ``BEFORE BREAKPOINT`` executes whenever the tree matrix is setup before any :ref:`BREAKPOINT` blocks execute
    - ``AFTER SOLVE`` executes afer all the :ref:`SOLVE` blocks (have updated the states for the fixed step method). For the fixed step method that is more or less the end of :ref:`fadvance()`. But for variable step methods that refers to the completion of a cvode step which is not quite what is desired in practice because event arrival can cause cvode to retreat to an earlier time. Hence the use of ``BEFORE STEP``.
    - ``BEFORE STEP`` executes just before vector record takes place. I.e. ``BEFORE STEP`` takes place when the entire system of equations and events are consistent at time `t`.

    .. note::
        Note that the ``INITIAL`` blocks are ordered so that mechanisms that write
        concentrations are after the initialization of ions and before mechanisms that read
        concentrations.
        But that is also the case for the order of the list of mechanisms that do ``INITIAL``, ``BREAKPOINT``, ``SOLVE``, etc.
        

    ``TODO``: Add existing example mod file


FOR_NETCONS
~~~~~~~~~~~

Description:
    FOR_NETCONS (args) means to loop over all NetCon connecting to this
    target instance and args are the names of the items of each NetCon's
    weight vector (same as the enclosing NET_RECEIVE but possible different
    local names).

    ``TODO``: Add existing example mod file (test/coreneuron/mod/fornetcon.mod)


PROTECT
~~~~~~~

Description:
    .. code-block::

        NEURON {
            GLOBAL var
        }

        BREAKPOINT {
            PROTECT var = var + 1
        }

    Mod files that update values to :ref:`GLOBAL` variables are not considered
    thread safe. In case of multi-threaded/SIMD/GPU execution, such updates can result
    in a race condition. To avoid this, one needs to use ``PROTECT`` keyword. Note that
    ``PROTECT`` internally uses atomic operations on CPU or GPU execution and hence
    the statement needs to be of a simple form such as:

    .. code-block::

        var1 = var1 binary_operator expression
        var1 = expression binary_operator var1

    If the mod file is using the ``GLOBAL`` essentially as a file scope :ref:`LOCAL`
    along with the possibility of passing values back to hoc in response to calling a
    :ref:`PROCEDURE`, make sure to use the :ref:`THREADSAFE` keyword in the
    :ref:`NEURON` block to automatically treat those ``GLOBAL`` variables as thread
    specific variables. NEURON assigns and evaluates only the thread 0 version and if
    :ref:`FUNCTION` and ::ref:`PROCEDURE` are called from Python, the thread 0 version
    of these globals are used.

    .. note::
        For the performance reason, we recommend to reduce or remove the use of
        ``PROTECT`` construct.


MUTEXLOCK / MUTEXUNLOCK
~~~~~~~~~~~~~~~~~~~~~~~

Description:
    .. code-block::

        LOCAL factors_done

        INITIAL {
            MUTEXLOCK
            if (factors_done == 0) {
                  factors_done = 1
                  factors()
            }
            MUTEXUNLOCK
        }

        PROCEDURE factors() {
            : ...
        }

    Similar to ``PROTECT``, ``MUTEXLOCK`` and ``MUTEXUNLOCK`` are two constructs to
    handle thread-safety in case update of updates to ``GLOBAL`` variables in
    multi-threaded execution. Internally it uses mutex mechanism to avoid race condition.

    .. note::
        This construct is not supported in the case of GPU execution via CoreNEURON.
        For the performance reason and compatibility with GPU execution, either avoid
        the usage of this construct or check alternatives using ``PROTECT`` construct.

.. _verbatim:

VERBATIM
~~~~~~~~

Description:
    Sections of code surrounded by ``VERBATIM`` and ``ENDVERBATIM`` blocks are
    interpreted as literal C/C++ code.
    This feature is typically used to interface with external C/C++ libraries,
    or to use NEURON features (such as random number generation) that are not
    explicitly supported in the NMODL language.

    .. code-block::

      PROCEDURE set_foo() {
      VERBATIM
      /* literal C/C++ */
      ENDVERBATIM
        foo = 42
      }

    This is, by its nature, more fragile than exclusively using NMODL language
    constructs, but it can be necessary.
    NEURON versions newer than 8.1
    (`#1762 <https://github.com/neuronsimulator/nrn/pull/1762>`_) provide some
    C/C++ preprocessor macros that make it easier to follow incompatible changes
    in external libraries or the internal workings of NEURON.

    .. code-block:: c++

      #if NRN_VERSION_EQ(9, 0, 0)
      /* NEURON version is exactly 9.0.0 */
      #endif
      #if NRN_VERSION_NE(8, 2, 3)
      /* NEURON version is not 8.2.3 */
      #endif
      #if NRN_VERSION_GT(9, 1, 0)
      /* NEURON version is >9.1.0 */
      #endif
      #if NRN_VERSION_LT(10, 2, 0)
      /* NEURON version is <10.2.0 */
      #endif
      #if NRN_VERSION_GTEQ(8, 2, 1)
      /* NEURON version is >=8.2.1 */
      #endif
      #if NRN_VERSION_LTEQ(8, 2, 2)
      /* NEURON version is <=8.2.2 */
      #endif
      #ifndef NRN_VERSION_GTEQ_8_2_0
      /* NEURON version is <8.2.0 */
      #else
      /* NEURON version is >=8.2.0 so NRN_VERSION_{EQ,NE,GT,LT,GTEQ,LTEQ}(...)
       * are defined. */
      #endif

    ``VERBATIM`` should be used with caution and restraint, as it is very easy
    to introduce dependencies on the implementation details of NEURON and the
    NMODL language compilers and end up with MOD files that are only compatible
    with a limited range of NEURON versions.

.. _connectingmechanismstogether:

Connecting Mechanisms Together
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Occasionally mechanisms need information from other mechanisms which may 
    be located elsewhere in the neuron. Connecting pre and post synaptic 
    point mechanisms is an obvious example. In the same vein, it may be useful 
    to call a function from hoc which modifies some mechanism variables 
    at a specific 
    location. (Normally, mechanism functions callable from HOC should not 
    modify range variables since the function does not know where the mechanism 
    data for a segment is located. Normally, the pointers are set when ``NEURON`` 
    calls the ``BREAKPOINT`` block and the associated ``SOLVE`` blocks.) 
     
    

 
    One kind of connection between mechanisms at the same point is through 
    ionic mechanisms invoked with the USEION statement. In fact this is 
    entirely adequate for local communication although treating an arbitrary 
    variable as an ionic concentration may be conceptually strained. 
    However, it does not solve the problem of communication between mechanisms 
    at different points. 

     
.. _pointer_communication:

Pointer Communication
~~~~~~~~~~~~~~~~~~~~~


Description:
    Basically what is needed is a way to implement the statement 

    .. tab:: Python

        .. code-block::
            python

            section1(x1).mech1.var1 =  section2(x2).mech2.var2

    .. tab:: HOC

        .. code-block::
            none

            section1.var1_mech1(x1) =  section2.var2_mech2(x2) 

    efficiently from within a mechanism without having to explicitly connect them 
    through assignment at the Python/HOC level everytime the :samp:`{var2}` might change. 
     
    First of all, the variables which point to the values in some other mechanism 
    are declared within the NEURON block via 

    .. code-block::
        none

        NEURON { 
           POINTER var1, var2, ... 
        } 

    These variables are used exactly like normal variables in the sense that 
    they can be used on the left or right hand side of assignment statements 
    and used as arguments in function calls. They can also be accessed from Python/HOC
    just like normal variables. 

    It is essential that the user set up the pointers to point to the correct 
    variables. This is done by first making sure that the proper mechanisms 
    are inserted into the sections and the proper point processes are actually 
    "located" in a section. Then, at the Python/HOC level each POINTER variable 
    that exists should be set up via the command

    .. tab:: Python

        .. code-block::
            python

            mechanism_object._ref_somepointer = source_obj._ref_varname

    .. tab:: HOC

        .. code-block::
            none

            setpointer pointer, variable 

    Here mechanism_object (a point process object or a density mechanism) and
    the other arguments (in Python) or pointer and variable (in HOC)
    have enough implicit/explicit information to 
    determine their exact segment and mechanism location. For a continuous 
    mechanism, this means the section and location information. For a point 
    process it means the object. The reference may also be to any NEURON variable 
    or voltage, e.g. ``soma(0.5)._ref_v`` in Python. 

    .. TODO: Replace hard-coded GitHub hyperlinks with a robust way to link to source files.

    .. tab:: Python

        .. note::
            In ``nrn/share/examples/nrniv/nmodl/``, see
            `tstpnt1.py <https://github.com/neuronsimulator/nrn/blob/master/share/examples/nrniv/nmodl/tstpnt1.py>`_
            and 
            `tstpnt2.py <https://github.com/neuronsimulator/nrn/blob/master/share/examples/nrniv/nmodl/tstpnt2.py>`_
            for examples of usage.
 
    .. tab:: HOC

        .. note::
            In ``nrn/share/examples/nrniv/nmodl/``, see
            `tstpnt1.hoc <https://github.com/neuronsimulator/nrn/blob/master/share/examples/nrniv/nmodl/tstpnt1.hoc>`_
            and 
            `tstpnt2.hoc <https://github.com/neuronsimulator/nrn/blob/master/share/examples/nrniv/nmodl/tstpnt2.hoc>`_
            for examples of usage.

    For example, consider a synapse which requires a presynaptic potential 
    in order to calculate the amount of transmitter release. Assume the 
    declaration in the presynaptic model 

    .. code-block::
        none

        NEURON { POINTPROCESS Syn   POINTER vpre } 

    Then

    .. tab:: Python

        .. code-block::
            python

            syn = n.Syn(section(0.8)) 
            syn._ref_vpre = axon(1)._ref_v

    .. tab:: HOC

        .. code-block::
            none

            objref syn 
            somedendrite {syn = new Syn(.8)} 
            setpointer syn.vpre, axon.v(1) 

    will allow the ``syn`` object located at ``section(0.8)`` 
    to know the voltage at the distal end of the axon section. 
    As a variation on that example, if one supposed that the synapse 
    needed the presynaptic transmitter concentration (call it :samp:`{tpre}`) calculated 
    from a point process model called "release" (with object reference :samp:`{rel}`, say)
    then the statement would be 

    .. tab:: Python

        .. code-block::
            python

            syn._ref_tpre = rel._ref_ACH_release

    .. tab:: HOC

        .. code-block::
            none

            setpointer syn.tpre, rel.AcH_release 

    The caveat is that tight coupling between states in different models 
    may cause numerical instability. When this happens, 
    merging models into one larger model may eliminate the instability,
    unless the model is so simple that time 
    does not appear, such as a passive channel. In that case, ``v`` is normally 
    chosen as the independent variable. MODL required this statement but NMODL 
    will implicitly generate one for you.  
    When currents and ionic potentials are calculated in a particular model they 
    are declared either as STATE, or ASSIGNED depending on the nature 
    of the calculation or whether they are important enough to save. If a variable 
    value needs to persist only between entry and exit of an instance 
    one may declare it as LOCAL, but in that case the model cannot be vectorized 
    and different instances cannot be called in parallel. 

    .. tab:: Python

        .. note::

            For density mechanisms, one cannot pass in e.g. ``n.hh`` as this raises 
            a TypeError; one can, however, pass in ``nrn.hh`` where ``nrn`` is defined
            via ``from neuron import nrn``.
