class DataPage:
    def __init__(self, key, page):
        self.key = key
        self.page = page

    def set_key(self, new_key):
        self.key = new_key

    def set_page(self, new_page):
        self.page = new_page

    def get_key(self):
        return self.key

    def get_page(self):
        return self.page

    def sorting(self, file, get_key):
        file.sort(key=get_key)
        return file
