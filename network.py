#!/usr/bin/env python

import os
from Bio import Entrez
from email.utils import parseaddr

email =  os.environ.get('EMAIL', '')
if '@' not in parseaddr(email)[1]:
    sys.stderr.write("Need a valid email address in 'EMAIL' environment variable!\n")
else:
    Entrez.email = email

def fetch_pubmed_record(pmid):
    handle = Entrez.efetch(db = 'pubmed', id = pmid, rettype = 'medline', retmode = 'text')
    pm_content = handle.readlines()
    handle.close()
    return pm_content

def get_article_info(pm_content):
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
    return (pm_journal, pm_title, pm_abstract, pm_author)

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

if __name__ == '__main__':
    import sys
    import re

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

    journal, title, abstract, author_list = get_article_info(fetch_pubmed_record(pmid))
    print 'Journal : %s' % journal
    print 'Title   : %s' % title
    print 'Abstract: %s' % abstract

    if author == None:
        author = author_list[0]
    elif author not in author_list:
        sys.stderr.write('Cannot find author: %s\n' % author)
        sys.stderr.write('\n'.join(author_list) + '\n')
        sys.exit(1)

    print '\n'.join(search_coauthor(author, author_list))
