import numpy as np

class Order_state:
	def __init__(self, D, rank, bool_col):
		self.D = D # no.of donation list
		self.rank = rank # perference ranking matrix
		self.M = rank.shape[1] # no.of gift
		self.N = rank.shape[0] # no.of children
		self.bool_col = bool_col
		self.col_order = np.array([], dtype=int)
		self.cost_sofar = np.zeros(self.M, dtype=int)
	
	# Creating column order subtree
	def create_order_subtree(self):
		order_subtree = []
		min_col_idx = self.find_min_col_idx() # find best possible columnes' index
		for i in xrange(0,len(min_col_idx)):
			updated_bool_col = np.copy(self.bool_col) # hard copy
			updated_bool_col[min_col_idx[i]] = 0 # mark that we visited this columne
			updated_col_order = np.copy(self.col_order)  # hard copy
			updated_col_order = np.append(updated_col_order, min_col_idx[i]) # append to order list
			order_state = Order_state(self.D, self.rank, self.bool_col) # create order state instance
			order_state.set_col_idx(updated_bool_col, updated_col_order)  # set up columns
			order_subtree.append(order_state) # append the instance to the list
		return order_subtree

	# Finding minimum column with best value
	def find_min_col_idx(self):
		copied_rank = np.copy(self.rank) 
		
		# hungarian algorithm (row, col reduction)
		for i in xrange(0, self.N):
			copied_rank[i,:] -= 1
		for j in xrange(0, self.M):
			copied_rank[:,j] -= np.min(copied_rank[:,j])
		for i in xrange(0, self.N):
			if len(np.array(np.where(copied_rank[i,:] == 0))[0]) < self.D[i]:
				non_zero_idx = np.array(np.where(copied_rank[i,:] != 0))[0]
				copied_rank[i, non_zero_idx] -= np.min(copied_rank[i,non_zero_idx])

		col_sum = np.sum(copied_rank, axis=0)
		for i in xrange(0, self.M):
			if self.bool_col[i] == False:
				col_sum[i] = 10e+8
		min_col_idx = np.array(np.where(col_sum == np.min(col_sum)))[0]
		return min_col_idx

	def get_order(self):
		return self.col_order

	def set_state(self, state):
		self.state = state

	def set_col_idx(self, bool_col, col_order):
		self.bool_col = bool_col
		self.col_order = col_order

	def all_visited(self):
		return len(np.array(np.where(self.bool_col == True))[0]) == 0