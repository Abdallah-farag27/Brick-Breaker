import os
import subprocess
from time import sleep

filedata = r"""
[cpu]
cycles = max
[sdl]
fullresolution=640x480
windowresolution=640x480
output=openglpp
[autoexec]
mount C C:\8086
set PATH=%PATH%;C:
MOUNT D --path--
D:
"""

filedata = filedata.replace("--path--", os.getcwd())

files = [f for f in os.listdir() if os.path.isfile(f)]

if "game.asm" in files:
    files.remove("game.asm")
    files.insert(0, "game.asm")

linkingstr = "link "

m = {}

for file in files:
    filename, file_extension = os.path.splitext(file)
    if file_extension == ".OBJ" or file_extension == ".EXE":
        os.remove(file)
    elif file_extension == ".asm":
        if len(filename) > 8:
            filename = filename[:6]
            if filename in m:
                m[filename] += 1
            else:
                m[filename] = 1
            filename += "~" + str(m[filename])
        filedata += f"masm {filename}.asm;\n"
        linkingstr += f"{filename}.OBJ+"

filedata += linkingstr[:-1]
filedata += ";"
filedata += "\ngame.exe"

filedata1 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM1
    """
)

filedata2 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM2
    """
)

with open("dosbox-x-generated1.conf", "w") as file:
    file.write(filedata1)

with open("dosbox-x-generated2.conf", "w") as file:
    file.write(filedata2)

prog1 = ["C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe", "-conf", "dosbox-x-generated1.conf"]
prog2 = ["C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe", "-conf", "dosbox-x-generated2.conf"]

subprocess.Popen(prog1)
sleep(2)
subprocess.Popen(prog2)