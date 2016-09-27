#!/usr/bin/python
# -*- coding: utf-8 -*-


'''
Given a tweet file (e.g. collected from the twitter stream API),
enlish-filtered ideally, outputs the relative frequency of each word,
avoiding "empty content" words, such as conjunctions, helping verbs, ...

'''
usage = 'python frequency.py <tweet_file>'

import sys, json, re

conjunctions = ['and', 'but', 'or', 'nor', 'for', 'yet', 'so','after', 'although', 'as', 'because', 'before', 'even', 'if', 'inasmuch', 'lest', 'now', 'once', 'provided', 'rather', 'since', 'supposing', 'than', 'that', 'though', 'til', 'unless', 'until', 'when', 'whenever', 'where', 'whereas', 'wherever', 'whether', 'which', 'while', 'who', 'whoever', 'why', 'both', 'either']
avoidableWords = ["about", "above", "across", "against", "ago", "at", "because", "below", "by", "for", "from", "in", "into", "like", "next", "of", "off", "on", "onto", "over", "past", "since", "through", "till", "to", "towards", "under", "until", "upon", "with"]
articles = ['the', 'a', 'an']
auxVerbs = ["be", "being", "been", "are", "aren't", "is", "isn't", "am", "was", "wasn't", "were", "weren't", "will", "won't", "would", "wouldn't", "could", "couldn't", "shall", "shan't", "should", "shouldn't", "must", "mustn't", "may", "might", "have", "having", "haven't", "had", "hadn't", "might", "do", "doing", "done", "did"]
removableChars = [',','.', ':', ';', '"', "'", '?','!', '|', '+', '-', '&', '+', '%', '*', '[', ']', '{', '}', ')','(', '/', '<', '>', '=', '[', '^', '$', '_', '#', '@','\\']

def readTweetsToList(outputfile):
	'''
	Read the tweets	and returns a list with the tweets
	'''
	tweets = []
	for line in outputfile:
		tweets.append(json.loads(line))
	return tweets

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


def hw(tweet_file):

	#Read tweets
	tweets = readTweetsToList(tweet_file)	

	frequencies = {}

	wordCount = 0.0
	for tweet in tweets:
		if tweet.has_key('text'): #Some tweets don't have a text field
			text = curateText(tweet['text'])
			words = text.split(" ")			
			wordCount += 1.0
			for word in words:
				if not word in auxVerbs and not word in conjunctions and not word in articles and not word in avoidableWords:
					word = word.strip()
					if word != " ":
						if frequencies.has_key(word):
							frequencies[word] += 1.0
						else:
							frequencies[word] = 1.0


	#print "Word count %d" % wordCount #Just for debugging
	
	#Print sorted values. 
	#(Recipe from: http://www.saltycrane.com/blog/2007/09/how-to-sort-python-dictionary-by-keys/)
	for key, value in sorted(frequencies.iteritems(), key=lambda (k,v): (v,k), reverse=False):
		if len(key) > 0:
			print "%s %1.2f" % (key, value/wordCount)


def main():
	if len(sys.argv) == 2:
		tweet_file = open(sys.argv[1])
		hw(tweet_file)
		sys.exit(0)
	else:
		print usage
		sys.exit(1)
    

if __name__ == '__main__':
    main()