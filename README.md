fssp
====

This is fssp, a MATLAB(R) script for solving the firing squad synchronization problem 
and creating a cross-stitch pattern from the solution.

For more information, please read the headers of the MATLAB(R) source files or the Wikipedia article on this problem [1].

Statement of the Problem
----

Consider a finite but arbitrary number of identical finite state machines
(soldiers) arranged in a line. 

At time t = 0, each soldier is initialized to the quiescent (idle) state, 
except for the soldier on the far left (the Officer). 

The state of each soldier at each discrete time-step t > 0
is dependent on its state and the state of its two neighbors at time
t - 1 (except for the two soldiers at either end, each of whose state
depends only on itself and its sole neighbor). 

In addition, if a soldier and its neighbors are in the quiescent state, 
then the soldier will remain quiescent at the next time-step. 

**The problem** is to define a finite set of states and state transition 
rules for the soldiers such that all soldiers enter a distinguished 
state (fire) at the same time and for the very first time.

Interest
----

This project came about after purchasing the cross-stitch / needlepoint 
DIY case for iPhone 4 [2,3] and wanting to create a design that was just
my style.

After looking at Cellular Automota / simple programs I found this pattern
to be visually appealing, as well as providing a computation challenge in
coding up the answer to fit any size cross-stitch design.

Development
----

Please feel free to make changes, offer suggestions, and help me port this to
other languages of interet.  Thanks!

References
----

[1] http://en.wikipedia.org/wiki/Firing_squad_synchronization_problem

[2] http://connectdesign.co.kr/front/php/product.php?product_no=170

[3] http://www.thinkgeek.com/product/ea9f/
