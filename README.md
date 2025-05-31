> [!WARNING]  
> Solar Synth is no where near complete! Builds might not be released for a long time.

<h2 align="center">
  <img width="1000" src="https://raw.githubusercontent.com/ZSolarDev/Solar-Synth/refs/heads/main/assets/Banner.png">
  <br> A vocal synthesis engine built to bridge the gap between free tools and high-end vocal synths without sacrificing creative freedom.
</h2>

# About Solar Synth
### What *exactly* is Solar Synth?
If you read the top and would like to know more, I'll tell you more. By free tools I'm reffering to things such as [Utau](http://utau2008.xrea.jp/) and [OpenUtau](https://www.openutau.com). By high-end vocal synths, I'm reffering to programs like [Vocaloid](https://www.vocaloid.com/en/) and [SynthesizerV](https://dreamtonics.com/synthesizerv/); and I'm sure you can grasp what "creative freedom" means. When this program releases, I hope for it to be easy to use, customizable, and high quality.

<br>

### About Voicebanks...
Making a voicebank(a collection of samples that the program synthesizes into a voice) for this program doesn't require "otoing"(a very tedious process.) Although, you could say it got replaced with the option to record countless samples for vocal variations. You don't have to, and you really only have to record long samples of you saying each character of the japanese alphebet once. I plan to make an assisting program that basically acts like a little helper to guide you though making your own Solar Synth voicebank. 

<br>

### What does it sound/look like?
TODO WHEN UI/VOCAL TEST SAMPLES ARE COMPLETE

<br>

### Why did I make Solar Synth?
For this, I need to talk more in depth about Utau, OpenUtau, SynthesizerV, and Vocaloid. If you don't know what those are, keep reading(skip to the next paragraph if you are familiar with all of these programs.) A *voicebank*, is a collection of short audio files called phonemes of that persons voice that your vocal synthesis program synthesizes into speech. Each program listed has their own formatting to voicebanks; A voicebank made for this single program only supports that single program, and someone will have to manually port it to another program if they don't want to use it in that program alone. Vocaloid by Yamaha is a paid, multilingual popular yet not beginner friendly vocal synthesizing program. It's like a blank slate; if you don't know what you're doing, what you make will sound horrible. Utau is a multilingual vocal synthesis engine, and It's tricky if you don't know what you're doing due to its dated interface. In Utau, the quality of your vocals really depends on the voicebank you use; There are a small selection of super realistic voicebanks for Utau, but a majority of voicebanks sound a bit(or extremely) robotic. Utau has another problem, Parameters. If you want to fluxuate between a soft and a powerful voice, you would need another version of that voicebank thats powerful and soft and edit both files together in an external program. OpenUtau is basically Utau but open source(code is public) with a much cleaner more modern interface, and is a special exception to the voicebank rule I mentioned earlier; It supports utau voicebanks. Some voicebanks have specific OpenUtau versions, and voicebanks with vocal variations(soft, tense, powerful, etc.) might have a specific OpenUtau version that merges all variations into 1 voicebank. OpenUtau supports voice variation shifting unlike Utau. Finally, SynthesizerV is a paid multilingual realistic vocal synthesis program; I personally really like it due to its quality, ease of use, and customizability. The catch is that it costs a lot of money; a lot of money that *I* and many others don't have. This context lets me explain further.

I realized that there was nothing free that was of similar quality to SynthV. I basically just said, "f*ck it, I'll just do it myself." I started this when I was 12 and look where I am now..

### Credits
Johannes Klatt([CdrSonan](https://github.com/CdrSonan)), the creator of [ESPER-Utau](https://github.com/CdrSonan/ESPER-Utau). I'm using it for the synthesis engine.

[Wikiti](https://gitlab.com/wikiti)/[Wikiti - Random stuff](https://gitlab.com/wikiti-random-stuff/), the creator of [hxIni](https://gitlab.com/wikiti-random-stuff/hxini). I'm using it for the voicebank system.
<br>
<br>

# Want more info?
To find more info such as how to use it, mod it, where to get voicebanks from, etc, look at the Solar Synth website here: TODO

<br>
<br>

# TODO
## Goals:
 - [X] Finish Startup Visuals(Loading)
   - Add more stuff to load if needed..
 - [ ] Finish Start Menu UI - (rest of the ui require systems that are currently being worked on(ex. project loading, settings, voicebanks, etc.))
 - [X] Finish Synthesis Engine
    - [X] Add pitch
        - [X] Get it working
        - [X] Add multi-octave support(4 octaves is enough for now.)
    - [X] Add note lenth increasing
    - [X] Improve Phoneme blending
 - [ ] Haxe Plugin system
    - [ ] A way to add more right-click options to any built-in dropdowns or just custom dropdowns anywhere
    - [ ] A way to add buttons to the top bar
    - [ ] A way to interface with the Synthesis Engine
        - [ ] A way to interface with the Note processor
        - [ ] A way to interface with the Vocal Generator
 - [ ] Create Project Editor
    - [X] Add .ssp(solar synth project) file support for saving and loading projects
    - [ ] Voicebank UI (Finish voicebank system before doing this.)
    - [F] Track System
        - [F] Section System
            - [F] Some sections have notes, some have audio.
    - [ ] Track Viewer UI (Finish track system before doing this.)
        - [ ] Clear section viewing
        - [ ] Section selection
            - [ ] Hold left click and drag to move sections around
            - [ ] Hold left click and drag at the edges of a section to resize it
            - [ ] Right click to open a little menu
                - [ ] Delete section
                - [ ] Duplicate section
                - [ ] Copy section
                - [ ] Change section name
                - [ ] Change section bpm
    - [ ] Piano Roll
        - [ ] Visual note system
            - [ ] Visual note rendering
            - [ ] Note editing
            - [ ] Note selection
                - [ ] Note mass-editing
                    - [ ] Left click and drag to move the notes around along with all of their parameters
                        - [ ] It wont move in that direction if there is a note on the same region(vertically)
            - [ ] Note copy pasting
            - [ ] Hold left click and drag at the edges of a note to resize it
                - [ ] It wont resize in that direction if there is a note on the same region(vertically)
            - [ ] Hold left click and drag a note to move it around
                - [ ] It wont move in that direction if there is a note on the same region(vertically)
            - [ ] Right click a note to delete it (keeping the parameters there)
        - [ ] Parameter automation editor(pitch parameter automation line will render over notes and be editable over the notes via pencil tool for easier usage. Everything else will be in a bottom tab like OpenUtau. The bottom tab will have a pencil, eraser(bringing it back to its default value), and a line tool.)
    - [ ] Main Bar
        - [ ] Current bpm
        - [ ] Time signature
        - [ ] Playback controls
        - [ ] Waveform display(toggleable via global options)
        - [ ] Project name display(user can't edit it from here though, they can only edit it from the project config.)
        - [ ] Misc things that I don't feel like adding here
        - [ ] Undo/Redo
    - [ ] Right Bar
        - [ ] Voicebank paramaters with a section at the top with the voicebank name and the voicebank icon. there is also an option for a banner at the top with a custom image(a setting with the voicebank itself.)
            - [ ] Area for default voicebank parameters: mouth, power, breathiness, and gender.
            - [ ] Area for custom presets with the a parameter preset and the option to have custom haxe code run either during note processing when processing all notes queued, after a vocal stem(a specific paramater such as mouth, softness, etc.) is done rendering, and/or after all vocal stems are done being merged into 1 Bytes instance before Sound conversion.
    - [ ] Bottom Bar
        - [ ] Extra text saying things like whats processing and a flxbar saying the progress of the task.
    - [ ] Top-Tabs
        - [ ] Plugin management(do plugin system first.)
        - [ ] Project saving/loading (finish system before this)
        - [ ] Project rendering
        - [ ] Project config
            - [ ] Voicebank switcher(with functionality to import voicebanks)
                - [ ] Make sure it warns user about unsupported parameters
            - [ ] Edit project name
            - [ ] Threads Reserved while rendering
        - [ ] General settings(opens a substate with a camera with the settings tab from the start menu ui, then when done, reload the editor state with a warning saying it will clear undo history.)
    - [ ] General Copy/Paste System
    - [ ] General Redo/Undo System
 - [ ] Voicebank System
    - [ ] Add .ssvb(solar synth voicebank) file support for saving(in another program) and loading voicebanks
    - [ ] Make program to create them(After SS is done)
 - [ ] exe-file interaction
    - [ ] Add ability to drag and drop a project/voicebank into solar synth
    - [ ] Add ability to open a project/voicebank with solar synth
    - [ ] Add custom file icons
 ### Good job to have gotten this far, future me! Never thought I would get this far! I am so proud of you!! Lets move on to the next set of goals, we're almost done!
 - [ ] Get youtubers to test Solar Synth via email and hope! Repeat this process until a good number of youtubers are happy with it.
 - [ ] Update the version number. (Major.Minor.Patch-BuildNum)
 - [ ] Make a webite via compiling haxeui to html5. Host it on a new render account.
    - [ ] Main page
        - [ ] Logo/big fancy eye-catching banner
        - [ ] Most recent announcement
        - [ ] Media pages(youtube, discord, twitter/bluesky, etc.)
        - [ ] Describe what Solar Synth is
        - [ ] Describe what Solar Synth can do
        - [ ] Describe what Solar Synth was meant to do/why I made it
    - [ ] Normal docs page on how to use it with videos to help
    - [ ] Getting started page
    - [ ] Plugin docs page
    - [ ] QnA page
    - [ ] Changelog page
    - [ ] Download page
    - [ ] Samples page(video samples)
    - [ ] Voicebanks page
    - [ ] Announcements page
    - [ ] Github repository for said website
    - [ ] A blog page
        - [ ] Funny Development stories with sounds and video snippets
        - [ ] Anything else important
    - [ ] add a link to the github repository to Solar Synth
    - [ ] add a link to the issues page in the Solar Synth repository
    - [ ] Contact page
    - [ ] Find people to help make a few voicebanks that are available for download on the Solar Synth website.
        - [ ] Actually find people for the voicebanks
        - [ ] For file downloading, make another render website, this one will be made in nodejs and it will download a file based on what you requested and close itself after downloading it.
    - [ ] Pin the website second repository to my top repositories on my profile
    - [ ] Make a youtube video announcing its release, documenting what it can do, and using the various voicebanks for a multitude of example songs. Try to get example covers that the youtubers from before had made; But don't release it quite yet, read the next step.
    - [ ] Try to start building a community and establish a release date after the video is done. That way everything will be ready to go when the release date is hit. Make the release date quite far as this is your first time releasing anything that has *this* much potential.
    - [ ] Release Solar Synth if all goes well..!

## Current Todo:
 - [X] Make a GitHub repository so I don't lose my progress at all
    - [X] Make branding and a huge fancy readme with what Solar Synth is, then Solar Synths backstory. Then maybe add a hardcoded sample or 2 if audio previews work with GitHub markdown after pitch shifting is fixed(That last part is optional, cause I'll most-likely run out of gas after typing up the entire readme.)
    - [X] Pin Solar Synth to my top repositories on my profile
 - [X] Finish Synthesis Engine
 - [ ] Make a hardcoded sample of the synthesis engine using the temporary teto lite voicebank I made in like an hour, then show it to friends and feel good about myself.
 - [ ] Take a break from this project when previous tasks are complete.
    - I feel like I deserve this break. I've been working hard on this since March 19th, and I've already gotten this much done within a couple of months. A whole japanese vocal synthesis engine! SOLO!!! I'm not a huge expensive crazy corporation at all, and I managed to make an entire synthesis engine with 0$ and half of my sanity per day spent. Impressive if I say so myself. Also, I just genuinely need time to work on things that *actually* need to be done irl(especially that one school project. UPDATE: Already finished it. It's already summer, this took so much longer than I thought!)
    - [ ] Actually take a break for a few days so you don't get burnt out, burn out will be an issue. ESPECIALLY when doing the tedious task of editor ui.

## Bugs:
 - Some consonants sound off after resampling.
 - Strange pops in some consonants after resampling.

## Future Goals:
 - [ ] Make a mod application form
 - [ ] Make available on mac/linux
 - [ ] Add build-in multilingual support
 - [ ] Utau support
    - [ ] Ust (shouldn't be that hard..)
    - [ ] Voicebanks (I have to find out how to read an oto.ini and convert samples to work with Solar Synth)
 - [ ] Themes
    - [ ] Custom themes
 - [ ] Reach out to Twindrill to ask if they're down for making a Kasane Teto voicebank for Solar Synth(I'm broke at the time of writing and they prob gonna ask for hella moneyyy 😭😭)
