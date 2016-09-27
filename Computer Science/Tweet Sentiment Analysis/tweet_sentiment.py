#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, json, re

'''
	python <tweet_file> <sent_file>
	Rates tweets from tweet_file, according to values from sent_file
	OUTPUT:
		rating of every tweet on the file
'''

def loadSentimentToDict(sent_file):
	scores = {} # initialize an empty dictionary
	for line in sent_file:
		term, score  = line.split("\t")  # The file is tab-delimited. "\t" means "tab character"
		scores[term] = int(score)  # Convert the score to an integer.
	return scores

def readTweetsToList(outputfile):
	#Read the tweets	
	tweets = []
	for line in outputfile:
		tweets.append(json.loads(line))
	return tweets

def curateText(tweetText):
	curatedText = re.sub('@(\w)+','',tweetText)#removes @reply's
	curatedText = re.sub('#(\w)+', '', curatedText)#removes hashtags
	curatedText = re.sub('@(\w)+', '', curatedText)#removes RTs
	curatedText.strip() #Removes trailing and leading spaces

	return tweetText

def hw():
	afinnfile = open("AFINN-111.txt")
	outputfile = open("output.txt")
	
	#Load scores
	scores = loadSentimentToDict(afinnfile)
	#Load tweets
	tweets = readTweetsToList(outputfile)

	#Rate tweets
	tweetScores = []
	for tweet in tweets:
		score = 0.0 #Default value
		if tweet.has_key('text'): #Some tweets don't have text field
			tweetText = tweet['text']			
			
			
			words = tweet['text'].split(" ")			
			for word in words:
				#Don't care about these chars
				word = word.replace(',','').replace('.','').replace('#','').replace('@','') 
				if scores.has_key(word):
					score += scores[word]			
		tweetScores.append(score)

	for index, tweetScore in enumerate(tweetScores):
		print index, tweetScore

def main():
    sent_file = open(sys.argv[1])
    tweet_file = open(sys.argv[2])
    hw()


if __name__ == '__main__':
    main()
