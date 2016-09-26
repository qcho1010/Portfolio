PYSPARK_DRIVER_PYTHON=ipython pyspark
fileA = sc.textFile("input/join1_FileA.txt")
fileA.collect()
fileB = sc.textFile("input/join1_FileB.txt")
fileB.collect()

##Mappers for File A
def split_fileA(line):
    # split the input line in word and count on the comma
    word, count = line.split(",")
    # turn the count to an integer
    count = int(count)
    return (word, count)

test_line = "able,991"
split_fileA(test_line)
fileA_data = fileA.map(split_fileA)
fileA_data.collect()

##Mappers for File B
def split_fileB(line):
    # split the input line into word, date and count_string
    lef, count = line.split(",")
    date, word = lef.split(" ")
    return (word, date + " " + count)

fileB_data = fileB.map(split_fileB)
fileB_data.collect()

fileB_joined_fileA = fileB_data.join(fileA_data)
fileB_joined_fileA.collect()
