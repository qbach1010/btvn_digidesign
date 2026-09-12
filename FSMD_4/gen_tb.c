#include <stdio.h>
int M = 8, N = 8;

int main() {
    int A[M][N];
    int X[N];
    int R[M];
    for (int m=0; m<M; m++) {
        R[m] = 0;
        for (int n=0; n<N; n++) R[m] += A[m][n] * X[n];
    }
}