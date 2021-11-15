import os
import sys
import time
import glob
import time
import random
import numpy as np
import pandas as pd
from datetime import datetime
from konlpy.tag import Mecab
mecab = Mecab('C:/Mecab/mecab-ko-dic')
mecab.nouns('탄소중립')
mecab.nouns('개발도상국')
mecab.nouns('개발 도상국')

os.chdir('C:/Users/KKD/Desktop/KEI_Text')
xlsx_list=[f for f in os.listdir('.') if f.endswith('.xlsx')]

# 모든 파일 불러오기(빈 데이터프레임을 만든 뒤 append 하는 방식)
from tqdm import tqdm 
df = pd.DataFrame()
for name in tqdm(xlsx_list):
    data = pd.read_excel(name)
    data['filename'] = str(name)[:-5]
    data = data.loc[:, data.columns.str.contains('filename|title|content|date')]
    data['date'] = data['date'].astype(str)
    df = df.append(data)

# 데이터 정리(9738 -> 5476, 2000년 이상, 연도정보 있음, 요약문 존재)
df.columns
df['year'] = df['date'].str.slice(stop=4)
df = df.dropna(axis=0) # 5771개
df = df[df['year']!='nan'] # 5624개
df = df[(df['year'].astype(int) >= 2000)&(df['year'].astype(int) <= 2020)] # 5476개
df = df.reset_index(drop=True)

# 전처리

# 대체어 처리(시간 매우매우 오래 걸림)
replace=pd.read_excel('C:/Mecab/user-dic/dictionary.xlsx', sheet_name='대체어 사전', header=None)

# 12분
for i in tqdm(range(0, len(df['content']))):
    for p in range(0, len(replace)):
        df.content[i] = df.content[i].replace(replace[0][p], replace[1][p])

# 불용어처리
stop1=pd.read_excel('C:/Mecab/user-dic/dictionary.xlsx', sheet_name='개체명 사전', header=None, names=['name'])
stop2=pd.read_excel('C:/Mecab/user-dic/dictionary.xlsx', sheet_name='불용어 사전', header=None, names=['name'])
stop3=pd.read_excel('C:/Mecab/user-dic/dictionary.xlsx', sheet_name='수량어 사전', header=None, names=['name'])
stop4=pd.read_excel('C:/Mecab/user-dic/dictionary.xlsx', sheet_name='인물명 사전', header=None, names=['name'])
temp=pd.concat([stop1, stop2, stop3, stop4], axis=0, ignore_index=True)
temp.dropna(subset=['name'], inplace=True)
temp=temp.reset_index(drop=True)
stopwords = temp.name.to_list()
len(stopwords)


# 명사추출(1분)
import re

df['text']=""
for i in tqdm(range(0, len(df.content))) :
    df.text[i] = re.sub(r'\[[^\]]+\]|\([^\)]+\)|\<[^\>]+\>', '', df.content[i])
    df.text[i] = re.sub(r'[^ ㄱ-ㅣ가-힣]+', '', df.text[i])
    df.text[i] = " ".join([x for x in mecab.nouns(df.text[i]) if x not in stopwords and len(x)>1])

df = df[df['text']!='']
df = df.reset_index(drop=True)

df['length']=""
for i in tqdm(range(0, len(df.text))) :
    df['length'][i] = len(df['text'][i])
df = df[df['length'] > 10]
df = df.reset_index(drop=True)
len(df) #4956개


# 전처리 데이터 저장
df.to_excel('total.xlsx')


# 데이터 불러오기
df = pd.read_excel('total.xlsx')

df['type'].value_counts()

# 연도별 문서수
df['type'] = df['filename'].str.contains('탄소중립')*1
df['year'].value_counts()

## 시간별 빈도 그래프
sub = df.groupby(['type', 'year']).count()['text'].unstack().T
sub = sub.reset_index(level='year')
sub.columns = ['year', '온실가스', '탄소중립']

import plotly.express as px
import plotly
import plotly.graph_objs as go
from plotly.subplots import make_subplots
plotly.offline.init_notebook_mode(connected=True)

fig = make_subplots(specs=[[{"secondary_y": True}]])

fig.add_trace(go.Scatter(x= sub['year'], y= sub['온실가스'], name='온실가스',  line = dict(color='firebrick', width=4, dash='dot')), secondary_y=False)
fig.add_trace(go.Scatter(x= sub['year'], y= sub['탄소중립'], name='탄소중립', line = dict(color='royalblue', width=4)), secondary_y=True)

fig.update_layout(barmode='group', xaxis_tickangle=-45)
plotly.offline.plot(fig)

# 중요단어 분석
import plotly.graph_objs as go
import plotly.express as px
import plotly

from sklearn.preprocessing import MinMaxScaler
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer

cv = CountVectorizer(min_df=10)
dtm_counts = cv.fit_transform(df[df['type']==0]['text'])
wordFreq1 = pd.DataFrame({"Word":cv.get_feature_names(), "WordCount": np.squeeze(np.asarray(dtm_counts.sum(axis=0)))})
dtm_counts = cv.fit_transform(df[df['type']==1]['text'])
wordFreq2 = pd.DataFrame({"Word":cv.get_feature_names(), "WordCount": np.squeeze(np.asarray(dtm_counts.sum(axis=0)))})

total_words = pd.merge(wordFreq1, wordFreq2, left_on="Word", right_on="Word", how='outer')
total_words.columns = [0, 1, 2]
scaler = MinMaxScaler()
total_words[[1, 2]] = scaler.fit_transform(total_words[[1, 2]])
total_words = total_words.sort_values(by=2, ascending=False)[0:50]
total_words = total_words.fillna(0)

fig = go.Figure()
fig.add_trace(go.Bar(
    x= total_words[0],
    y= total_words[1],
    name='온실가스',
    marker_color='indianred'
))
fig.add_trace(go.Bar(
    x= total_words[0],
    y= total_words[2],
    name='탄소중립',
    marker_color='lightsalmon'
))

fig.update_layout(barmode='group', xaxis_tickangle=-45)
fig.update_yaxes(type="log")
plotly.offline.plot(fig)
fig.write_image("histogram.png")


#wordcloud
from wordcloud import WordCloud
import matplotlib as mpl
import matplotlib.pyplot as plt
font_path = 'C:/Windows/fonts/NanumBarunGothic.ttf'

krwordrank_cloud = WordCloud(
    font_path=font_path,
    width = 800,
    height = 800,
    max_words = 100,
    max_font_size = 300,
    background_color="white"
)

cv = CountVectorizer(min_df=5)
dtm = cv.fit_transform(df['text'])
wordFreq = pd.DataFrame({"Word":cv.get_feature_names(), "WordCount": np.squeeze(np.asarray(dtm.sum(axis=0)))})
krwordrank_cloud = krwordrank_cloud.generate_from_frequencies(dict(zip(wordFreq.Word, wordFreq.WordCount)))
fig = plt.figure(figsize=(10, 10))
plt.imshow(krwordrank_cloud, interpolation="bilinear")
plt.savefig('wordcloud.png')



## 여기서부터 다시 시작
# word2vec
df = pd.read_excel('total.xlsx')
df = df.loc[:, ~df.columns.str.match('Unnamed')]


# list 형태의 단어를 입력해야 함, 따라서 final은 lists in list
from gensim.models import Word2Vec
final = df['text'].str.split()
model = Word2Vec(sentences=final, size=300, window=5, min_count=5, workers=8, sg=1, negative=5, iter=5, seed=42, compute_loss=True)
df1 = pd.DataFrame(model.wv.most_similar("온실가스", topn=20))
df2 = pd.DataFrame(model.wv.most_similar("탄소중립", topn=20))
df3 = pd.concat([df1, df2], axis=1)
df3.to_excel('df5.xlsx')
df3
model.wv.similarity("온실가스", "탄소중립")
model.get_latest_training_loss()
model.save("word2vec1.model")

model.most_similar(positive=['탄소중립'], negative=['온실가스'], topn=10)
model.most_similar(positive=['탄소중립', '온실가스'], topn=10)



from sklearn.decomposition import PCA
import numpy as np
from sklearn.manifold import TSNE
import seaborn as sns
sns.set_style("darkgrid")
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from matplotlib import rc
font_name = fm.FontProperties(fname='C:/Windows/Fonts/malgun.ttf').get_name()
rc('font', family=font_name)
mpl.rcParams['axes.unicode_minus'] = False


# PCA와 TSNE 같이 쓰기

# tsne plot for below word

def tsne_plot(for_word, w2v_model):
    # trained word2vec model dimention
    dim_size = w2v_model.wv.vectors.shape[1]

    arrays = np.empty((0, dim_size), dtype='f')
    word_labels = [for_word]
    color_list  = ['red']

    # adds the vector of the query word
    arrays = np.append(arrays, w2v_model.wv.__getitem__([for_word]), axis=0)

    # gets list of most similar words
    sim_words = w2v_model.wv.most_similar(for_word, topn=20)

    # adds the vector for each of the closest words to the array
    for wrd_score in sim_words:
        wrd_vector = w2v_model.wv.__getitem__([wrd_score[0]])
        word_labels.append(wrd_score[0])
        color_list.append('green')
        arrays = np.append(arrays, wrd_vector, axis=0)

    #---------------------- Apply PCA and tsne to reduce dimention --------------

    # fit 2d PCA model to the similar word vectors
    model_pca = PCA(n_components = 2).fit_transform(arrays)

    # Finds 2d coordinates t-SNE
    np.set_printoptions(suppress=True)
    Y = TSNE(n_components=2, random_state=0, perplexity=15).fit_transform(model_pca)

    # Sets everything up to plot
    df_plot = pd.DataFrame({'x': [x for x in Y[:, 0]],
                       'y': [y for y in Y[:, 1]],
                       'words_name': word_labels,
                       'words_color': color_list})

    #------------------------- tsne plot Python -----------------------------------

    # plot dots with color and position
    plot_dot = sns.regplot(data=df_plot,
                     x="x",
                     y="y",
                     fit_reg=False,
                     marker="o",
                     scatter_kws={'s': 40,
                                  'facecolors': df_plot['words_color']
                                 }
                    )

    # Adds annotations with color one by one with a loop
    for line in range(0, df_plot.shape[0]):
         plot_dot.text(df_plot["x"][line],
                 df_plot['y'][line],
                 '  ' + df_plot["words_name"][line].title(),
                 horizontalalignment='left',
                 verticalalignment='bottom', size='medium',
                 color=df_plot['words_color'][line],
                 weight='normal'
                ).set_size(15)


    plt.xlim(Y[:, 0].min()-50, Y[:, 0].max()+50)
    plt.ylim(Y[:, 1].min()-50, Y[:, 1].max()+50)

    plt.title('t-SNE visualization for word "{}'.format(for_word.title()) +'"')
    plt.show()

tsne_plot(for_word='탄소중립', w2v_model=model)
tsne_plot(for_word='온실가스', w2v_model=model)


# t-SNE 그래프

from sklearn.feature_extraction.text import CountVectorizer
cv = CountVectorizer(min_df=5)
dtm = cv.fit_transform(df[df['type']==1]['text'])
wordFreq = pd.DataFrame({"Word":cv.get_feature_names(), "WordCount": np.squeeze(np.asarray(dtm.sum(axis=0)))})

vocab = list(wordFreq[(wordFreq['Word']!="온실가스") & (wordFreq['Word']!="탄소중립")].sort_values(by='WordCount', ascending=False)[0:50]['Word'])
vocab.append("온실가스")
vocab.append("탄소중립")

X = model[vocab]
len(vocab)

def show_pca(X) :
    # fit 2d PCA model to the similar word vectors
    model_pca = PCA(n_components = 10).fit_transform(X)

    # Finds 2d coordinates t-SNE
    np.set_printoptions(suppress=True)
    x_pca = TSNE(n_components=2, random_state=0, perplexity=10).fit_transform(model_pca)

    plt.figure(figsize=(15,15))
    plt.xlim(x_pca[:, 0].min()-0.5, x_pca[:, 0].max()+0.5) 
    plt.ylim(x_pca[:, 1].min()-0.5, x_pca[:, 1].max()+0.5)
    for i in range(len(X)-2): 
        plt.text(x_pca[i, 0], x_pca[i, 1], str(vocab[i]), fontdict={'weight': 'bold', 'size': 15}) 
    plt.text(x_pca[50, 0], x_pca[50, 1], str(vocab[50]), fontdict={'weight': 'bold', 'size': 20, 'color':  'red'}) 
    plt.text(x_pca[51, 0], x_pca[51, 1], str(vocab[51]), fontdict={'weight': 'bold', 'size': 20, 'color':  'blue'}) 
    plt.xlabel("첫 번째 주성분") 
    plt.ylabel("두 번째 주성분") 
    plt.show()

show_pca(X)
df3

# iter50
model2 = Word2Vec(sentences=final, size=300, window=5, min_count=20, workers=8, sg=1, negative=5, iter=50)
model2.wv.similarity("온실가스", "탄소중립")

# 중요문장추출(KRwordRank)
import kss

result = []
for i in df[df.type==0]['content'] :
    i = re.sub(r'[^\.|\s|가-힣]+', '', i)
    temp = kss.split_sentences(i) 
    for t in temp :
        result.append(t)


result1 = []
for i in df[df.type==1]['content'] :
    i = re.sub(r'[^\.|\s|가-힣]+', '', i)
    temp = kss.split_sentences(i) 
    for t in temp :
        result1.append(t)


from krwordrank.sentence import summarize_with_sentences

penalty = lambda x:0 if (100 <= len(x) <= 200) else 1
keywords , sents = summarize_with_sentences(result, penalty=penalty, stopwords = stopwords, diversity=0.7,
num_keywords=100, num_keysents=20, scaling=lambda x:1, verbose=False,)
pd.DataFrame(sents).to_excel('abstracts.xlsx')

from krwordrank.sentence import summarize_with_sentences

penalty = lambda x:0 if (100 <= len(x) <= 200) else 1
keywords , sents = summarize_with_sentences(result1, penalty=penalty, stopwords = stopwords, diversity=0.7,
num_keywords=100, num_keysents=20, scaling=lambda x:1, verbose=False,)
pd.DataFrame(sents).to_excel('abstracts1.xlsx')

