#Archivo MOD, proyecto EII410: "A single vehicle routing problem with fixed delivery and optional collections"
#Definición de Conjuntos 
set N; #Conjunto de nodos
set A:= {i in N, j in N: i > j}; #Conjunto de aristas (i,j)
set C within N; #Conjunto de nodos de clientes de recolección
set D within N; #Conjunto de nodos de clientes de entrega (delivery)
set S within N; #Subconjunto de nodos, sin incluir el nodo del depósito
set R within A; #Subconjunto de aristas (i,j) infactibles (por capacidad excedida del vehículo)

#Definición de Parámetros
param c{i in N, j in N}; #Costo asociado a cada arista (i, j)
param M{t in C}; #Ganancia asociada al cliente de recolección t
param a{i in D}; #Cantidad a transportar del cliente de entrega i
param Q; #Capacidad del auto
param b{i in C}; #Cantidad a transportar del cliente de recolección i

#Variables
var X {(i,j) in A} binary; #1 si la arista (i,j) es parte del tour, 0 e.o.c.
var Y {t in C} binary; #1 si visito al cliente de recolección t, 0 e.o.c.
var u {i in S} >= 0; #Cantidad acumulada a transportar por el vehículo después de visitar el nodo i

#Función Objetivo
minimize FO: sum{(i,j) in A} c[i,j]*X[i,j] - sum{t in C} M[t]*Y[t];

#Restricciones
s.t. delivery_clients_visited {t in D}: sum{(i,j) in A: i == t} X[t,j] + sum{(i,j) in A: j == t} X[i,t] = 1; 
s.t. collection_clients_visited {t in C}: sum{(i,j) in A: i == t} X[t,j] + sum{(i,j) in A: j == t} X[i,t] = 1*Y[t];
s.t. subtour_elimination {i in S}: sum {j in N: (i,j) in A} X[i,j] <= card(S)-1;
s.t. infeasible_tour {(i,j) in R}: sum{(i,j) in R} X[i,j] <= card(R)-1;
s.t. packets_transportation {(i,j) in A: i != j and j != 0}: u[j] >= u[i] + (if j in D then a[j] else 0) + (if j in C then b[j]*Y[j] else 0);
s.t. vehicle_capacity_lower {i in N: i != 0}: (if i in D then a[i] else 0) + (if i in C then b[i]*Y[i] else 0) <= u[i];
s.t. vehicle_capacity_upper {i in N: i != 0}: u[i]<= Q;
s.t. no_multiple_arcs_incoming {i in S: (i,j) in A}: sum{j in N} X[i,j] = 1;