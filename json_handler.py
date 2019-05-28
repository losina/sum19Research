import json
import sys

# GHARCHIVE QUERIES
# Program to query gharchive data (json format)
# Current implementation searches for term stored in msg_search
# and returns list of resulting github url, commit hash, and repo name


def sanitize(url):
    lst = url.split("/commits/")
    l = len(lst[0])
    temp = lst[0].split("/")
    repo = temp[5]
    return (repo, "https://github.com" + lst[0][28:l] + ".git")

def process_msg(msg):
        str1 = ''
        for i in msg:
                if i == '\"':
                        str1 += '\"'
                elif ord(i) in [40, 41, 93, 91]:
                        str1 += ' '
                else:
                        str1 += i
        return str1

def get_urls(filename, event_search):
        jsonf = []
        with open(filename) as f:
                data = [json.loads(line) for line in f]
                payloads = [x['payload'] for x in data if x['type'] == event_search]
                for y in payloads:
                        if 'commits' in y:
                                parent = y['before']
                                for i in range(len(y['commits'])):
                                        commit = y['commits'][i]
                                        # order of repo_name, repo_url, buggy_hash, fixed_hash, message
                                        url_repo = sanitize(commit['url'])
                                        elem = {'repo_name' : url_repo[0], 
                                        'repo_url' : url_repo[1], 
                                        'buggy_hash' : parent, 
                                        'fixed_hash' : commit['sha'], 
                                        'commit_msg' : process_msg(commit['message'])}
                                        jsonf.append(elem)
                                        parent = y['commits'][i]['sha']
        # with open('~\\sum19\\sum19Research\\2019-03-output.json', 'w') as outfile:
        with open('2019-03-output.json', 'w') as outfile:
                json.dump(jsonf, outfile)


fn = sys.argv[1]
evnt_srch = sys.argv[2]
print(get_urls(fn, evnt_srch))


