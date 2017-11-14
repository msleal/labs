#!/usr/bin/python
#byLeal

import requests
import random
import sys

#Simple validation...
if (len(sys.argv) != 2):
	print ">> You need to provide the number of votes..."
	exit(1)

#Ok, let's do our civil duty...
x=0; candidates=['a', 'b'];
while (x < int(sys.argv[1])):
	prefer = "Dogs";
	vote = random.choice(candidates);
	if (vote == "a"):
		prefer = "Cats";
	r = requests.post('http://localhost:5000', data = {'vote':vote});
	if (r.status_code == 200):
		print("Vote Number: " + str(x) + " for: " + prefer);
	else: 
		print("Error Voting!");
	x+=1;
