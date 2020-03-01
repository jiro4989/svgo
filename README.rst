====
svgo
====

This is svgo, a small utility to create SVG objects.
This was inspired by `jpmens/jo <https://github.com/jpmens/jo>`_.

Usage
=====

.. code-block:: shell

   svgo -W 200 -H 200 circle cx=100 cy=100 r=80 stroke=teal fill='#DDD' out.svg
   seq 0 10 100 | svgo -W 200 -H 200 circle cx=100 cy=100 r='$1' stroke=teal fill='#DDD' -O 'out_$1.svg'
   seq 10 | awk '{print $1, $1*10}' | svgo -W 200 -H 200 circle cx='$2' cy=100 r='$1' stroke=teal fill='#DDD' -O 'out_$1_$2.svg'
   svgo -W 200 -H 200 circle cx=100 cy=100 r=80 stroke=teal fill="#DDD" out.svg
   svgo -W 200 -H 200 [ circle cx=100 cy=100 r=80 stroke=teal fill="#DDD" ] out.svg
   svgo -W 200 -H 200 [ g [ circle cx=100 cy=100 r=80 stroke=teal fill="#DDD" ] [ circle cx=100 cy=100 r=80 stroke=teal fill="#DDD" ] ] out.svg
   svgo -W 200 -H 200 [ g [ circle cx=100 cy=100 r=80 stroke=teal fill="#DDD" ] [ circle cx=100 cy=100 r=80 stroke=teal fill="#DDD" ] ] -
