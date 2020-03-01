====
svgo
====

This is svgo, a small utility to create SVG objects.
This was inspired by `jpmens/jo <https://github.com/jpmens/jo>`_.

.. contents:: Table of contents

Usage
=====

Basic usage
-----------

`-W` is a width of `svg` tag elements.
`-H` is a height of `svg` tag elements.
Default values are `200`.

.. code-block:: shell

   $ svgo -W 400 -H 400 [ circle cx=200 cy=200 r=200 stroke=teal fill='#DDD' ]

   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
   <svg version="1.1" width="400" xmlns="http://www.w3.org/2000/svg" height="400"><circle cy="200" cx="200" fill="#DDD" stroke="teal" r="200" /></svg>

Save file. (`-o`)

.. code-block:: shell

   $ svgo -o out.svg [ circle cx=200 cy=200 r=200 stroke=teal fill='#DDD' ]

Nested elements.

.. code-block:: shell

   $ svgo [ g [ circle cx=100 cy=100 r=80 stroke=teal fill="#DDD" ] [ circle cx=100 cy=100 r=80 stroke=teal fill="#DDD" ] ]

   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
   <svg version="1.1" width="200" xmlns="http://www.w3.org/2000/svg" height="200"><g>
       <circle cy="100" cx="100" fill="#DDD" stroke="teal" r="80" />
       <circle cy="100" cx="100" fill="#DDD" stroke="teal" r="80" />
     </g></svg>

Special variables
-----------------

Field variables ($1, $2, ... $NF)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Records are read in stdin at a time, and stored in the field variables.
The record is split into fields which are stored in $1, $2, ..., $NF like `awk`
when activate `-i (--use-stdin)` flag.

.. code-block:: shell

   $ seq 3 | svgo -i [ circle cx=100 cy=200 r='$1' ]

   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
   <svg version="1.1" width="200" xmlns="http://www.w3.org/2000/svg" height="200"><circle cy="200" cx="100" r="1" /></svg>
   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
   <svg version="1.1" width="200" xmlns="http://www.w3.org/2000/svg" height="200"><circle cy="200" cx="100" r="2" /></svg>
   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
   <svg version="1.1" width="200" xmlns="http://www.w3.org/2000/svg" height="200"><circle cy="200" cx="100" r="3" /></svg>

.. code-block:: shell

   $ seq 3 | awk '{print $1, $1*10}' | svgo -i [ circle cx='$1' cy='$2' r='$1' ]

   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
   <svg version="1.1" width="200" xmlns="http://www.w3.org/2000/svg" height="200"><circle cy="10" cx="1" r="1" /></svg>
   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
   <svg version="1.1" width="200" xmlns="http://www.w3.org/2000/svg" height="200"><circle cy="20" cx="2" r="2" /></svg>
   <?xml version="1.0" encoding="UTF-8" ?>
   <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
   <svg version="1.1" width="200" xmlns="http://www.w3.org/2000/svg" height="200"><circle cy="30" cx="3" r="3" /></svg>

Current record number (NR)
^^^^^^^^^^^^^^^^^^^^^^^^^^

TODO

Animation GIF
-------------

.. code-block:: shell

   $ (seq 1 10 100; seq 100 -10 0) | svgo [ circle cx=100 cy=100 r='$1' ] -in -w 3 -o 'out_$NR.svg'
   $ convert -density 1200 -resize 200x200 out_*.svg anim1.gif

|image-demo-anim1|

.. code-block:: shell

   $ (seq 5 | awk '{print $1 * 40, 200}' | tee >(awk '{print $2, $1}')) | svgo [ rect x=0 y=0 width='$1' height='$2' ] -ino 'out_$NR.svg'
   $ convert -resize 200x200 out*.svg anim2.gif

|image-demo-anim2|

.. code-block:: shell

   $ yes 'echo $((RANDOM % 200)) $((RANDOM % 200))' | head | bash | svgo [ circle cx='$1' cy='$2' r='50' ] -ino 'out_$NR.svg'
   $ convert -resize 200x200 out*.svg anim3.gif

|image-demo-anim3|

Installation
============

.. code-block:: shell

   $ nimble install -Y svgo

LICENSE
=======

MIT

.. |image-demo-anim1| image:: ./docs/anim1.gif
.. |image-demo-anim2| image:: ./docs/anim2.gif
.. |image-demo-anim3| image:: ./docs/anim3.gif

