# -*- coding: utf-8 -*-

import sqlite3
import re
import sys
from textatistic import Textatistic

# Establish database connection.
conn = sqlite3.connect('0-data/fixed/read.db')
csql = conn.cursor()

# Update NBER readability statistics.
query = "DELETE FROM NBERStat;"
csql.execute(query)
query = "SELECT NberID, Abstract FROM NBER WHERE Abstract IS NOT NULL;"
nber_articles = csql.execute(query).fetchall()
for article in nber_articles:
    stats = Textatistic(article[1]).dict()
    for key,val in stats.items():
        query = "INSERT INTO NBERStat (NberID, StatName, StatValue) VALUES (?, ?, ?);"
        csql.execute(query, (article[0], key, val))
print('NberStat updated successfully.')

# Update published article readability statistics.
query = "DELETE FROM ReadStat;"
csql.execute(query)
query = "SELECT ArticleID, Abstract FROM Article WHERE Abstract IS NOT NULL AND Abstract <> '';"
articles = csql.execute(query).fetchall()
for article in articles:
    stats = Textatistic(article[1]).dict()
    for key,val in stats.items():
        query = "INSERT INTO ReadStat (ArticleID, StatName, StatValue) VALUES (?, ?, ?);"
        csql.execute(query, (article[0], key, val))
print('ReadStat updated successfully.')

# Commit changes and close database connection.
conn.commit()
conn.close()
