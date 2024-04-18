import math
import random
import struct
import string
import time
from DataClass import DataClass
from DataPage import DataPage

# variables useful for organizing the file and making some other actions
return_value, return_value2, return_value3 = 0, 0, 0
page, index_page, sorted_index_page = 1, 1, 1
# lists that are used to store the generated data strings, pages and sorted keys for writing the 3rd
sort_keys, pages, string_list = [], [], []
# Lists to store records in data.bin - index.bin - sorted_index.bin files
data_instance, index_file, sorted_index_file = [], [], []
# List to store the random keys that are used for searching
given_keys = []
# List used to check that keys generated with N > 1000 are unique
key_list = []
# List with all the possible N values
n = [50, 100, 200, 500, 800, 1000, 2000, 5000, 10000, 50000, 100000, 200000]
# List with all the possible string sizes
data_capacity = [55, 27]
# initialing the value of the variable used to show results
efficiency = 0
# Setting the value of N here
x = n[4]
# Setting the string size
y = data_capacity[1]
# counters for each sum
page1, index_page2, sorted_index_page3 = 1, 1, 1
# Variables used to count time
start1, start2, start3 = 0, 0, 0
end1, end2, end3 = 0, 0, 0


#####################################################################
#                           CODE SECTION                            #
#####################################################################
# Function made to read the files
def file_reader(filename):
    # variables used in function
    page = 1
    index_page = 1
    # Checks the filename
    if filename == "data.bin":
        # opens file for reading
        fr = open(filename, "rb")
        # Loops until the file finishes
        while True:
            # Reads records one by one, and it stores them into a list
            v = fr.tell()
            if v >= page * 256 - (y + 4):
                fr.seek(page * 256)
                page = page + 1
            writen_buf = fr.read(4 + y)
            if not writen_buf:
                break
            key, data = struct.unpack(f'i{y}s', writen_buf)
            data = data.decode('ascii')
            data_instance.append(DataClass(key, data))
    else:
        # opens file for reading
        filer = open(filename, "rb")
        # Loops until the file finishes
        while True:
            # Reads records one by one, and it stores them into the proper list
            v = filer.tell()
            if v > index_page * 256 - 8:
                filer.seek(index_page * 256)
                index_page = index_page + 1
            writen_buf = filer.read(8)
            if not writen_buf:
                break
            key, page = struct.unpack("ii", writen_buf)
            # Checks if it is the 3rd file or the 2nd one to store data in the correct list
            if filename == "sorted_index.bin":
                sorted_index_file.append(DataPage(key, page))
            else:
                index_file.append(DataPage(key, page))


# Function for the binary search used in 3rd way
def binary_search(arr, low, high, num, page_num):
    if high >= low:
        if low == high:
            high = high + 32
        ret = 0
        # computes the value of variable mid
        mid = int((high + low) / 2)
        # then it makes it the first record of the page
        mid = math.floor(8 * mid / 256) * 32
        # Setting the limits of the search
        if mid + 32 > high:
            var = high
        else:
            var = mid + 32
        # if given key is inside the given limits
        if arr[mid].get_key() <= num <= arr[var].get_key():
            # Looping in the page found
            for j in range(mid, var):
                if num == arr[j].get_key():
                    # Finding the record num
                    ret = j
                    break
            # If it is found the function returns the result value and the page of the found record in the data file
            if ret != 0:
                return int(ret), int(page_num)
            # If not found it returns result as -1 to show it and the number of the pages that it searched
            else:
                return -1, int(page_num)
        # if given key is smaller than the smallest key inside the search limits it goes to the smallest half
        elif arr[mid].get_key() > num:
            return binary_search(arr, low, mid - 32, num, page_num + 1)
        # if given key is greater than the biggest key inside the search limits it goes to the bigger half
        elif arr[var].get_key() < num:
            return binary_search(arr, mid + 32, high, num, page_num + 1)
    else:
        return -1, len(sorted_index_file)


# Loop to generate data and keys and store in to lists
for i in range(x):
    # Generate random data
    random_int = random.randint(0, 2 * x)
    while True:
        if random_int in key_list:
            random_int = random.randint(0, 2 * x)
        elif random_int not in key_list:
            break
    key_list.append(random_int)
    random_string = ''.join(random.choices(string.ascii_letters + string.digits, k=y)).encode('ascii')
    string_list.append(random_string)

# Opening the files
f = open('data.bin', 'wb')
file = open("index.bin", "wb")
c_file = open("sorted_index.bin", "wb")
for i in range(x):
    ##################################################################################
    #                               FIRST WAY FILE                                   #
    ##################################################################################
    writen_buf = struct.pack(f'i{y}s', key_list[i], string_list[i])
    var = f.tell()
    if var >= page * 256 - (y + 4):
        f.seek(page * 256)
        page = page + 1
    f.write(writen_buf)
    ##################################################################################
    #                               SECOND WAY FILE                                  #
    ##################################################################################
    writen_buf = struct.pack("ii", key_list[i], page)
    var = file.tell()
    if var > index_page * 256 - 8:
        file.seek(index_page * 256)
        index_page = index_page + 1
    file.write(writen_buf)
    ##################################################################################
    #                                THIRD WAY FILE                                  #
    ##################################################################################
    # storing keys and pages to the list
    sorted_index_file.append(DataPage(key_list[i], page))
    # waits until all the data is loaded
    if i == x - 1:
        # sorts the list object by key
        sorted_index_file.sort(key=lambda k: k.key)
        # Loops in the list
        for a in range(x):
            # Takes each list object and writes its key and page into the file
            writen_buf = struct.pack("ii", sorted_index_file[a].get_key(), sorted_index_file[a].get_page())
            var = c_file.tell()
            if var > sorted_index_page * 256 - 8:
                file.seek(sorted_index_page * 256)
                sorted_index_page = sorted_index_page + 1
            c_file.write(writen_buf)
        # clears the list ,so it can be loaded later with the data that we read
        sorted_index_file.clear()

# Until hear the data is loaded in each file and lists are made
################################################################################
# Random key generation for searching
for i in range(1000):
    if x > 1000:
        given = random.randint(0, 2 * x)
        while True:
            if given in given_keys:
                given = random.randint(0, 2 * x)
            elif given not in given_keys:
                break
        given_keys.append(given)
    else:
        given = random.randint(0, 2 * x)
        given_keys.append(given)
###############################################################################
#                                FIRST WAY                                    #
###############################################################################
# Goes to the file_reader function
file_reader("data.bin")
# Timer starts counting for 1st way
start1 = start1 + time.time_ns()
# Looping in searching keys list
for given_key in given_keys:
    m = 0
    return_value = 0
    # Looping in the list with data
    for instance in range(0, len(data_instance)):
        if return_value == 1:
            break
        # Checks if the searching key is equal to a key in the data list and makes the calculations
        if given_key is data_instance[instance].get_key():
            m = 1
            if instance == len(data_instance) and page1 == 1:
                page1 = math.ceil(instance / math.floor(256 / (y + 4)))
            else:
                page1 = page1 + math.ceil(instance / math.floor(256 / (y + 4)))
            return_value = 1
            break
        if instance == len(data_instance) - 1 and m == 0 and given_key is not data_instance[instance].get_key():
            page1 = page1 + math.ceil(instance / math.floor(256 / (y + 4)))
            break
        else:
            continue
# Timer stops counting for 1st way
end1 = end1 + time.time_ns()
###############################################################################
#                               SECOND WAY                                    #
###############################################################################
# Goes to the file_reader function
file_reader("index.bin")
# Timer starts counting for 2nd way
start2 = start2 + time.time_ns()
# Looping in searching keys list
for given_key in given_keys:
    e = 0
    # Looping in index file data
    for index in range(0, len(index_file)):
        # Checks if the searching key is equal to a key in the data list and makes the calculations
        if given_key is index_file[index].get_key():
            e = 1
            # Computing the starting point for the search in the data file
            index_page2 = index_page2 + math.ceil(index / 32)
            b_page = index_file[index].get_page()
            search_indicator = math.floor(256 / (y + 4)) * (b_page - 1)
            # Computing the stop point for the search in the data file
            if search_indicator + math.floor(256 / (y + 4)) > len(data_instance):
                stop = len(data_instance)
            else:
                stop = search_indicator + 4
            return_value2 = 0
            # Looping in data file to find the record and add 1 page in the previous sum
            for instance in range(search_indicator - 1, stop):
                if return_value2 == 1:
                    break
                if given_key is data_instance[instance].get_key():
                    index_page2 = index_page2 + 1
                    return_value2 = 1
                    break
                else:
                    continue
        # if a key isn't in a page add the length of the file to the sum
        elif given_key != index_file[index].get_key() and e == 0 and index == len(index_file) - 1:
            index_page2 = index_page2 + math.ceil(index / 32)
        else:
            continue
# Timer stops counting for 2nd way
end2 = end2 + time.time_ns()
###############################################################################
#                                   THIRD WAY                                 #
###############################################################################
# Sets the file pointer
c_file.seek(sorted_index_page * 256)
# Goes to the file_reader function
file_reader("sorted_index.bin")
# Timer starts counting for 3rd way
start3 = start3 + time.time_ns()
# Looping in searching keys list
for given_key in given_keys:
    # Goes to binary_search function to return the value to check if the given key is equal to the key in data and also
    # the page where it is found or the length of the file if it is not found
    result, _page = binary_search(sorted_index_file, 0, len(sorted_index_file) - 1, given_key, 1)
    sorted_index_page3 = sorted_index_page3 + _page
    # if result != -1 it means that the key was found
    if int(result) != -1:
        # Computing the starting point for the search in the data file
        page = sorted_index_file[int(result)].get_page()
        search_indicator = (math.floor(256 / (y + 4))) * (page - 1)
        # Computing the stop point for the search in the data file
        if search_indicator + math.floor(256 / (y + 4)) > len(data_instance):
            stop = len(data_instance)
        else:
            stop = search_indicator + 4
        return_value3 = 0
        # Looping in the data file to find the record and add 1 page to the previous sum
        for instance in range(search_indicator - 1, stop):
            if return_value3 == 1:
                break
            if given_key is data_instance[instance].get_key():
                sorted_index_page3 = sorted_index_page3 + 1
                return_value3 = 1
                break
            else:
                continue
    else:
        continue
# Timer stops counting for 3rd way
end3 = end3 + time.time_ns()
# Results printing
print("-----------First Way-----------")
print(f"{page1} total pages")
time1 = (end1 - start1) / 1000
print(f"Time in ns:{time1}")
efficiency = page1 / 1000
print(f"The efficiency is: {efficiency:.01f}")
print("-----------Second Way----------")
print(f"{index_page2} total pages")
time2 = (end2 - start2) / 1000
print(f"Time in ns:{time2}")
efficiency = index_page2 / 1000
print(f"The efficiency is: {efficiency:.01f}")
print("-----------Third Way-----------")
print(f"{sorted_index_page3} total pages")
time3 = (end3 - start3) / 1000
print(f"Time in ns:{time3}")
efficiency = sorted_index_page3 / 1000
print(f"The efficiency is: {efficiency:.01f}")
