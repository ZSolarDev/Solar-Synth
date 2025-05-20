## Build 614, 4/20/2025-1:24 AM || Just got project saving and loading done. yay....
...I felt like I had the brain of an ant when making this. Idk how programmers just code through the night like this, my brain is so slow right now. I made the stupidest mistakes making this that made it take so much longer than it should have. I'm typing this at abnormally slow speeds right now, I'm going to bed now.

## Build 614, 4/20/2025-11:07 AM || *A plan.*
I have a plan. My old broken method for pitch shifting was time stretching preserving pitch(currently has a nasty undertone for some reason), pitch shifting via shrinking/stretching sample without preserving pitch, and formant shifting(completly busted...). Instead of trying to fix that, I just realized something existed. ***libESPER;*** a resampler. I can create Hashlink externs for it, and use it to pitch/formant shift the samples. I'm using hashlink externs cause hashlink works across Windows, MacOS, and Linux. Wish me luck..!

## Build 614, 4/21/2025-8:22 AM || libESPER Day 2
Ok so its not working correctly(and by that I mean It's doing nothing to the audio.). I'll figure this out when I get back from school.

## Build 614, 4/21/2025-9:45 AM || libESPER Day 2
Ok now the extern is but Isn't linking back to haxe? Like it registers the function but doesn't actually run the extern function code. I don't know what I did wrong..

## Build 614, 5/17/2025-7:52 PM || I surrender.
libESPER Isn't happening. It's close, I just ran out of patiance. I just needed to use esperUtau in the externs, but even that wouldn't work. I don't know what I did wrong. I might just need to straight up use Esper-Utau in parralel on the cpu. I will hate myself for this, but it might be fast enough.