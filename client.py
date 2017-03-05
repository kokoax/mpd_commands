from mpd import MPDClient

client = MPDClient()
client.timeout = 10
client.idletimeout = None
client.connect("localhost", 6600)
# print(client.mpd_version)
# print(client.status())

print(client._execute("status",[]))

client.close()
client.disconnect()

