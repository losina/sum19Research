from github import Github

#access token
g = Github('baf0a15087342530803203b886e2385a7340ad1b')
repo = g.get_repo("losina/sum19Research")
print(repo.get_commit('cf646e1d8d745de6a0a2d5dfedccbc810da74ed5').files)