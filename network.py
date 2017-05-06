#!/usr/bin/env python

import os
import copy
from Bio import Entrez
from email.utils import parseaddr
from itertools import combinations, permutations

email =  os.environ.get('EMAIL', '')
if '@' not in parseaddr(email)[1]:
    sys.stderr.write("Need a valid email address in 'EMAIL' environment variable!\n")
else:
    Entrez.email = email

def get_article_info(pmid):
    '''
    collect related information about an article (journal name, title,
    abstract, author list, etc.) using its pubmed id
    '''
    handle = Entrez.efetch(db = 'pubmed', id = pmid, rettype = 'medline', retmode = 'text')
    pm_content = handle.readlines()
    handle.close()

    pm_journal = [x[6:].strip() for x in pm_content if x[:2] == 'JT'][0]
    pm_title = [x[6:].strip() for x in pm_content if x[:2] == 'TI'][0]
    pm_author = [x[6:].strip() for x in pm_content if x[:3] == 'FAU']
    abs_start = False
    pm_abstract = ''
    for line in pm_content:
        if line[:3] == 'AB ':
            pm_abstract = line[6:].strip()
            abs_start = True
        elif abs_start:
            if line[0] == ' ':
                pm_abstract = pm_abstract + ' ' + line.strip()
            else:
                break
        else:
            pass

    return {'journal': pm_journal,
            'title': pm_title,
            'abstract': pm_abstract,
            'author': pm_author}

def search_author(author):
    '''
    search pubmed using the full name of an author, return a list of pubmed
    ids. Author name is in the format of '<family name>, <given name>'
    '''
    query_string = '"' + author + '"[FAU]"'
    handle = Entrez.esearch(db = 'pubmed', term = query_string, retmax = 1000, idtype = 'acc')
    record = Entrez.read(handle)
    handle.close()
    return record['IdList']

def search_coauthor(author1, author_list):
    '''
    search pubmed using the full name of an author and his coauthors, return
    a list of pubmed ids. Author names are in the format of '<family name>,
    <given name>'
    '''
    pmid_list = set()
    for author2 in author_list:
        if author1 == author2: continue
        query_string = '"' + author1 + '"[FAU] AND "' + author2 + '"[FAU]'
        handle = Entrez.esearch(db = 'pubmed', term = query_string, retmax = 1000, idtype = 'acc')
        record = Entrez.read(handle)
        handle.close()
        pmid_list |= set(record['IdList'])

    return list(pmid_list)

def get_coauthor_link(article_list):
    coauthor_link = {}

    print '\n'.join(article_list)
    for article_id in article_list:
        article_info = get_article_info(article_id)
        title = article_info['title']
        journal = article_info['journal']
        coauthor_link[article_id] = copy.deepcopy(article_info)

        for idx, coauthor in enumerate(article_info['author']):
            if coauthor not in coauthor_list:
                if coauthor.lower() in coauthor_list_lower:
                    # 'Yan Xiyun' and 'Yan XiYun' are the same person
                    coauthor_link[article_id]['author'][idx] = \
                            coauthor_list[coauthor_list_lower.index(coauthor.lower())]
                else:
                    coauthor_list.append(coauthor)
                    coauthor_list_lower.append(coauthor.lower())
                    print "New coauthor '%s' in article '%s' (%s)" % \
                            (coauthor, title, journal)

    return coauthor_link

def coauthor_link_to_network(coauthor_link):
    author_node = {}
    author_edge = {}
    for coauthor_dat in coauthor_link.values():
        coauthor_dat_author = coauthor_dat['author']
        for author_ in coauthor_dat_author:
            if author_ not in author_node:
                author_node[author_] = ('A' + str(len(author_node)), 1)
            else:
                aid,size = author_node[author_]
                author_node[author_] = (aid, size + 1)

        for author1, author2 in combinations(coauthor_dat_author, 2):
            author1_abb = author_node[author1][0]
            author2_abb = author_node[author2][0]
            if (author1_abb, author2_abb) not in author_edge:
                author_edge[(author1_abb, author2_abb)] = 1
            else:
                author_edge[(author1_abb, author2_abb)] += 1

    return (author_node, author_edge)

def write_network(author_node, author_edge):
    if not os.path.exists('network'):
        os.mkdir('network')

    # more details about network formats:
    # http://wiki.cytoscape.org/Cytoscape_User_Manual/Network_Formats
    with open('network/network.sif', 'w') as f:
        for author1, author2 in author_edge.keys():
            f.write('%s\tco\t%s\n' % (author1, author2))

    with open('network/node.csv', 'w') as f:
        f.write('id,fau,size\n')
        for author,info in author_node.iteritems():
            f.write('%s,"%s",%s\n' % (info[0], author, info[1]))

    with open('network/edge.csv', 'w') as f:
        f.write('link,size\n')
        for authors,size in author_edge.iteritems():
            f.write('%s,%s\n' % (authors[0] + ' (co) ' + authors[1], size))

if __name__ == '__main__':
    import sys
    import re
    import pprint

    if len(sys.argv) > 1:
        if re.search('[^0-9]', sys.argv[1]) == None:
            pmid = sys.argv[1]
            author = None
            if len(sys.argv) > 2:
                author = sys.argv[2]
                if ',' not in author:
                    author = author.split()[-1] + ', ' + author.split()[:-1]
        else:
            pmid = None
            author = sys.argv[1]
    else:
        sys.stderr.write('Usage  : %s <pubmed id> [author name]\n' % sys.argv[0])
        sys.stderr.write('         %s <author name>\n' % sys.argv[0])
        sys.stderr.write('Example: %s 27549193 "Li, Bo"\n' % sys.argv[0])
        sys.stderr.write('         %s "Yan, Xiyun"\n' % sys.argv[0])
        sys.exit(1)

    if not pmid == None:
        article_info = get_article_info(pmid)
        author_list = article_info['author']
        coauthor_list = author_list
        coauthor_list_lower = map(lambda x:x.lower(), coauthor_list)

        print 'Journal : %s' % article_info['journal']
        print 'Title   : %s' % article_info['title']
        print 'Abstract: %s' % article_info['abstract']

        if author == None:
            author = author_list[0]
        elif author not in author_list:
            sys.stderr.write('Cannot find author: %s\n' % author)
            sys.exit(1)

        article_list = search_coauthor(author, author_list)
    else:
        coauthor_list = [author]
        coauthor_list_lower = [author.lower()]
        article_list = search_author(author)

        if len(article_list) == 0:
            sys.stderr.write('Cannot find author: %s\n' % author)
            sys.exit(1)

    coauthor_link = get_coauthor_link(article_list)

    # pprint.pprint(coauthor_link)
    author_node, author_edge = coauthor_link_to_network(coauthor_link)
    write_network(author_node, author_edge)
