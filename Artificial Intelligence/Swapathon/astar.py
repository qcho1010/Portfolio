import numpy as np
from order_state import *
from state import *

class Astar:
	def __init__(self, D, rank, eta):
		self.rank = rank
		self.D = D # number of donation for each child
		self.M = rank.shape[1] # no.of gift
		self.N = rank.shape[0] # no.of children
		
		self.order_list = []
		self.state_list = []
		self.result_list = np.array([], dtype=int) 
		self.best_min = float("inf") # to store the best score
		self.best_state = None # to store best instance
		self.bool_col = np.ones(np.arange(0, self.M).shape, dtype=bool) # tracking visited column purpose
		
		self.state = State(self.D, self.rank, eta)	# make initial state instance # initial state
		self.order_state = Order_state(self.D, self.state.rank, self.bool_col) # create building column order graph instance

	def run(self):
		print "********************** Start **********************"
		print "Donation List :\n", self.D
		print "Original Data :\n", self.state.rank
		
		# build search graph (order)
		self.create_col_graph(self.order_state)
		self.order_list = np.array(self.order_list, dtype=int)
		print "** Done Generating Column Order Graph **"
		print self.order_list
		print "** Searching Best Solution **"

		# search
		# result = self.search(self.state, self.order_list[0], self.best_min, self.depth)
		# self.find_best_result()
		order_counter = 1
		for col_order in self.order_list:
			result = self.search(self.state, col_order, self.best_min)
			print "Iteration :", order_counter
			order_counter += 1
			self.find_best_result()
		print "Donation List :\n", self.D
		print "Result Matrix :\n", self.best_state.rank
		print "********************** End **********************"
		return self.best_state.rank

	# Recursive function to create search tree
	def search(self, state, col_order, best_min):
		if state.all_visited():
			return state
		else:
			subtree = state.create_subtree(col_order[0]) # create subtree for next level
			if subtree != False:
				for node in subtree:
					result = self.search(node, col_order[1:], best_min) # recursive call
					result_score = np.sum(result.rank)
					if  result_score < self.best_min:
						self.best_min = result_score
						state = result
				self.state_list.append(state)
				self.result_list = np.append(self.result_list, np.sum(state.rank))
				return state
			else:
				print "No Fesible Solution"
				return False
	
	# Creating column graph
	def create_col_graph(self, order_state):
		if order_state.all_visited():
			return self.order_list.append(order_state.get_order())
		else:
			order_subtree = order_state.create_order_subtree() # create subtree for next level
			for order_state in order_subtree:
				self.create_col_graph(order_state)

	# Display log function
	def find_best_result(self):				
		best_state_idx = np.array(np.where(self.result_list == min(self.result_list)))[0][0] # retrive the best result index
		print "Number of Candidates Solution:", len(self.result_list) 
		counter = 0
		for state in self.state_list:
			if counter == best_state_idx:
				if len(np.array(np.where(state.bool_col == False))[0]) != state.M:
					print "** Fail **"
				else:
					print "** Success **"
				self.best_state = state
				print "Score :", np.sum(state.rank)
			counter += 1