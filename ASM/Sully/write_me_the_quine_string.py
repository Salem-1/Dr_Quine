final_file_out = ""

with open("Sully.s", "r", encoding="utf-8") as f:
	original = f.read()

	if original.endswith("\n"):
		original = original[:-1]

	tmp = original.split("\n")
	cpy = original.split("\n")
	msg = ""

	for i in tmp:
		if "msg db " in i:
			i = "	msg db %2$c%4$s%2$c, 0"
		else:
			a = i.replace("%", "%3$c")
			b = a.replace('"', "%2$c")
			i = b

		i += "%1$c"
		msg += i

	for i in cpy:
		if "msg db " in i:
			final_file_out += f'	msg db "{msg}", 0\n'
		else:
			final_file_out += i + "\n"

with open("Sully.s", "w", encoding="utf-8") as f:
	f.write(final_file_out)

print(final_file_out, end="")