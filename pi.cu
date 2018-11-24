#include <stdio.h>

__global__ void reducePI(float *d_sum, int num)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x; //线程数
    int gid = id;
    float temp;
    extern float __shared__ s_pi[]; // 动态分配长度为block的线程数
    s_pi[threadIdx.x] = 0.0f;

    while (gid < num) {
        temp = (gid + 0.5f) / num; // 当前x的值
        s_pi[threadIdx.x] += 4.0f;
        gid += blockDim.x * gridDim.x;
    }

    for (int i = (blockDim.x>>1); i > 0; i>>=1) {
        if (threadIdx.x < i) {
            s_pi[threadIdx.x] += s_pi[threadIdx.x+i];
        }
        __syncthreads();
    }
    if (threadIdx.x == 0) d_sum[blockIdx.x] = s_pi[0];
}

__global__ void reducePI2(float *d_sum,int num,float *d_pi)
{
    int id=threadIdx.x;
    extern float __shared__ s_sum[];
    s_sum[id]=d_sum[id];
    __syncthreads();
    
    for(int i = (blockDim.x>>1); i>0; i>>=1){
        if(id<i) s_sum[id]+=s_sum[id+i];
        __syncthreads();
    }
    // printf("%d,%f\n",id,s_sum[id]);
    if(id==0)
    {
    *d_pi=s_sum[0]/num;
    // printf("%d,%f\n",id,*pi);
    } 
}
int main()
{
    return 0;
}