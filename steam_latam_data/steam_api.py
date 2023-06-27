import requests

API_KEY = 'API_KEY'
base_url = 'http://api.steampowered.com'

def get_friend_list(user_id):
    url = f'{base_url}/ISteamUser/GetFriendList/v0001/?key={API_KEY}&steamid={user_id}&relationship=friend'
    response = requests.get(url)
    data = response.json()
    if 'friendslist' in data and 'friends' in data['friendslist']:
        return data['friendslist']['friends']
    return None

def get_user_info(user_ids):
    user_ids_str = ','.join(user_ids)
    url = f'{base_url}/ISteamUser/GetPlayerSummaries/v0002/?key={API_KEY}&steamids={user_ids_str}'
    try:
        response = requests.get(url, timeout=100)
        response.raise_for_status()
        data = response.json()
        if 'response' in data and 'players' in data['response']:
            return data['response']['players']
    except (requests.exceptions.RequestException, ValueError):
        pass
    return []
