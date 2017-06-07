__author__ = 'lotfull'
# !/usr/bin/env python
# -*- coding: utf-8 -*-
import numpy
import os
import pandas as pd
import csv
import sqlite3 as lite
import time
import json
from bs4 import BeautifulSoup
from selenium import webdriver
from shutil import copyfile
import tweepy
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy import StreamListener
consumer_secret = "Ht0eDzAsWJwnP1vTiiGH0hKE3ZCfvuzJuJVUKJjfR2Sjj4Wh5t"
consumer_key = "3JGcrhPkeOjUrEMDNZEer8X9y"
access_token = "298552064-DJC8sHqkD0psgZbdg1mhoqBryUvL3kJfpXcZayzQ"
access_token_secret = "9HUme1VG5ckhRrc8Cj5uqnR0uqFDSHhMcjUxkeTuFCtXW"
auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth)
public_tweets = api.home_timeline()
'''for tweet in public_tweets:
    print(tweet.text)'''

count = 0
last_count = 0
checkout = 200
step = 200
limit = 600

words_names = [u"дратути", u"путлер", u"тян", u"шавуха", u"ето ", u"зашквар", u"бро", u"брутальный", u"зига", u"лузер", u"марамойка", u"омг", u"ололо", u"онотоле", u"педовка", u"стафф", u"фейк", u"хасл", u"хейтер", u"азаз", u"сорян", u"млять", u"госпади", u"лол", u"кек", u"навальный", u"ипаный", u"нахой", u"ахуенно", u"жиза", u"усманов", u"димон", u"путен", u"блэт", u"нэвэльный", u"россея", u"фак", u"рашка", u"сук "]
mat_words = [u"бля", u"сука", u"хуй", u"ебать", u"пиздец", u"ахуенно"]
shhh_words = [u"щас", u"шо ", u"ща ", u"чо "]
#words_names.extend(mat_words).extend(shhh_words)
words_count = {}
every_words_count = {}

def print_dict_sorted_by_value(name, dictionary):
    print("\n\n*********\n", name, "\n*********\n\n")
    for (key, value) in sorted(dictionary.items(), key=lambda x: x[1], reverse=True):
        if value < 5:
            break
        print(key, ": ", value, sep='')

def every_word_count_in(sentence):
    words = sentence.split()
    for word in words:
        if word in every_words_count:
            every_words_count[word] += 1
        else:
            every_words_count[word] = 1


class listener(StreamListener):
    def on_data(self, data):
        global count, last_count, words_names, words_count, checkout, step, limit
        data = json.loads(data)
        last_count = count
        #matchers = ['abc','def'] # words_names
        text = data["text"].lower()
        every_word_count_in(text)
        if count > checkout:
            checkout += step
            print_dict_sorted_by_value("SLANG WORDS", words_count)
            if checkout > limit:
                print_dict_sorted_by_value("ALL WORDS", every_words_count)
                return False
        for word_name in words_names:
            if word_name in text:
                words_count[word_name] = words_count.get(word_name, 0) + 1
                print(count, word_name)
                count += 1
        if last_count == count:
            print("********LOL, no coincidence********")

        return True

    def on_error(self, status):
        print(status)

starttime=time.time()
timeout = 1000.0

while True:
    print("tick")
    twitterStream = Stream(auth, listener())
    twitterStream.filter(track=words_names, async=True)
    time.sleep(timeout)
    print_dict_sorted_by_value("SLANG WORDS", words_count)
    print_dict_sorted_by_value("ALL WORDS", every_words_count)
    break
