import requests
import csv
from bs4 import BeautifulSoup

# this script web-scraps the top 250 latam users
# with the largest friend list according to steamladder.com

STEAM_LADDER_URL = 'https://steamladder.com/ladder/friends/'
LATAM_CODES = ['AR', 'BR', 'CL', 'CO', 'CR', 'CU', 'DO', 'EC', 'GT', 'HN', 'MX', 'NI', 'PA', 'PE', 'PY', 'SV', 'UY', 'VE']
HEADERS = ['steam_id', 'country']
FILE_NAME = 'steam_most_friends_latam.csv'

with open(FILE_NAME, mode="w", newline="") as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(HEADERS)
    
    for code in LATAM_CODES:

        url = STEAM_LADDER_URL + code.lower()
        print(url)
        response = requests.get(url)
        soup = BeautifulSoup(response.text, "html.parser")

        table = soup.find('table')
        tbody = table.find('tbody')
        rows = tbody.find_all('tr')
        i = 0
        for row in rows:
            steam_id_raw = row.find('td', class_='id')
            try:
                steam_id_raw = steam_id_raw.find('a').get('href')[:-1]
                steam_id_separator = steam_id_raw.rfind('/')
                steam_id = steam_id_raw[steam_id_separator + 1:]
                writer.writerow([steam_id, code])   
            except:
                continue

print("Job done!")
print(f"Check {FILE_NAME} for your results")

