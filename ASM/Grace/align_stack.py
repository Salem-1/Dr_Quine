


with open("Grace.s", "r", encoding="utf-8") as f:
	buff = f.read()
	buff = buff.split("\n")
	pushes = 0
	PUSHES = 0
	cs = 0
	for i in buff:
		#removing commented lines
		if "; Bism Ellah Elrahman Elraheem%cextern fopen" in i:
			cs = i.count("%c") + i.count("%s")
		elif ";" in i or "macro" in i:
			continue
		elif "push" in i:
			pushes += 1
		elif "PUSH_NEWLINE" in i:
			PUSHES += int(i.split(" ")[1])
	pushes -=1
	total_pushes = pushes + PUSHES
	print(f"%cs = {cs}")
	print(f"Total pushes = {total_pushes}")
	print(f"sub rsp, {hex(total_pushes * 8)}")
	print(f"add rsp, {hex(total_pushes * 8 * 2)}")