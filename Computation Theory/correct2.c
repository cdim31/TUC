#include <stdio.h>
#include <stdlib.h>
//#include "lambdalib.h"

#define SELF struct Circle *self
typedef struct Circle {
    double x,y;
    double radius;
    double (*area)(SELF);
    double (*perimeter)(SELF);
    void (*move)(SELF,double dx, double dy);
} Circle;

double area(SELF) {

return 3.14 * (pow(self->radius, 2));
}

double perimeter(SELF) {

return 2 * 3.14 * self->radius;
}

void move(SELF,double dx, double dy) {

self->x = self->x + dx;

self->y = self->y + dx;
}

const Circle ctor_Circle = {.area = area, .perimeter = perimeter, .move = move};
#undef SELF
void testMacros() {

writeStr("Chris");

piTimes2 = (2 * 3.14159265);

}double totalArea(Circle c[], int size) {

int i;

double sum;

sum = 0;

for(int i=0; i<size - 1; i++) {

sum = sum + c[i].area();
};

return sum;

}const int N = 100;
int a[100];
int main() {

double sum;

for(int i=0; i<N; i++) {

a[i] = i;
};

int* a = (int*)malloc(100 * sizeof(int));
for (int i = 0; i < 100; ++i){
    a[i] = i;
}

testMacros();

for(int i=0; i<N; i++) {

a[i] = i;
};

double* half = (double*)malloc(100 * sizeof(double));
for (int a_i = 0; a_i < 100; ++a_i) {
    half[a_i] = a[a_i] / 2;
}

Circle c = ctor_Circle;

sum = totalArea(c, 5);

writeStr(sum);

}

//Correct Syntax !
