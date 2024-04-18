class DataClass:

    def __init__(self, key, data):
        self.key = key
        self.data = data

    def get_key(self):
        return self.key

    def set_key(self, new_key):
        self.key = new_key

    def get_data(self):
        return self.data

    def set_data(self, new_data):
        self.data = new_data

