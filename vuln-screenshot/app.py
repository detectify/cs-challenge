from flask import Flask, request, render_template, send_from_directory
from selenium import webdriver
from time import sleep
import requests
import os
import sys
import re
from urllib.parse import urlparse
import socket

app = Flask(__name__)
@app.route("/", methods=['GET', 'POST'])
def index(name=None):
	status = ""
	value = ""
	if request.method == "POST":
		try:
			url = request.form['image-url']
			value = url.lower()
			r = requests.get(url)
			status = take_screenshot(url)
		except Exception as e:
			pattern = re.compile(r'[<>\"\' \n]')
			status = f"Screenshot failed with the error: {e}"
			
			if (pattern.search(value) != None):
				status = "Detected invalid character."
			if "script" in value:
				value = value.replace('script','')

	return render_template('screenshot.html', name=name, status=status, value=value)

@app.route("/success")
def success():
	return render_template('success-screenshot.html')

def take_screenshot(url):
    urlParts = urlparse(url)

    host = urlParts.hostname

    # Protect the admin interface

    print(resolvesToLocalhost(host))
    if resolvesToLocalhost(host):
        raise Exception("Domains that resolve to localhost are not allowed")

    if re.search(r'[a-zA-Z]', host) is None:
        raise Exception("The domain must contain atleast one letter")

    if host.lower() == "localhost":
        raise Exception("Requests to localhost are not allowed")

    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1200,1200')

    driver = webdriver.Chrome('chromedriver', chrome_options=options)
    driver.get(url)

    print(driver.save_screenshot(
        f"/app/screenshots/{host.replace('.','-')}.png"))
    driver.quit()
    return f"View screenshot <a href=\"/images/{host.replace('.','-')}.png\">here</a>"

# Checks if a dns record resolves to localhost
def resolvesToLocalhost(host):
    # Don't try to resolve host if it is an ip address
    try:
        socket.inet_aton(host)
        return False
    except socket.error:
        # it is not a valid ip address, continue
        pass

    try:
        ip = socket.gethostbyname(host)
        if ip.startswith("127"):
            return True
        if ip.startswith("0"):
            return True
    except socket.gaierror:
        print("Failed to resolve host")
        pass
    return False

@app.route('/images/<path:filename>')
def image(filename):
    return send_from_directory("screenshots",
                               filename)

def main():
    print("Running Vulnerable Screenshot Service")


if __name__ == '__main__':
    main()
    app.run()
else:
    application = app
