import nltk
import pandas as pd

print("Let's begin")
f = open('/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/first_article2.txt')
raw = f.read()

tokens = nltk.word_tokenize(raw)

#Create your bigrams
bgs = nltk.bigrams(tokens)

#compute frequency distribution for all the bigrams in the text
fdist = nltk.FreqDist(bgs)
#for k,v in fdist.items():
#    print(k,v)

df = pd.DataFrame(fdist.items(), columns=['word', 'frequency'])

df.to_csv('/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/speech_converted_bigrams.csv', index=False)
print("Im Done")