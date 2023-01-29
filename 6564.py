from icecream import ic

notes = [-2, 0, 2, -2, 0, 2, -2, 0, -2, 0, 2, -2, 0, 2, -2, 0]
notes = notes + [-2, 0, 3, -2, 0, 3, -2, 0, -2, 0, 3, -2, 0, 3, -2, 0]
notes = notes + [-3, -1, 2, -3, -1, 2, -3, -1, -3, -1, 2, -3, -1, 2, -3, -1]
notes = notes + [-3, -1, 1, -3, -1, 1, -3, -1, -3, -1, 1, -3, -1, 1, -3, -1]
notes = notes + [3]
octaves = [0, 0, 0, 12, 12, 12, 24, 24]

scale_name = ["c", "d", "e", "f", "g", "a", "b"]
scale_num = [0, 2, 4, 5, 7, 9, 11]
last_note = None
music = ["", ""]
for i in range(64 * 12):
    note_num = (
        scale_num[notes[i % len(notes)] % len(scale_num)] + octaves[i % len(octaves)]
    )
    note_name = scale_name[notes[i % len(notes)] % len(scale_name)]
    # print(note, name, note_num)
    j = 1  # treble
    if i % 8 < 4:
        j = 0  # bass

    # bfigure out octaive string
    octave_string = ""
    if note_num >= 17:
        # treble
        octave_string = "'"
        if note_num >= 24:
            octave_string = "''"
        lily = f"{note_name}{octave_string}8 "
        ic(i, note_num, note_name, lily)
        music[1] += lily
        music[0] += "r8 "
    else:
        if note_num >= 12:
            octave_string = "'"
        lily = f"{note_name}{octave_string}8 "
        ic(i, note_num, note_name, lily)
        music[0] += lily
        music[1] += "r8 "

s = """\\header {
  title = "65/64"
  composer = "infinite digits"
      tagline = ##f
}
"""
s += "\\repeat volta 2 <<\n"
s += '\\new Staff { \\clef "treble" ' + music[1] + "}\n"
s += '\\new Staff { \\clef "bass" ' + music[0] + "}\n"
s += ">>\n"

s = s.replace("r8 r8 r8 r8", "r2")
s = s.replace("r8 r8", "r4")
print(s)
