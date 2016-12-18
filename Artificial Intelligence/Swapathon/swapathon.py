import numpy as np
from astar import *
from os import listdir
from os.path import isfile, join

# return file lists from the directory
def get_file_list():
	mypath = './input/'
	file_list = [f for f in listdir(mypath) if isfile(join(mypath, f))]
	return file_list

# reading text data
def read_data(filename):
	filename = './input/' + filename
	header = child = D = rank = [] # col, row, donate count, rank mtrix
	with open(filename) as input:
		for idx, line in enumerate(input):
			line = line.strip().split('\t') # tokenize
			if idx == 0:	# first iteration == header
				header = np.array(line)
			else:
				child = np.append(child, line[0])
				D = np.append(D, int(line[1]))
				row = [int(x) for x in line[2:]]
				rank.append(row)
	return np.array(D, dtype=int), np.array(rank), header, child, filename

# writing text data
def write_data(header, child, D, result, filename):
	char_idx = filename.index('_') # find character _ for the output format
	filename = './output/output_' + filename[char_idx:] # add output in front of the format
	f = open(filename, 'w') # open work file

	# write score
	f.write('AllScores=')
	f.write(str(np.sum(result)))
	f.write('\n')

	# write header
	for i in xrange(0, len(header)):
		f.write(str(header[i]))
		f.write('\t')

	# write result
	result_combined = np.insert(result, 0, D, axis=1)
	for i in xrange(0, len(child)):
		for j in xrange(0, len(header)):
			if j == 0:
				f.write('\n')
				f.write(str(child[i]))
				f.write('\t')
			else:
				f.write(str(result_combined[i,j-1]))
				f.write('\t')

def main():
	file_list = get_file_list()
	for file_name in file_list:
		print "Running File Name :", file_name
		D, rank, header, child, filename = read_data(file_name) # read data
		# eta = prunning power (value between 0 to 10)
		# eta=0 most aggressive prunning, least accurate, fastest
		# eta=10 least aggressive prunning, most accurate, slowest
		a_star = Astar(D, rank, eta=5) 
		result = a_star.run() # run the search
		write_data(header, child, D, result, filename) # write data

if __name__ == '__main__':
    main()
