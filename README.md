muntzbot
========

A simple Twitter bot that responds to the mention of "Nelson Muntz" with his characteristic laugh.

Changelog
=========

+ 1.0.5 - Better parroting of laughs, using regex for "Haw haw!", "Ha ha!", and "¡Ja ha!".
+ 1.0.4 - Timestamps on all logs and moved Twitter credential variables to the top of the file. Also, searching for “haw” string, so that I can more accurately mimic the expected laugh type.
+ 1.0.3 - I can’t remember what I changed in this version. :-(
+ 1.0.2 - Was only waiting a second between updates. Had code to make it uniform between 15 and 30, but must have left sleep(1) in there while debugging.
+ 1.0.1 - Changed update functionality so it is replying to tweet rather than a stand alone.

Component List
==============

+ Server (currently using cheapest available EC2 instance)
+ Ruby
	+ JSON Gem
	+ Twitter Gem
+ Twitter account
+ Text file (for data persistence)
+ Cron

Pseudocode 
==========

1. Cron launches process at predetermined interval.
2. Process grabs last known Twitter ID from text file.
3. Search is made for phrase asking for items newer than ID.
4. Response is parsed into individual items.
5. Items are re-verified to make sure they contain desired phrase.
6. Response is chosen from predetermined weighted list.
7. Response is sent, if last known ID was found in step 2. Otherwise, skip responding this round.
8. Last known ID is written back to file.

License
=======

Code is available under a BSD-style license. See the included LICENSE file for details.

