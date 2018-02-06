# coding: utf-8
import os
import requests
import json

callback_url = 'http://xxxxxxxx.ngrok.io/'

def main():
	print('Sent event...')	
	url = 'https://events.inferenstar.com'

	headers = {
		'Content-Type': 'application/json; charset: utf-8',
		'X-API-Key': os.environ['X_API_KEY']
	}

	payload = {
		'type': 'login_successful',
		'uref': 'user1',
		'email': 'demo@demo.com',
		'remote_ip': '216.58.204.110',
		'callback_url': callback_url,
		'http_headers': {
			'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.74.9 (KHTML, like Gecko) Version/7.0.2 Safari/537.74.9'
		}
	}

	resp = requests.post(url, headers=headers, data=json.dumps(payload))
	print('Response code: {}'.format(resp.status_code))
	print(resp.json())

if __name__ == '__main__':
	main()
