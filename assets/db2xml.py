#!/usr/bin/env python2

"""Convert a raw Android SMS database (Sqlite file) into a XML file, compatible
with the application "SMS backup & restore"
(http://android.riteshsahu.com/apps/sms-backup-restore).
"""

import sys
import sqlite3
import xml.etree.ElementTree as ET

def list_sms(c):
    """Extract the list of SMS from the given SQlite base"""
    res = []
    cursor = c.execute("""select protocol, address, date, type, subject,
        service_center, read, status, body from sms;""")
    for (protocol, address, date, type, subject, service_center, read, status, body) in cursor:
        res.append({
            "protocol": unicode(protocol) or "0",
            "address": address or "null",
            "date": unicode(date),
            "type": unicode(type) or "null",
            "subject": subject or "null",
            "service_center": service_center or "null",
            "read": unicode(read),
            "status": unicode(status),
            "body": body,
        })
    return res

def print_sms(smses):
    """Print the given list of SMS as a XML file"""
    t = ET.Element(u"smses", {u"count": unicode(len(smses))})
    for sms in smses:
        ET.SubElement(t, "sms", sms)
    print ET.tostring(t, encoding="utf8")


if __name__ == '__main__':
    if len(sys.argv) <= 1:
        print "usage: db2xml file.db"
        sys.exit(1)
    filename = sys.argv[1]
    c = sqlite3.connect(filename)
    sms = list_sms(c)
    # print "extracted %d SMS" % len(sms)
    print_sms(sms)
