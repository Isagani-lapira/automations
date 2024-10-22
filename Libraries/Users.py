import requests
import string
import secrets
class Users():
    def get_users_via_api(self):
        response = requests.get(url="https://jsonplaceholder.typicode.com/users",verify=False)
        return response.json()
    
    def generate_password(self):
        alphabet = string.ascii_letters + string.digits
        return ''.join(secrets.choice(alphabet) for i in range(20))
    
    
