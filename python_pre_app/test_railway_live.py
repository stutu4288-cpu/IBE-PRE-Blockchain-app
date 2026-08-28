import urllib.request
import urllib.parse
import http.cookiejar

RAILWAY_URL = "https://ibe-pre-blockchain-app-production.up.railway.app"

def test_railway():
    print(f"Testing Railway Live URL: {RAILWAY_URL}")
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    
    # 1. Test Home page
    res_home = opener.open(f"{RAILWAY_URL}/")
    print(f"[1] GET / -> Status {res_home.status}")
    assert res_home.status == 200
    
    # 2. Test TA Login
    login_ta = urllib.parse.urlencode({'email': 'ta', 'password': 'ta', 'role': 'ta'}).encode('utf-8')
    res_ta = opener.open(f"{RAILWAY_URL}/login", login_ta)
    print(f"[2] POST /login (TA) -> Status {res_ta.status}, Final URL: {res_ta.geturl()}")
    assert res_ta.status == 200
    assert "/ta/dashboard" in res_ta.geturl()
    
    # 3. Test Owner Login
    login_do = urllib.parse.urlencode({'email': 'sikapalinkz@gmail.com', 'password': '1234', 'role': 'owner', 'private_key': 's8lQ64h2tJ4='}).encode('utf-8')
    res_do = opener.open(f"{RAILWAY_URL}/login", login_do)
    print(f"[3] POST /login (DataOwner) -> Status {res_do.status}, Final URL: {res_do.geturl()}")
    assert res_do.status == 200
    assert "/owner/dashboard" in res_do.geturl()

    # 4. Test User Login
    login_du = urllib.parse.urlencode({'email': 'stutu4288@gmail.com', 'password': '1234', 'role': 'user', 'private_key': 'VAC4uFdeRe8='}).encode('utf-8')
    res_du = opener.open(f"{RAILWAY_URL}/login", login_du)
    print(f"[4] POST /login (DataUser) -> Status {res_du.status}, Final URL: {res_du.geturl()}")
    assert res_du.status == 200
    assert "/user/dashboard" in res_du.geturl()

    # 5. Test CSP Login (Username: csp, Password: CSP or csp)
    login_csp = urllib.parse.urlencode({'email': 'csp', 'password': 'CSP', 'role': 'csp', 'cspkey': 'CSP'}).encode('utf-8')
    res_csp = opener.open(f"{RAILWAY_URL}/login", login_csp)
    print(f"[5] POST /login (CSP) -> Status {res_csp.status}, Final URL: {res_csp.geturl()}")
    assert res_csp.status == 200
    assert "/csp/dashboard" in res_csp.geturl()

    # 6. Test Proxy Login (Username: Cloud or proxy, Password: Cloud or proxy)
    login_proxy = urllib.parse.urlencode({'email': 'Cloud', 'password': 'Cloud', 'role': 'proxy'}).encode('utf-8')
    res_proxy = opener.open(f"{RAILWAY_URL}/login", login_proxy)
    print(f"[6] POST /login (Proxy) -> Status {res_proxy.status}, Final URL: {res_proxy.geturl()}")
    assert res_proxy.status == 200
    assert "/proxy/dashboard" in res_proxy.geturl()

    print("\n=================================================================")
    print("   ALL 5 ROLES TESTED LIVE ON RAILWAY & 100% OPERATIONAL!")
    print("=================================================================")

if __name__ == "__main__":
    test_railway()
