#!/usr/bin/python


import sys, json


usage = 'Usage: python top_ten.py tweetFile [number of hashtags]'

'''
Outputs the top ten hashtags, contained in the tweet_file

'''


def getHashTags(tweet):
	return [i[1:] for i in tweet.split() if i.startswith("#")]

def readTweetsToList(outputfile):
	'''
	Read the tweets	and returns a list with the tweets
	'''
	tweets = []
	for line in outputfile:
		tweets.append(json.loads(line))
	return tweets

def hw(tweet_file, number):
	tweets = readTweetsToList(tweet_file)

	hashTagsFrequency = {}

	for tweet in tweets:
		if tweet.has_key('text'):
			hashTags = getHashTags(tweet['text'])
			for hashTag in hashTags:
				if hashTagsFrequency.has_key(hashTag.lower()):
					hashTagsFrequency[hashTag.lower()] += 1
				else:
					hashTagsFrequency[hashTag.lower()] = 1

	for key, value in (sorted(hashTagsFrequency.iteritems(), key=lambda (k,v): v,reverse=True))[:number]:
		print "#%s" % key, ":  Freq: %d" % value		
	

def main():	
	numberArguments = len(sys.argv[1:])
	if numberArguments == 0 or numberArguments > 2:
		print usage
		sys.exit(1)

	number = 10
	
	tweet_file = open(sys.argv[1])
	if numberArguments > 1:
		number = int(sys.argv[2])

	hw(tweet_file, number)
	sys.exit(1)


if __name__ == '__main__':
    main()
