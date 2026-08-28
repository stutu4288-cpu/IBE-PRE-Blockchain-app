import urllib.request
import urllib.parse
import http.cookiejar
import os

def test_live_web():
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

    # 1. Login as Owner
    login_data = urllib.parse.urlencode({'role': 'OWNER', 'email': 'owner@example.com', 'password': '1234'}).encode('utf-8')
    req = urllib.request.Request('http://127.0.0.1:8000/login', data=login_data)
    res = opener.open(req)
    print("1. Owner Login Response:", res.status)

    # 2. View Dashboard
    res = opener.open('http://127.0.0.1:8000/owner/dashboard')
    print("2. Owner Dashboard View:", res.status)

    # 3. View Files
    res = opener.open('http://127.0.0.1:8000/owner/files')
    print("3. Owner Files List:", res.status)

    print("\n[SUCCESS] Live Python Web Application verified over HTTP!")

if __name__ == '__main__':
    test_live_web()
