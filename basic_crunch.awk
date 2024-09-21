#!/bin/gawk -f
# basic_crunch v2
# Lauren Rad 2024 cybertapes.com
# Reduce filesize of Color Basic source code.
# This allows for writing maintainable Color Basic code that doesn't waste too much memory.
#

BEGIN {
	targets["NULL"]=1 # Array of target tags
	for (i=0; i<ARGC; i++) {
		if (ARGV[i] ~ /--.+/) {
			if (ARGV[i] == "--no-summary") {
				no_summary = 1
				delete ARGV[i]
			} else if (ARGV[i] ~ /--dbg/) {
				debug=1
				delete ARGV[i]
			} else if (ARGV[i] ~ /--outfile=.+/) {
				outfile = substr(ARGV[i],11)
				fout = 1
				delete ARGV[i]
			} else if (ARGV[i] ~ /--target=.+/) {
				split(ARGV[i],ar,"=")
				targets[ar[2]]=1 # Add new target
				delete ARGV[i]
				delete targets["NULL"]
			} else {
				print "Usage: basic_crunch.awk [ GNU long options ] file"
				print "Options:"
				print "--no-summary	(If output file is used) Do not print a filesize summary."
				print "--outfile=[file] Use output file instead of stdout."
				print "--target=[BAS|EXTBAS|DRAGON] Choose target platform for conditional code."
				exit 1
			}
		}
	}
	print "selected targets: "
	for (t in targets)
		print t
}

BEGINFILE {
	# Get input filesize
	if (!no_summary) {
		command = "stat -c %s " FILENAME
		command | getline insize
		close(command)
	}
}

function arr_length(arr) {
	len = 0
	for (i in arr)
		len++
	return len
}

# Run gsub on a line, ignoring items in strings
function sgsub(line, regexp, substitution) {
	if (line ~ /"/) {
		s = ""
		split(line,ar,"\"",seps)
		sz = arr_length(ar)
		for (i=1; i<=sz; i++) {
			#print "processing segment: " ar[i]
			if (i%2 != 0) {
				subs = gsub(regexp, substitution, ar[i])
				# if this deletes to end of line, bail out after substitution
				if (substitution == "" && regexp ~ /\$/ && subs>0) {
					line = s ar[i]
					return line
				} else {
					s = s ar[i]
				}
			} else {
				s = s "\"" ar[i] "\""
			}
		}
		line = s
	} else {
		gsub(regexp, substitution, line)
	}
	return line
}

# Do not modify first line
$1 == "1" {
	if (fout)
		print > outfile
	else
		print
	next
}

# Ignore lines with @NOCRUNCH
/@NOCRUNCH/ {
	if (fout)
		print > outfile
	else
		print
	next
}

# Include debug lines if debug is on
/@DEBUG/ {
	if (debug) {
		if (fout)
			print > outfile
		else
			print
	}
	next
}

# Target conditional code
/@TARGETS=/ {
	match($0,/(@TARGETS=)(.+)$/,ar) # get list of targets
	split(ar[2],ts,",") # get comma separated targets
	found = 0
	for (t in ts) {
		if (ts[t] in targets)
			found = 1 # one of the targets in the list matches a selected target
	}

	if (!found)
		next #skip if target is not a selected target
}

# Do not print lines containing only a ' comment
/^[[:digit:]]+[[:space:]]*\47/ {
	next
}

# Strip end of line comments
/.*[[:alpha:]]+.*\47.*$/ {
	$0 = sgsub($0,@/\47.*$/,"")
}

{
	# Isolate the line numbers from the rest of the line
	match($0,/^[[:digit:]]+[[:space:]]/)
	linenum = substr($0,1,RLENGTH)
	rest = substr($0,RLENGTH+1)

	# Replace some tokens with shorthands
	rest = sgsub(rest,@/PRINT/,"?")
	rest = sgsub(rest,@/REM/,"\47")
	# Remove whitespace around some tokens
	# This does currently cause a discrepancy between output difference and actual
	# bytes saved because if space after a line number is removed BASIC will add it back
	rest = sgsub(rest,@/[[:space:]]*IF[[:space:]]*/,"IF");
	rest = sgsub(rest,@/[[:space:]]*FOR[[:space:]]*/,"FOR");
	rest = sgsub(rest,@/ELSE[[:space:]]+/,"ELSE");
	rest = sgsub(rest,@/THEN[[:space:]]+/,"THEN");
	rest = sgsub(rest,@/[[:space:]]*GOTO[[:space:]]*/,"GOTO");
	rest = sgsub(rest,@/[[:space:]]*GOSUB[[:space:]]*/,"GOSUB");
	rest = sgsub(rest,@/[[:space:]]*POKE[[:space:]]*/,"POKE");i

	# Rejoin whole line
	$0 = linenum rest

	if (fout)
		print > outfile
	else
		print

}

ENDFILE {
	if (fout)
		close(outfile)
	# Get output filesize
	if (!no_summary && fout) {
		command = "stat -c %s " outfile
		command | getline outsize
		close(command)
	}

}

END {
	# print summary
	if (!no_summary && fout) {
		print "Before: " insize " bytes"
		print "After: " outsize " bytes"
		print "Bytes saved: " (insize-outsize) " bytes"
	}

}


