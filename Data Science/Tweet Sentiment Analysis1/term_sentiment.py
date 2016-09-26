#!/usr/bin/python
# -*- coding: utf-8 -*-


'''
	python term_sentiment.py <sentiment_file> <tweet_file>
	Given a sentiment file and a tweet file, rates new terms based on
	a very simple algorithm: if a new term is in a tweet with mostly good tweets, 
	it'll be added +1, if it's in a "bad" tweet -1. Neutral tweets don't modify the value.
	
	OUTPUT:
		50 words with the highest positive values

'''

import sys, json, re

avoidableWords = ["about", "above", "across", "against", "ago", "at", "because", "below", "by", "for", "from", "in", "into", "like", "next", "of", "off", "on", "onto", "over", "past", "since", "through", "till", "to", "towards", "under", "until", "upon", "with"]
auxVerbs = ["be", "being", "been", "are", "aren't", "is", "isn't", "am", "was", "wasn't", "were", "weren't", "will", "won't", "would", "wouldn't", "could", "couldn't", "shall", "shan't", "should", "shouldn't", "must", "mustn't", "may", "might", "have", "having", "haven't", "had", "hadn't", "might", "do", "doing", "done", "did"]
conjunctions = ['and', 'but', 'or', 'nor', 'for', 'yet', 'so','after', 'although', 'as', 'because', 'before', 'even', 'if', 'inasmuch', 'lest', 'now', 'once', 'provided', 'rather', 'since', 'supposing', 'than', 'that', 'though', 'til', 'unless', 'until', 'when', 'whenever', 'where', 'whereas', 'wherever', 'whether', 'which', 'while', 'who', 'whoever', 'why', 'both', 'either']
articles = ['the', 'a', 'an']
removableChars = [',','.', ':', ';', '"', "'", '?','!', '|', '+', '-', '&', '+', '%', '*', '[', ']', '{', '}', ')','(', '/', '<', '>', '=', '[', '^', '$', '_', '#', '@','\\']

#PARAMS
wordsToShow = 50


def loadSentimentsToDict(sent_file):
	scores = {} # initialize an empty dictionary
	for line in sent_file:
		term, score  = line.split("\t")  # The file is tab-delimited. "\t" means "tab character"
		scores[term] = int(score)  # Convert the score to an integer.
	return scores

def readTweetsToList(outputfile):
	'''
	Read the tweets	and returns a list with the tweets

	'''
	tweets = []
	for line in outputfile:
		tweets.append(json.loads(line))
	return tweets

def contentWord(word):
	return not word in avoidableWords and not word in auxVerbs and not word in conjunctions and not word in articles


def curateText(tweetText):		
	curatedText = re.sub('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+','', tweetText)#removes links to websites
	curatedText = re.sub('@(\w)+','',curatedText) #removes @reply's
	curatedText = re.sub('#(\w)+', '', curatedText) #removes hashtags
	curatedText = re.sub('[0-9]+', ' ', curatedText) #removes numbers
	curatedText = curatedText.replace('RT ', ' ') #removes RTs	

	for char in removableChars:
		curatedText = curatedText.replace(char, ' ')

	curatedText = curatedText.replace('\n',' ')	

	curatedText = curatedText.lower()	

	re.sub('( ){2,}',' ', curatedText) #removes contiguos spaces

	curatedText.strip() #Removes trailing and leading spaces

	return curatedText

def rateTweet(tweets, scores):
	#Rate tweets
	tweetScores = []
	for tweet in tweets:
		score = 0.0 #Default value
		if tweet.has_key('text'): #Some tweets don't have text field
			tweetText = tweet['text']				
			words = tweetText.split(" ")			
			for word in words:
				#Don't care about these chars
				word = word.replace(',','').replace('.','')
				if scores.has_key(word):
					score += scores[word]			
		tweetScores.append(score)
	return tweetScores

def hw(sent_file, tweet_file):

	#Load scores
	scores = loadSentimentsToDict(sent_file)
	#Load tweets
	tweets = readTweetsToList(tweet_file)

	#Rate tweets
	tweetScores = rateTweet(tweets, scores)

	newTerms = {}
	for index, tweet in enumerate(tweets):
		if tweet.has_key('text'): #Some tweets don't have text field
			text = curateText(tweet['text'])
			words = text.split(" ") # Breaks the tweet into words
			for word in words:
				if contentWord(word):
					if not scores.has_key(word):
						if not newTerms.has_key(word):
							newTerms[word] = 0.0
						if tweetScores[index] < 0:
							newTerms[word] -= 1
						elif tweetScores[index] > 0:
							newTerms[word] += 1

	for key, value in sorted(newTerms.iteritems(), key=lambda (k,v): (v,k), reverse=False)[-wordsToShow:]:
		if len(key) > 0:
			print "%s %1.2f" % (key, value)
	#print newTerms

def main():
    sent_file = open(sys.argv[1]) #usually AFINN
    tweet_file = open(sys.argv[2])
    hw(sent_file, tweet_file)

if __name__ == '__main__':
    main()
