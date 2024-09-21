# Little script to take output from EDTASM+ and convert to
# comma-separated decimal values for Color Basic
# V2

import sys

# Convert the file to the desired format; returns number of bytes
# on success or a negative number on failure.
def edtasm2bas(infile, outfile):
    lcount = 0 # line count
    bcount = 0 # byte count
    try:
        for line in infile:
            lcount += 1
            if line.find("END") != -1:
                print(f'Processed {lcount} lines.')
                return bcount # END reached, success
            data = line[6:20].split()
            for item in data:
                if len(item) == 2:
                    bcount += 1
                    outfile.write(str(int(item,16)))
                    if bcount % 15 == 0:
                        outfile.write('\n')
                    else:
                        outfile.write(',')
                else:
                    # Bytes need to be split
                    while len(item) > 0:
                        bcount += 1
                        it = item[0:2]
                        item = item[2:]
                        outfile.write(str(int(it,16)))
                        if bcount % 15 == 0:
                            outfile.write('\n')
                        else:
                            outfile.write(',')
    except Exception as e:
        print(f"Aborting: Encountered data that could not be handled: {item};{e}")
        return -2
    finally:
        print("Closing files...")
        infile.close()
        outfile.close()
    return -1 # Premature EOF, presumed failure

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: edtasm2bas [file]")
        exit(3)
    
    try:
        infile = open(sys.argv[1],'r')
    except FileNotFoundError as e:
        print("Unable to open input file.")
        exit(1)

    try:
        outfile = open('bas.out','w')
    except:
        print("Error opening output file for writing.")
        infile.close()
        exit(2)
    
    status = edtasm2bas(infile, outfile)
    if status > 0:
        print(f"Output {status} bytes.")
    else:
        print(f"Exited with error status {status}.")

    exit(0)

