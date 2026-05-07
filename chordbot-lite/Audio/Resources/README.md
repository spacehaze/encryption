# Audio Resources

The app expects a SoundFont file named **`GeneralUser-GS.sf2`** in this folder
at build time. The file is gitignored (~30 MB) — fetch it once with:

```sh
cd chordbot-lite
./Scripts/fetch-soundfont.sh
```

That downloads [GeneralUser GS](https://schristiancollins.com/generaluser.php)
(SCC license, free for any use) and renames it to `GeneralUser-GS.sf2` so
`AudioEngine` can find it via `Bundle.main.url(forResource:withExtension:)`.

If you'd rather use a different SoundFont, drop it here under the same name —
or change the constant in `Audio/AudioEngine.swift`.
