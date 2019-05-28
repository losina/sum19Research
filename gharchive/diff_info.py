import json
import sys

# GHARCHIVE DIFF INFO FINDER
# Program to parse gharchive bug results json
# Returns list of resulting github url, fixed commit hash, buggy commit hash


def parse(line):
    return tuple([str(line[x]) for x in ["repo_url", "repo_name", "fixed_hash", "buggy_hash", "commit_msg"]])


def get_info(filename):
    with open(filename) as f:
        json_array = json.load(f)
        arr = []
        # file = f.read()
        # arr = str(file).split("},")
        # arr = [str("".join(i.split()) + "}") for i in arr]
        # arr[0] = arr[0].replace("[", "")
        # arr[len(arr) - 1] = arr[len(arr) - 1].replace("]}", "")
        # data = [json.loads(a) for a in arr]
        return str([parse(item) for item in json_array])


fn = sys.argv[1]
print(get_info(fn))
# print(get_info("diff_test.json"))