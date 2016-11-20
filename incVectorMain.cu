#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <time.h>

__global__ void vAdd(int* A, int num_elements){

	//Posicion del thread
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	printf("Hola desde el hilo %d, en el bloque %d y el hilo %d\n", i, blockIdx.x, threadIdx.x);

	if(i < num_elements){
		A[i] = A[i] + 1;
	}


}



void fError(cudaError_t err){
	if(err != cudaSuccess){
		printf("Ha ocurrido un error con codigo: %s\n", cudaGetErrorString(err));
	}
}


int main(){

	int num_elements = 100000;

	//Reservar espacio en memoria HOST


	int * h_A = (int*)malloc(num_elements * sizeof(int));


	if(h_A == NULL ){
		printf("Error al reservar memoria para los vectores HOST");
		exit(1);
	}



	//Inicializar elementos de los vectores
	for(int i=0; i<num_elements; i++){
		h_A[i] = 10;

	}

	cudaError_t err;

	int size = num_elements * sizeof(int);

	int * d_A = NULL;
	err = cudaMalloc((void **)&d_A, size);
	fError(err);


	//Copiamos a GPU DEVICE
	err = cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);


	int HilosPorBloque = 256;
	int BloquesPorGrid = (num_elements + HilosPorBloque -1) / HilosPorBloque;


	cudaError_t Err;

	//Lanzamos el kernel y medimos tiempos
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaEventRecord(start, 0);

	vAdd<<<BloquesPorGrid, HilosPorBloque>>>(d_A, num_elements);
	Err = cudaGetLastError();
	fError(Err);

	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	float tiempo_reserva_host;
	cudaEventElapsedTime(&tiempo_reserva_host, start, stop);


	printf("Tiempo de suma vectores DEVICE: %f\n", tiempo_reserva_host);

	cudaEventDestroy(start);
	cudaEventDestroy(stop);


	//Copiamos a CPU el vector C
	err = cudaMemcpy(h_A, d_A, size, cudaMemcpyDeviceToHost);


	/*for(int i=0; i<num_elements; i++){
		printf("%i", h_A[i]);
		printf("\n");
	}*/

}







