print(gdb.execute("show version",True,True).split("\n")[0].split(" ")[-1])
exit(0)
