#!/bin/python3

import os
import asyncio
from datetime import datetime
from collections import defaultdict
from pyrogram import Client, idle
from pyrogram.errors import BadRequest
from prometheus_client import Gauge, start_http_server


whitelist_string = os.environ.get('UO_WHITELIST', None)
whitelist = whitelist_string.split(',') if whitelist_string else None
metric_name = os.environ.get('UO_METRIC', 'user_online')
session_name = os.environ.get('UO_SESSION', 'darkkeks')

app = Client(session_name)

online = Gauge(metric_name, 'User online', ['login'])

# user_id -> update counter
updates = defaultdict(lambda: 0)


def set_status(user_id, login, value):
    print(f"Setting {login} (id = {user_id}) online to {value}")
    online.labels(login=login).set(value)


async def set_offline(delay, user_id, login, update_counter):
    print(f"Deferring offline for {login} (id = {user_id}) after {delay} seconds")
    await asyncio.sleep(delay)

    if updates[user_id] == update_counter:
        print(f"Deffered offline for {login} (id = {user_id})")
        set_status(user_id, login, 0)
    else:
        print(f"Newer status update was received for {login} (id = {user_id})")


async def get_login(client, user_id):
    try:
        user = await client.get_users(user_id)
    except BadRequest as e:
        print(f"Received user status for unknown peer {user_id}")
        return None

    if user.username:
        return user.username

    if user.first_name:
        name = user.first_name
        if user.last_name:
            name += ' ' + user.last_name
        return name

    if user.last_name:
        return user.last_name

    return user_id


@app.on_user_status()
async def handle_user_update(client, update):
    print(f"Update: {update}")
    user_id = update.id

    updates[user_id] += 1
    update_counter = updates[user_id]

    login = await get_login(client, user_id)
    if login is None:
        return

    if whitelist and login not in whitelist:
        print(f'Skipping "{login}" (not in whitelist)')
        return

    value = 1 if update.status == 'online' else 0

    set_status(update.id, login, value)

    if update.status == 'online':
        next_offline_date = update.next_offline_date
        delay = next_offline_date - datetime.now().timestamp()
        asyncio.create_task(set_offline(delay, user_id, login, update_counter))


if whitelist:
    print(f"Starting with whitelist: {','.join(whitelist)}")
else:
    print("Starting without whitelist")

loop = asyncio.get_event_loop()
start_http_server(9101)
app.start()

# preload all peers
print("Preloading")
for dialog in app.iter_dialogs():
    name = dialog.chat.title or f"{dialog.chat.first_name} {dialog.chat.last_name}"
print("Done preloading")

idle()
loop.stop()
app.stop()
