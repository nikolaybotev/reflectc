#include <stdio.h>

struct STR0 {
  long *random;
  double eps;
  char c;
};

typedef struct STR0 STR0_T;

struct STR1 {
  STR0_T parent;
  union {
    int sig;
    unsigned int unsig;
  };
  int istruct, k;
  double jstruct;
  char* cstruct; short y;
  int **b[];
};

typedef struct STR1 STR1_T;

typedef struct STR2 STR2_T;

struct STR2 {
  struct STR1 parent;

  STR1_T parent_t;

  char n;
  long long xlog;

  struct STR0 sibling;

  struct STR0 *psibling;

  STR2_T *next;

  unsigned long int t3_degree;

  signed long long _8bit;

  unsigned long long int _4words;

  int arr[];

};

int main() {
  struct STR1 a;
  struct STR2 b;
  a.istruct = 42;
  b.next = &b;
  printf("Hello %d %d .\n", sizeof(struct STR1), offsetof(struct STR1, y));
  return 0;
}
