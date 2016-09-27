
import sys
import json
import re

def lines(fp):
	print str(len(fp.readlines()))

# build_dict: file -> (dict: string int)
# builds the sentiment dictionary
def build_dict(afinnfile):
	scores = {} # initialize empty dictionary
	for line in afinnfile:
		term, score = line.split("\t") # split by tabs
		scores[term] = int(score) # convert score to int
	return scores

# build_tweets_list: file (dict: string int) -> (dict: string int)
# returns a list of valid US tweets
# file -> (listof listof lower-case strings)
def build_US_tweets_list(t_file, scores):
	state_tweet_dict = {}
	for line in t_file:
		if 'place' in line:
			temp = json.loads(line)['place']
			if temp != None and temp['country_code'] == 'US':
				tweet = json.loads(line)['text']
				current_state = temp['full_name'].split(',')[1]
				if current_state in state_tweet_dict:
					state_tweet_dict[current_state] += get_tweet_sent(tweet, scores)
				else:
					state_tweet_dict[current_state] = get_tweet_sent(tweet, scores)
	return state_tweet_dict

# get_tweet_sent: string (dict: string int) -> int
# returns the sentiment of a tweet
def get_tweet_sent(tweet, s_list):
	running_sent = 0;
	tweet = re.split('[\. \, \? ! @ # \$ % ^ & \* ( ) \+ - ; : < > |]', tweet)
	for word in tweet:
		if word in s_list:
				running_sent += s_list[word]
	return running_sent

# print_happiest_state: (dict: string int) -> stdout
def print_happiest_state(US_tweet_dict):
	happiest_state = {'dummy' : -999999}
	for key, value in US_tweet_dict.items():
		if value > happiest_state.values()[0]:
			happiest_state = {key : value}
	print happiest_state.keys()[0]
#	print happiest_state.values()[0]

def main():
	sent_file = open(sys.argv[1])
	tweet_file = open(sys.argv[2])
	scores = build_dict(sent_file) 
	US_tweet_dict = build_US_tweets_list(tweet_file, scores)
	print_happiest_state(US_tweet_dict)

if __name__ == '__main__':
    main()