#include <stdio.h>
using namespace std;
float cpuPI(int num)
{
    float sum = 0.0f;
    float temp;
    for (int i = 0; i < num; i++)
    {
        temp = (i + 0.5f) / num;
        // printf ("%f\n", temp);
        sum += 4 / (1 + temp * temp);
        // printf ("%f\n", sum);
    }
    return sum / num;
}

int main()
{
    printf("%lf\n", cpuPI(1000000));
    return 0;
}