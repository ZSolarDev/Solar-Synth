## 4/20/2025-1:24 AM || Just got project saving and loading done. yay....
...I felt like I had the brain of an ant when making this. Idk how programmers just code through the night like this, my brain is so slow right now. I made the stupidest mistakes making this that made it take so much longer than it should have. I'm typing this at abnormally slow speeds right now, I'm going to bed now.

## 4/20/2025-11:07 AM || *A plan.*
I have a plan. My old broken method for pitch shifting was time stretching preserving pitch(currently has a nasty undertone for some reason), pitch shifting via shrinking/stretching sample without preserving pitch, and formant shifting(completly busted...). Instead of trying to fix that, I just realized something existed. ***libESPER;*** a resampler. I can create Hashlink externs for it, and use it to pitch/formant shift the samples. I'm using hashlink externs cause hashlink works across Windows, MacOS, and Linux. Wish me luck..!

## 4/21/2025-8:22 AM || libESPER Day 2
Ok so its not working correctly(and by that I mean It's doing nothing to the audio.). I'll figure this out when I get back from school.

## 4/21/2025-9:45 AM || libESPER Day 2
Ok now the extern is but Isn't linking back to haxe? Like it registers the function but doesn't actually run the extern function code. I don't know what I did wrong..

## 5/17/2025-7:52 PM || I surrender.
libESPER Isn't happening. It's close, I just ran out of patiance. I just needed to use esperUtau in the externs, but even that wouldn't work. I don't know what I did wrong. I might just need to straight up use Esper-Utau in parralel on the cpu. I will hate myself for this, but it might be fast enough.

## 5/20/2025-7:50 AM || Uh Oh..
I couldn't even make it run parallel on the cpu! What am I even expecting anymore? Not even my 3 years if programming can help me. Not to mention but I have my biology final and my theatre show today. Ugh!

## 5/20/2025-8:26 AM || ANOTHER PLAN
THIS MIGHT WORK, TRUST ME.
I only needed libESPER for pitch shifting originally. Once I found out I can change things like breathiness, dynamics, etc, I got hooked. I thought I could have a normal render mode where it used samples from the voicebank, and a mode where it used libESPER. I thought I needed a new pitch shifting method when that extra side-tangent failed, then I realized what I originally wanted libESPER for; pitch shifting.

I realized I just needed to render the final result of the vocal synthesis into a file and shove it into libESPER with pitch bend curves. Some parts might have to go in again due to it being outside of the original 2 octave range, but the concept is still the same. This also means I don't need externs, only the resampler. That also means people can use a resampler of their choice.

The best part of this is that I can still have a libESPER mode; automation just won't be supported, though. Only one value per note. Also render times are increased significantly due to the extra step of resampling every note individually.

Also note duration is quite a struggle for the synthesis engine currently, so I thought of a fix. With the program used to make the voicebank(I'm making my own,) I will add a button to generate a cache with the voicebank. This will run every sample through the resampler to extend the samples length to 30 seconds if it isn't already that long. You can also flag a sample to not go through the resampler. If the resampler is Esper-UTAU, it will generate frequency and esper files that are put into the cache as well. This all means that I'll only have to resample a note if either there is no cache and the og sample isn't long enough, or if the cached sample isn't long enough. Best part is if the cache uses Esper-UTAU and you're using Esper-UTAU, the resampler will be much faster if there is a cache due to the already existing frequency and esper files.

This could work!

## 5/20/2025-8:47 PM || Seriously...?
I knew there was a chance ESPER-Utau might not like the fact that I stuffed more than 1 phoneme in it, but it was unhappier than I thought. The resulting noise came out distorted, almost crunchy. I'll ask CdrSonan if he can give suggestions.

## 5/26/2025-4:36 PM || ESPER-UTAU INTEGRATION NEARLY COMPLETE!!!!
WHOOOOOOOOOO! I finally got it working! You know how I was talking about ESPER-Utau running in parralel on the CPU? I thought It would never work, but I got it working! I'm so happy! All I need to do is skip past the strange pops and make note length longer than required to minimize the fade out and it's done! A MONTH AND 6 DAYSSSS

## 5/27/2025-1:53 PM || ESPER-UTAU INTEGRATION COMPLETE.
Everything works. It all works. There were some bugs that leaked through but after extensive testing today, I've concluded it works well. The downside is that It takes 10~ seconds to run including the .esp files being transfered over, but I have a decent solution. Instead of synthesizing the entire section when pressing play, I can pre-synthesize it when a note is edited. The only issue with that is that if you modify a note while ESPER-Utau is running, it will take a second to wait for the previous ESPER-Utau's to complete before restarting the synthesization process to ensure file names don't collide. I've made it so far.... all I need is improved phoneme blending and realism and the synthesis is done.

## 5/31/2025-4:17 PM || Bye Flixel, hello HaxeUI!
I'm replacing Flixel with HaxeUI after finding out how much more sophisticated it is after finding out it's much more extensive and sophisticated at UI than Flixel. Also, someone is going to be helping me with the frontend: Aura! We have both never used HaxeUI, so It's going to be a first time for the both of us. I hope this goes well!