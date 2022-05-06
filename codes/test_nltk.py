# packages to store and manipulate data
import pandas as pd
import numpy as np
# plotting packages
import matplotlib.pyplot as plt
import seaborn as sns
from nltk.stem.snowball import HungarianStemmer
import nltk
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
# model building package
import sklearn
# package to clean text
import re

df = pd.read_csv("osszesegyben.csv", encoding="windows-1250")

#
text = df["text"].unique()




# A 10 legtöbb bejegyzést közzétevő szereplő

plt.rcParams.update({'font.size': 15})
# Az ábra méreteinek megadása
fig = plt.figure(figsize=(10, 10))
# A szeletek változó reprezentációjának megadása
sizes = df["screen_name"].value_counts().head(10)
labels = sizes.index
# Kördiagram létrehozása (óramutató járásával ellentétesen csökkenő sorrendben)
plt.pie(sizes, labels=labels, autopct='%1.0f%%',
        shadow=False, startangle=90)
# Az ábra megjelenítése




# Közzétett tweetek és a készítő összes kedveléseinek száma az adott időszakban

df["screen_name"].value_counts().head(10).index
likes = df["favourites_count"].sort_values(ascending=False).head(100)
print(likes)

print(df.columns)

def find_mentioned(tweet):
    '''This function will extract the twitter handles of people mentioned in the tweet'''
    return re.findall('(?<!RT\s)(@[A-Za-z]+[A-Za-z0-9-_]+)', tweet)

def find_hashtags(tweet):
    '''This function will extract hashtags'''
    return re.findall('(#[A-Za-z]+[A-Za-z0-9-_]+)', tweet)

# print([df["text"][df["retweet_count"]>0]])
df['retweeted'] = df["text"][df["retweet_count"]>0]

df['mentioned'] = df.text.apply(find_mentioned)
# print(df['mentioned'])
df['hashtags'] = df.text.apply(find_hashtags)
# print(df['hashtags'])
#

# take the rows from the hashtag columns where there are actually hashtags
hashtags_list_df = df.loc[
                       df.hashtags.apply(
                           lambda hashtags_list: hashtags_list !=[]
                       ),['hashtags']]
print(hashtags_list_df)

# create dataframe where each use of hashtag gets its own row
flattened_hashtags_df = pd.DataFrame(
    [hashtag for hashtags_list in hashtags_list_df.hashtags
    for hashtag in hashtags_list],
    columns=['hashtag'])

print(flattened_hashtags_df)

# number of unique hashtags
print(flattened_hashtags_df['hashtag'].unique().size)

# count of appearances of each hashtag
popular_hashtags = flattened_hashtags_df.groupby('hashtag').size()\
                                        .reset_index(name='counts')\
                                        .sort_values('counts', ascending=False)\
                                        .reset_index(drop=True)
print(popular_hashtags)

# number of times each hashtag appears
counts = flattened_hashtags_df.groupby(['hashtag']).size().reset_index(name='counts').counts
print(counts)

# number of times each hashtag appears
counts = flattened_hashtags_df.groupby(['hashtag']).size()\
                              .reset_index(name='counts')\
                              .counts

# define bins for histogram
my_bins = np.arange(0,counts.max()+2, 5)-0.5

# plot histogram of tweet counts
plt.figure()
plt.hist(counts, bins = my_bins)
plt.xlabels = np.arange(1,counts.max()+1, 1)
plt.xlabel('hashtag number of appearances')
plt.ylabel('frequency')
plt.yscale('log')


# take hashtags which appear at least this amount of times
min_appearance = 10
# find popular hashtags - make into python set for efficiency
popular_hashtags_set = set(popular_hashtags[
                           popular_hashtags.counts>=min_appearance
                           ]['hashtag'])
print(popular_hashtags_set)

# make a new column with only the popular hashtags
hashtags_list_df['popular_hashtags'] = hashtags_list_df.hashtags.apply(
            lambda hashtag_list: [hashtag for hashtag in hashtag_list
                                  if hashtag in popular_hashtags_set])
# drop rows without popular hashtag
popular_hashtags_list_df = hashtags_list_df.loc[
            hashtags_list_df.popular_hashtags.apply(lambda hashtag_list: hashtag_list !=[])]

print(popular_hashtags_list_df)

# make new dataframe
hashtag_vector_df = popular_hashtags_list_df.loc[:, ['popular_hashtags']]

for hashtag in popular_hashtags_set:
    # make columns to encode presence of hashtags
    hashtag_vector_df['{}'.format(hashtag)] = hashtag_vector_df.popular_hashtags.apply(
        lambda hashtag_list: int(hashtag in hashtag_list))

print(hashtag_vector_df)
hashtag_matrix = hashtag_vector_df.drop('popular_hashtags', axis=1)

print(hashtag_matrix.head())

# calculate the correlation matrix
correlations = hashtag_matrix.corr()

# plot the correlation matrix
plt.figure(figsize=(10,10))
sns.heatmap(correlations,
    cmap='RdBu',
    vmin=-1,
    vmax=1,
    square = True,
    cbar_kws={'label':'correlation'})
plt.show()

# nltk.download('stopwords')
def remove_links(tweet):
    '''Takes a string and removes web links from it'''
    tweet = re.sub(r'http\S+', '', tweet) # remove http links
    tweet = re.sub(r'bit.ly/\S+', '', tweet) # rempve bitly links
    tweet = tweet.strip('[link]') # remove [links]
    return tweet

def remove_users(tweet):
    '''Takes a string and removes retweet and @user information'''
    tweet = re.sub('(RT\s@[A-Za-z]+[A-Za-z0-9-_]+)', '', tweet) # remove retweet
    tweet = re.sub('(@[A-Za-z]+[A-Za-z0-9-_]+)', '', tweet) # remove tweeted at
    return tweet

#
my_stopwords = nltk.corpus.stopwords.words('hungarian')
word_rooter = nltk.stem.snowball.HungarianStemmer(ignore_stopwords=False).stem
my_punctuation = '!"$%&\'()*+,-./:;<=>?[\\]^_`{|}~•@'

#
# cleaning master function
# def clean_tweet(tweet, bigrams=False):
    #
# tweet = df["text"].apply(remove_users)
# tweet = tweet.apply(remove_links)
# tweet = tweet.lower() # lower case
# tweet = re.sub('['+my_punctuation + ']+', ' ', tweet) # strip punctuation
# tweet = re.sub('\s+', ' ', tweet) #remove double spacing
# tweet = re.sub('([0-9]+)', '', tweet) # remove numbers
# tweet_token_list = [word for word in tweet.split(' ')
#                         if word not in my_stopwords] # remove stopwords

# tweet_token_list = [word_rooter(word) if '#' not in word else word
#                     for word in tweet_token_list] # apply word rooter
# if bigrams:
#     tweet_token_list = tweet_token_list+[tweet_token_list[i]+'_'+tweet_token_list[i+1]
#                                         for i in range(len(tweet_token_list)-1)]
# tweet = ' '.join(tweet_token_list)
# return tweet
#
# df['clean_tweet'] = df.text.apply(clean_tweet)
#
# print(df.head())
#
# from sklearn.feature_extraction.text import CountVectorizer
#
# # the vectorizer object will be used to transform text to vector form
# vectorizer = CountVectorizer(max_df=0.9, min_df=25, token_pattern='\w+|\$[\d\.]+|\S+')
#
# # apply transformation
# tf = vectorizer.fit_transform(df['clean_tweet']).toarray()
#
# # tf_feature_names tells us what word each column in the matric represents
# tf_feature_names = vectorizer.get_feature_names()
#
#
#
# from sklearn.decomposition import LatentDirichletAllocation
#
# number_of_topics = 10
#
# model = LatentDirichletAllocation(n_components=number_of_topics, random_state=0)
#
# model.fit(tf)
#
# def display_topics(model, feature_names, no_top_words):
#     topic_dict = {}
#     for topic_idx, topic in enumerate(model.components_):
#         topic_dict["Topic %d words" % (topic_idx)]= ['{}'.format(feature_names[i])
#                         for i in topic.argsort()[:-no_top_words - 1:-1]]
#         topic_dict["Topic %d weights" % (topic_idx)]= ['{:.1f}'.format(topic[i])
#                         for i in topic.argsort()[:-no_top_words - 1:-1]]
#     return pd.DataFrame(topic_dict)
#
# no_top_words = 10
#
# model_disp = display_topics(model, tf_feature_names, no_top_words)
#
# model_disp.to_csv("model_disp.csv")
#
#
