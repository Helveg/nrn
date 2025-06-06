.. _list:

List
----



.. class:: List

    List of objects 

    Syntax:
        ``n.List()``

        ``n.List("templatename")``


    Description:
        The ``List`` class provides useful tools for creating and manipulating lists of objects. 
        In many cases, e.g., if you have a network of cells connected at synapses and each synapse 
        is a separate object, you might want to store such information (pre-syns, post-syns, cells)
        using regular Python lists.

        Besides interacting with legacy code, the NEURON ``List`` class provides two key features
        not available in Python lists:

        1. The ability to create a dynamic ``List`` of all the object instances of a template (e.g.,
           all instances of an ``"IClamp"`` or of a cell class.)
        2. The ability to create a GUI browser for the list, which can be used to select and interact
           with the objects in the list.


        There are two ways of invoking the constructor:

        ``n.List()`` 
            Create an empty list. Objects added to the list are referenced. 
            Objects removed from the list are unreferenced. 

        ``n.List("templatename")`` 
            Create a list of all the object instances of the template. 
            These object instances are NOT referenced and therefore the list 
            dynamically changes as objects of template instances are 
            created and destroyed. Adding and removing objects 
            from this kind of list is not allowed. 

    Example:

        .. code-block::
            python

            from neuron import n

            clamps = n.IClamp(), n.IClamp(), n.IClamp()

            all_iclamps = n.List('IClamp')
            print(f'There are initially {len(all_iclamps)} IClamp objects.') # 3

            another = n.IClamp()

            print(f'There are now {len(all_iclamps)} IClamp objects.')       # 4

         

----



.. method:: List.append


    Syntax:
        ``l.append(object)``


    Description:
        Append an object to a list, and return the number of items in list. 

         

----



.. method:: List.prepend


    Syntax:
        ``l.prepend(object)``


    Description:
        Add an object to the beginning of a list, and return the number of objects in the list. 
        The inserted object has index=0.  Following objects have an incremented 
        index. 

         

----



.. method:: List.insrt


    Syntax:
        ``l.insrt(i, object)``


    Description:
        Insert an object before item *i*, and return the number of items in the list. 
        The inserted object has index *i*, following items have an incremented 
        index. 
         
        Not called :ref:`insert <keyword_insert>` because that name is a HOC keyword.

         

----



.. method:: List.remove


    Syntax:
        ``l.remove(i)``


    Description:
        Remove the object at index *i*. Following items have a decremented 
        index. ie it's often most convenient to remove items from back 
        to  front. Return the number of objects remaining in the list. 

         

----



.. method:: List.remove_all


    Syntax:
        ``l.remove_all()``


    Description:
        Remove all the objects from the list. Return 0. 

         

----



.. method:: List.index


    Syntax:
        ``l.index(object)``


    Description:
        Return the index of the object in the ``List``. Return a -1 if the 
        object is not in the ``List``.

        This is approximately analogous to the Python list method ``.index()``,
        except that the method for Python lists raises a ``ValueError`` if the
        object is not in the list.
         

----



.. method:: List.count


    Syntax:
        ``l.count()``


    Description:
        Return the number of objects in the list.
        
        This is mostly useful for legacy code. A more Python solution is to just use ``len(my_list)``.

         

----



.. method:: List.browser


    Syntax:
        ``l.browser()``

        ``l.browser("title", "strname")``

        ``l.browser("title", py_callable)``


    Description:


        ``l.browser(["title"], ["strname"])`` 
            Make the list visible on the screen. 
            The items are normally the object names but if the second arg is 
            present and is the name of a string symbol that is defined 
            in the object's	template, then that string is displayed in the list. 

        ``l.browser("title", py_callable)`` 
            Browser labels are computed. For each item, ``py_callable`` is executed 
            with ``n.hoc_ac_`` set to the index of the item. Some objects 
            notify the List when they change, ie point processes when they change 
            their location notify the list. 

    Example:

        .. code-block::
            python

            from neuron import n, gui

            my_list = n.List()

            for word in ['Python', 'HOC', 'NEURON', 'NMODL']:
                my_list.append(n.String(word))

            my_list.browser('title', 's')   # n.String objects have an s attribute that returns the Python string


        .. image:: ../../images/list-browser1.png
            :align: center
                    
    Example of computed labels:

        .. code-block::
            python

            from neuron import n, gui

            my_list = n.List()
            for word in ['NEURON', 'HOC', 'Python', 'NMODL']:
                my_list.append(n.String(word))

            def label_with_lengths():
                item_id = n.hoc_ac_
                item = my_list[item_id].s
                return f'{item} ({len(item)})'

            my_list.browser('Words!', label_with_lengths)

        .. image:: ../../images/list-browser2.png
            :align: center

        If we now execute the following line to add an entry to the List, the new entry will appear in the browser immediately:         

        .. code-block::
            python

            my_list.append(n.String('Neuroscience'))

        .. image:: ../../images/list-browser2b.png
            :align: center

----



.. method:: List.selected


    Syntax:
        ``l.selected()``


    Description:
        Return the index of the highlighted object or -1 if no object is highlighted. 

    .. seealso::
        :meth:`List.browser`

         

----



.. method:: List.select


    Syntax:
        ``l.select(i)``


    Description:
        Highlight the object at index *i*. 

    .. seealso::
        :meth:`List.browser`

         

----



.. method:: List.scroll_pos


    Syntax:
        ``index = list.scroll_pos()``

        ``list.scroll_pos(index)``


    Description:
        Returns the index of the top of the browser window. Sets the scroll so that 
        index is the top of the browser window. A large number will cause a scroll 
        to the bottom. 

    .. seealso::
        :meth:`List.browser`

         

----



.. method:: List.select_action


    Syntax:
        ``l.select_action(command)``

        ``l.select_action(command, False or True)``


    Description:
        Execute a command (a Python funciton handle) when an item in the 
        list :meth:`List.browser` is selected by single clicking the mouse. 
         
        If the second arg exists and is True (or 1) then the action is only called on 
        the mouse button release. If nothing is selected at that time then 
        :data:`hoc_ac_` = -1 

    Example:

        .. code-block::
            python

            from neuron import n, gui

            my_list = n.List()

            def on_click():
                item_id = my_list.selected()
                if item_id >= 0: # check to make sure selection isn't dragged off
                    print(f'Item {item_id} selected ({my_list[item_id].s})')


            for word in ['Python', 'HOC', 'NEURON', 'NMODL']:
                my_list.append(n.String(word))

            my_list.browser('title', 's')
            my_list.select_action(on_click)


        .. image:: ../../images/list-browser1.png
            :align: center
                    
         

----



.. method:: List.accept_action


    Syntax:
        ``l.accept_action(command)``


    Description:
        Execute a command (a Python function handle) when double clicking 
        on an item displayed in the list :meth:`List.browser` by the mouse. 

        Usage mirrors that of :meth:`List.select_action`.


         

----



.. method:: List.object


    Syntax:
        ``l.object(i)``

        ``l.o(i)``


    Description:
        Return the object at index *i*. 
        
        This is mostly useful for legacy code. In Python, use, e.g. ``my_list[i]`` instead.

         

----



.. method:: List.o


    Syntax:
        ``l.object(i)``

        ``l.o(i)``


    Description:
        Return the object at index *i*. 
        
        This is mostly useful for legacy code. In Python, use, e.g. ``my_list[i]`` instead.



