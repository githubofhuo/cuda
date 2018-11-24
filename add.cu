#include <stdio.h>
#include <cuda_runtime.h>
#include "freshman.h"

__global__ void sumMatrix(float * MatA,float * MatB,float * MatC,int nx,int ny)
{
    int ix=threadIdx.x+blockDim.x*blockIdx.x;
    int iy=threadIdx.y+blockDim.y*blockIdx.y;
    int idx=ix+iy*ny;
    if (ix<nx && iy<ny)
    {
      MatC[idx]=MatA[idx]+MatB[idx];
    }
}

int main(int argc,char** argv)
{
  //printf("strating...\n");
  //initDevice(0);
  int nx=1<<13;
  int ny=1<<13;
  int nxy=nx*ny;
  int nBytes=nxy*sizeof(float);

  //Malloc
  float* A_host=(float*)malloc(nBytes);
  float* B_host=(float*)malloc(nBytes);
  float* C_host=(float*)malloc(nBytes);
  float* C_from_gpu=(float*)malloc(nBytes);
  initialData(A_host,nxy);
  initialData(B_host,nxy);

  //cudaMalloc
  float *A_dev=NULL;
  float *B_dev=NULL;
  float *C_dev=NULL;
  CHECK(cudaMalloc((void**)&A_dev,nBytes));
  CHECK(cudaMalloc((void**)&B_dev,nBytes));
  CHECK(cudaMalloc((void**)&C_dev,nBytes));


  CHECK(cudaMemcpy(A_dev,A_host,nBytes,cudaMemcpyHostToDevice));
  CHECK(cudaMemcpy(B_dev,B_host,nBytes,cudaMemcpyHostToDevice));

  int dimx=argc>2?atoi(argv[1]):32;
  int dimy=argc>2?atoi(argv[2]):32;

  double iStart,iElaps;

  // 2d block and 2d grid
  dim3 block(dimx,dimy);
  dim3 grid((nx-1)/block.x+1,(ny-1)/block.y+1);
  iStart=cpuSecond();
  sumMatrix<<<grid,block>>>(A_dev,B_dev,C_dev,nx,ny);
  CHECK(cudaDeviceSynchronize());
  iElaps=cpuSecond()-iStart;
  printf("GPU Execution configuration<<<(%d,%d),(%d,%d)|%f sec\n",
        grid.x,grid.y,block.x,block.y,iElaps);
  CHECK(cudaMemcpy(C_from_gpu,C_dev,nBytes,cudaMemcpyDeviceToHost));

  cudaFree(A_dev);
  cudaFree(B_dev);
  cudaFree(C_dev);
  free(A_host);
  free(B_host);
  free(C_host);
  free(C_from_gpu);
  cudaDeviceReset();
  return 0;
}

