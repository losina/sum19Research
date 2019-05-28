import pandas as pd
import csv

def process(data):
  d = data
  processed = []
  for index, cell in data.iterrows():
    url = cell['repo_url'][1:]
    url = url.split(".git")
    new_url = str(url[0])
    new_url += "/commit/"
    new_url += cell['fixed_commit'][1:]
    processed.append(new_url)
  print(processed)
  return processed
# Your main function

def main():
    # Read in CVS result file with pandas
    # PLEASE DO NOT CHANGE
    res = pd.read_csv('./diffresult/diff_results.csv')
    
    processed = process(res)

    dat2 = pd.DataFrame({'diff_url': processed})
    # print(dat2)
    df1 = res.join(dat2)
    df1.to_csv('output_url_added.csv', index=False)


if __name__ == '__main__':
    main()
