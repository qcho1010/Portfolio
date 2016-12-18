import numpy as np

class State:
	def __init__(self, D, rank, eta):
		self.D = D # no.of donation list
		self.rank = rank # perference ranking matrix
		self.M = rank.shape[1] # no.of gift
		self.N = rank.shape[0] # no.of children
		self.bool_col = np.ones(np.arange(0, self.M).shape, dtype=bool)
		self.eta = eta # prunning parameter

	# Creating subtree for next possible solution
	def create_subtree(self, col_order):
		subtree = []
		updated_bool_col = np.copy(self.bool_col) # hard copy
		updated_bool_col[col_order] = 0 # update bool_col.
		min_row_idx = self.find_min_row_idx(col_order) # find estimation
		estimation = np.sum(self.update_rank(min_row_idx, col_order))
		row_idx = self.find_row_idx(col_order) # num.node.need

		for i in xrange(0, len(row_idx)): # len(row_idx) = no.nodes to make
			updated_D = np.copy(self.D)
			updated_D[row_idx[i]] -= 1
			updated_rank = self.update_rank(row_idx[i], col_order)

			if np.floor(estimation + self.eta) > np.sum(updated_rank): # A* approach
				state = State(updated_D, updated_rank, self.eta) 
				state.set_col_idx(updated_bool_col)
				subtree.append(state)

		return subtree

	# finding best row index to calculate the estimated value
	def find_min_row_idx(self, j):
		rank_value = np.array(self.rank[:, [j]]).reshape((1,self.N))[0] # extract rank_value for column 'j'
		for i in xrange(0, self.N):
			if self.D[i] == 0: # if child_i has 0 donated count
				rank_value[i] = 10e+8
		min_row_idx = np.array(np.where(rank_value == np.min(rank_value)))[0] # find all min.value.idx.
		return min_row_idx

	# finding all possible row index, after the contrains
	def find_row_idx(self, j):
		# row, col reduction from hungarian algorithm
		copied_rank = np.copy(self.rank)
		
		rank_value = np.array(self.rank[:, [j]]).reshape((1,self.N))[0] # extract rank_value for column 'j'
		result = rank_value
		remove_idx_list = []
		for i in xrange(0, self.N): # if child_i has 0 donated count or gift rank is less than 75
			if self.D[i] == 0 or float(rank_value[i]) > (float(self.M)*.75):
				remove_idx = np.array(np.where(rank_value == rank_value[i]))[0] # find removing index 
				remove_idx_list = np.append(remove_idx_list, remove_idx) # append to removing index list
		row_idx = np.setdiff1d(np.arange(0, self.N), remove_idx_list) # find the index difference

		return row_idx

	# update ranks
	def update_rank(self, row_idx, min_col_idx):
		updated_rank = np.copy(self.rank) # hard copy
		row_idx_del = np.delete(np.arange(0, self.N), row_idx, axis=0) # save only selected idx.
		updated_rank[row_idx_del, min_col_idx] = 0 # put 0 to non-selected one
		return updated_rank

	def set_col_idx(self, bool_col):
		self.bool_col = bool_col

	def all_visited(self):
		return len(np.where(self.bool_col==True)[0]) == 0