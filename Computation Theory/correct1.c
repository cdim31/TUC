#include <stdio.h>
#include <stdlib.h>
//#include "lambdalib.h"

const int N = 5;
int find_code(char* name) {

int code;

code = 0;

if(name == "Computation Theory") {

code = 402;
}else {

code = 2025;
}

return code;

}char* find_name(char* field, int field_opt) {

char* name;

name = "Not found";

if(field == "Software") {

if(field_opt == 1) {

name = "Computation Theory";
}
}else {

name = "Introduction to Quantum Computing";
}

return name;

}char* find_field(int field_num) {

char* name;

name = "Not found";

if(field_num == 1) {

name = "Software";
}

if(field_num == 2) {

name = "Hardware";
}

if(field_num == 3) {

name = "Telecommunications";
}

if(field_num == 4) {

name = "Electrical";
}

return name;

}int main() {

char* field;

char* name;

int code;

field = find_field(1);

name = find_name(field, 1);

code = find_code(name);

printf("Full Name: %s, Code Name: %s%d", name, field, code);

return 0;

}

//Correct Syntax !
