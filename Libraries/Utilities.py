
from datetime import date

class Utilities():
    def get_todays_date(self):
        today = date.today()
        return today.strftime("%m%d%y")