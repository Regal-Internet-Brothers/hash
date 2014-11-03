hash
====

A module containing several (Currently two) hashing functions for the [Monkey programming language](https://github.com/blitz-research/monkey).
Most notably: A multi-input MD5 implementation, and a quick rewrite of Java's 'hashCode' command.

The MD5 implementation is still rather slow with large files, but it's far faster than the alternatives currently. One of the benefits of my MD5 implementation is the smaller memory footprint. Add together the memory optimizations, the variety of container-backends, input-types, and a good compiler, and this should work well for realistic use. That being said, there are other implementations. So, if this doesn't fit your project, I'd recommend looking at the *"Special Thanks"* and *"Other References"* sections.

[Loosely based on the MD5 implementations provided by the Monkey community.](http://www.monkey-x.com/Community/posts.php?topic=3483)

*Special Thanks:*

* [Goodlookinguy, for his 'logical shift right' code, which this is based on.](http://www.monkey-x.com/Community/posts.php?topic=1707&post=83963)
* Craig Kiesau, for his original MD5 function written in BlitzBasic.
* Fred, for his original port of Craig's BlitzBasic code.
* Xaron, for his 'Strict' compatible version of Fred's code.

*Other References:*
* ["MD5 Shootout" by BitBucket user Rory "rplaire" Plaire.](https://bitbucket.org/rplaire/md5-shootout/)
* [RosettaCode's MD5 implementation page. (And the people behind it)](http://rosettacode.org/wiki/MD5/Implementation)
* [Wikipedia's MD5 pseudocode example.](http://en.wikipedia.org/wiki/MD5#Pseudocode)
