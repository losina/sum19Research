import json
import sys

# GHARCHIVE QUERIES
# Program to query gharchive data (json format)
# Current implementation searches for term stored in msg_search
# and returns list of resulting github url, commit hash, and repo name


def sanitize(url, msg):
    lst = url.split("/commits/")
    l = len(lst[0])
    temp = lst[0].split("/")
    repo = temp[5]
    lst[0] = "https://github.com" + lst[0][28:l] + ".git"
    lst += [repo]
    lst += [''.join(i for i in msg if ord(i)<128 and ord(i) not in [40, 41, 93, 91])]
    return tuple([str(x) for x in lst])


def get_urls(filename, event_search):
    msgs = ['fix', 'bug', 'fault', 'error']
    with open(filename) as f:
        data = [json.loads(line) for line in f]
        payloads = [x['payload'] for x in data if x['type'] == event_search]
        commits = [y['commits'][i] for y in payloads if 'commits' in y for i in range(len(y['commits']))]
        bugCommits = []
        for z in commits:
                bol = True
                for msg in msgs:
                        if bol and msg in z['message']:
                                bugCommits += [z] 
                                bol = False
        return str([sanitize(a['url'], a['message']) for a in bugCommits[1:10] if 'message' in a])


fn = sys.argv[1]
evnt_srch = sys.argv[2]
print(get_urls(fn, evnt_srch))