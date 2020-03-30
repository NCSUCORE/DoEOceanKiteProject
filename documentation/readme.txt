MATLAB files and their functions:
1. multinode_wing_tail: Main file which contains all simulation parameters.
						Run this file to run code.
2. calc_ini_tension: function to calculate initial elongation of the tethers
					 I wrote this code to minimize the initial oscillation in the
					 system due to starting at non-equilibrium conditions.
3. design_tether: This function chooses tether diameter based on the maximum 
				  expected load at a given operating flow speed and maximum
				  percentange elongation allowed
4. intermediate nodes: This function simply calculates the positions of the 
					   nodes between the first and last node to start the 
					   simulation
5. rotation_sequence: contains euler rotation matrices
6. VS_and_HS_design: I wrote this code to estimate the aerodynamic centers of
					 the vertical and horizontal stabilizers and some other 
					 parameters. 
			

Simulink files and their functions:
1. OCT array ready: This file contains references the multinode_simulink.slx model
					This one becomes useful when simulating an array. 
2. multinode_simulink: This file is main simulink file used to drive the simulation.


					 
				  
					