import sys
import os
import tempfile
import subprocess
import exploitable
import signal


libdislocator = """

arch = gdb.execute("show architecture",True,True)

env = os.environ['VIRTUAL_ENV']

if "x86-64" in arch:
    gdb.execute("set environment LD_PRELOAD={0}".format(os.path.join(env,'lib','libdislocator_64.so')))

elif "i386" in arch:
    gdb.execute("set environment LD_PRELOAD={0}".format(os.path.join(env,'lib','libdislocator_32.so')))

else:
    print("Unknown architecture: " + arch)

"""

def writeFile(fp):

    fp.write(b"import sys\n")
    fp.write(b"import os\n")
    fp.write(b"sys.path += ")
    fp.write(str(sys.path).encode('ascii'))
    fp.write(libdislocator.encode('ascii'))

def run():

    # Let's ignore ctrl-c
    signal.signal(signal.SIGINT, signal.SIG_IGN)

    # Need a temp file to hold our paths
    with tempfile.NamedTemporaryFile(suffix=".py") as fp:

        # Write to our tempfile, match up our paths
        writeFile(fp)
        fp.seek(0)
        fp.flush()
        
        # Build the command
        command = ["gdb"]

        # Dynamically set the python path
        command.append("-x")
        command.append(fp.name)

        # Load up GEF
        command.append("-x")
        command.append(os.path.join(os.environ['VIRTUAL_ENV'],'bin','.gef.py'))
    
        # Load up exploitable
        command.append("-x")
        # OK, a little hackish. Oh well.
        command.append(os.path.join(os.path.dirname(exploitable.__file__),"exploitable.py"))

        # Yes, I'm defaulting these on. So sue me.
        command.append("-ex")
        command.append("break _start") # Break right at the begining
        command.append("-ex")
        command.append("run")
        command.append("-ex")
        command.append("format-string-helper")
        command.append("-ex")
        command.append("heap-analysis-helper")


        # Tack on any extra args
        command += sys.argv[1:]

        # Give it a run
        subprocess.call(command)
