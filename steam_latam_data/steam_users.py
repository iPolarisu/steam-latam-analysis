import steam_api
import csv
from urllib3.exceptions import ConnectTimeoutError
import time

def read_csv_file(file_path):
    data = []
    with open(file_path, 'r', newline='') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)
        for row in reader:
            data.append(row[1])
    return data

def process_steamids(steamids, group_size, start, end):
    for group_num in range(start, end):
        start_index = group_num * group_size
        end_index = (group_num + 1) * group_size
        steamids_group = steamids[start_index:end_index]
        try:
            time.sleep(0.5)
            user_info = steam_api.get_user_info(steamids_group)
            save_user_info_to_csv(user_info)
        except ConnectTimeoutError:
            print(f"Timeout for group: {group_num}")
            break

def save_user_info_to_csv(user_info):
    fieldnames = ['steamid', 'personaname', 'lastlogoff', 'timecreated', 'gameid', 'gameextrainfo', 'loccountrycode', 'locstatecode', 'loccityid']
    with open('user_info.csv', 'a', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        for user in user_info:
            row = {
                'steamid': user.get('steamid'),
                'personaname': user.get('personaname'),
                'lastlogoff': user.get('lastlogoff'),
                'timecreated': user.get('timecreated'),
                'gameid': user.get('gameid'),
                'gameextrainfo' : user.get('gameextrainfo'),
                'loccountrycode': user.get('loccountrycode'),
                'locstatecode': user.get('locstatecode'),
                'loccityid': user.get('loccityid')
            }
            writer.writerow(row)

csv_file_path = 'friends.csv'

steamids = read_csv_file(csv_file_path)

group_size = 100
total_groups = len(steamids) // group_size + 1 #10362
groups = total_groups // 4
iter = 1
start = groups*(iter-1)
end = groups*(iter) 
process_steamids(steamids, group_size, start, end)


