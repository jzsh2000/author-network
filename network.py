#!/usr/bin/env python

import os
from Bio import Entrez
from email.utils import parseaddr
from itertools import combinations, permutations

email =  os.environ.get('EMAIL', '')
if '@' not in parseaddr(email)[1]:
    sys.stderr.write("Need a valid email address in 'EMAIL' environment variable!\n")
else:
    Entrez.email = email

def get_article_info(pmid):
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

def search_coauthor(author1, author_list):
    pmid_list = set()
    for author2 in author_list:
        if author1 == author2: continue
        query_string = '"' + author1 + '"[FAU] AND "' + author2 + '"[FAU]'
        handle = Entrez.esearch(db = 'pubmed', term = query_string, idtype = 'acc')
        record = Entrez.read(handle)
        handle.close()
        pmid_list |= set(record['IdList'])

    return list(pmid_list)

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

    if len(sys.argv) > 1 and re.search('[^0-9]', sys.argv[1]) == None:
        pmid = sys.argv[1]
        author = None
        if len(sys.argv) > 2:
            author = sys.argv[2]
            if ',' not in author:
                author = author.split()[-1] + ', ' + author.split()[:-1]
    else:
        sys.stderr.write('Usage  : %s <pubmed id> [author name]\n' % sys.argv[0])
        sys.stderr.write('Example: %s 27549193 "Li, Bo"\n' % sys.argv[0])
        sys.exit(1)

    article_info = get_article_info(pmid)
    author_list = article_info['author']
    print 'Journal : %s' % article_info['journal']
    print 'Title   : %s' % article_info['title']
    print 'Abstract: %s' % article_info['abstract']

    if author == None:
        author = author_list[0]
    elif author not in author_list:
        sys.stderr.write('Cannot find author: %s\n' % author)
        sys.exit(1)

    coauthor_link = {}
    coauthor_set = set(author_list)
    for _ in range(1):
        article_list = search_coauthor(author, author_list)
        print '\n'.join(article_list)
        author_list = []
        for article_id in article_list:
            article_info = get_article_info(article_id)
            title = article_info['title']
            journal = article_info['journal']
            if article_id not in coauthor_link:
                coauthor_link[article_id] = article_info

            for coauthor in coauthor_link[article_id]['author']:
                if coauthor not in coauthor_set and coauthor not in author_list:
                    author_list.append(coauthor)
                    print "New coauthor '%s' in article '%s' (%s)" % \
                            (coauthor, title, journal)

        if not author_list:
            break
        else:
            coauthor_set |= set(author_list)

    # pprint.pprint(coauthor_link)
    author_node, author_edge = coauthor_link_to_network(coauthor_link)
    write_network(author_node, author_edge)
