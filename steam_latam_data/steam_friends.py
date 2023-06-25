import steam_api
import csv
import datetime

PATH_TO_INPUT = "../steam_ladder_data/steam_most_friends_latam.csv"
FILE_NAME = "friends.csv"
HEADERS = ["id_0","id_1","friends_since"]

def unix_to_timestamp(unix_time):
    try:
        timestamp = int(unix_time)
        date = datetime.datetime.fromtimestamp(timestamp)
        date_format = date.strftime("%Y-%m-%d")
        return date_format
    except ValueError:
        return None

with open(FILE_NAME, mode="w", newline="") as friends_file:
    writer = csv.writer(friends_file)
    writer.writerow(HEADERS)

iterations = 0
skipped = 0
with open(PATH_TO_INPUT, 'r') as input_file:
    reader = csv.reader(input_file)
    next(reader)
    for row in reader:
        print(str(iterations))
        steam_id = row[0]
        friends = steam_api.get_friend_list(steam_id)
        with open(FILE_NAME, 'a', newline='') as friends_file:
            writer = csv.writer(friends_file)
            if not friends:
                skipped += 1
                iterations += 1
                continue
            for friend in friends:
                friend_id = friend['steamid']
                friend_timestamp = unix_to_timestamp(friend['friend_since'])
                writer.writerow([steam_id, friend_id, friend_timestamp])
        iterations += 1

print("Job done!")