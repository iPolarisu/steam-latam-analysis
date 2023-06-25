import steam_api
import csv
from urllib3.exceptions import ConnectTimeoutError

def read_csv_file(file_path):
    data = []
    with open(file_path, 'r', newline='') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)
        for row in reader:
            data.append(row[1])
    return data

def process_steamids(steamids, group_size):
    total_groups = len(steamids) // group_size + 1
    for group_num in range(total_groups):
        start_index = group_num * group_size
        end_index = (group_num + 1) * group_size
        steamids_group = steamids[start_index:end_index]
        try:
            user_info = steam_api.get_user_info(steamids_group)
            save_user_info_to_csv(user_info)
        except ConnectTimeoutError:
            print(f"Timeout for group: {group_num}")
            break

def save_user_info_to_csv(user_info):
    fieldnames = ['steamid', 'personaname', 'lastlogoff', 'timecreated', 'gameid', 'loccountrycode', 'locstatecode', 'loccityid']
    with open('user_info.csv', 'a', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        for user in user_info:
            row = {
                'steamid': user.get('steamid'),
                'personaname': user.get('personaname'),
                'lastlogoff': user.get('lastlogoff'),
                'timecreated': user.get('timecreated'),
                'gameid': user.get('gameid'),
                'loccountrycode': user.get('loccountrycode'),
                'locstatecode': user.get('locstatecode'),
                'loccityid': user.get('loccityid')
            }
            writer.writerow(row)

csv_file_path = 'friends.csv'

steamids = read_csv_file(csv_file_path)

group_size = 100
process_steamids(steamids, group_size)


