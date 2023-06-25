import steam_api

test1 = "76561198076737490"
test2 = "76561198011976717"

test_ids = [test1, test2]

info = steam_api.get_user_info(test_ids)
print(info)