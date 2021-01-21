
#Model file

#Sets
set PRODUCTS;   													#Set of products
set HOSPITALS;   													#Set of hospitals
				
#Parameters				
param demand_hosp {HOSPITALS,PRODUCTS} >= 0;  						#Annual Demand of knee and hip implants in each hospital	
				
param dist_betwn_hosp {HOSPITALS,HOSPITALS} >= 0;					#Distance between Hospitals
				
param total_prod_time {HOSPITALS} >= 0;  							#Total Available Production Time in a year
				
param processing_time {PRODUCTS} >=0;								#Processing Time of a Product
				
param weight {PRODUCTS} >=0;										#Average weight of a Product 
				
param max_equip_allowed {HOSPITALS} >=0;							#Maximum equipment allowed to setup in a hospital which is an AM center
				
param prod_emission >=0; 											#Maximum Production emission allowed
				
param prod_cost {HOSPITALS, PRODUCTS} >=0;							#Production Cost per product
				
param operating_cost {HOSPITALS, PRODUCTS} >=0;						#Operational Cost per product
				
param setup_cost >=0;												#Initial Setup Cost plus maintainance cost
				
param transportation_cost >=0;										#Transportation Cost per mile per weight of the product 
				
param max_equip_capacity {PRODUCTS} >=0; 							#Maximum production capacity of an equipment for a product 


#Decision Variables
var production_volume {HOSPITALS,PRODUCTS} integer >= 0; 			#Production volume of a product in an AM center

var prod_shipped {HOSPITALS,HOSPITALS,PRODUCTS} integer >=0;		#Product shipped from AM center to non AM center

var num_equip {HOSPITALS} integer >=0; 								#Number of equipments to be setup in a hospital which is an AM center

var x {HOSPITALS} binary;											#If hospital is an AM center then 1 , otherwise 0

var y {HOSPITALS} binary;											#If hospital is a non AM center then 1 , otherwise 0


#Objective Function
minimize Total_Cost:
   sum {i in HOSPITALS}
      setup_cost * num_equip[i]  													#Setup Cost
 + sum {i in HOSPITALS, j in HOSPITALS, p in PRODUCTS}
     transportation_cost * dist_betwn_hosp[i,j] * weight[p] * prod_shipped[i,j,p] 	#Transportation Cost
 + sum {i in HOSPITALS, p in PRODUCTS}
      production_volume[i,p] *  prod_cost[i,p]  									#Production Cost
 + sum {i in HOSPITALS, p in PRODUCTS}
 	  operating_cost[i,p] * production_volume[i,p] * processing_time[p]; 			#Operational cost

#Constraints

#This constraint ensures that the value of variables x and y are contradictory to each other.     
subject to connect_am_with_non_am {i in HOSPITALS}:
   x[i] + y[i] = 1;

#Maximum equipment capacity constraint
subject to max_cap_equip {p in PRODUCTS, i in HOSPITALS}:
	production_volume[i,p]  <= max_equip_capacity[p] * num_equip[i];
	
#Total production time availability constraint
subject to prod_time_constraint {i in HOSPITALS}:
   sum {p in PRODUCTS}  production_volume[i,p] * processing_time[p] <= total_prod_time[i] * num_equip[i] ; 
   
#Total demand must be less than or equal to total production volume
subject to total_Demand_hosp {p in PRODUCTS}:
 sum {i in HOSPITALS} demand_hosp[i,p] - sum {i in HOSPITALS} production_volume[i,p] <=0;
 
#This constraint ensures that the demand of the AM center is met first before its surplus is shipped
subject to total_Demand {p in PRODUCTS, i in HOSPITALS}:
   demand_hosp[i,p] * x[i] + sum {j in HOSPITALS} prod_shipped[i,j,p] <= production_volume[i,p];
   
#Demand constraints for implants from hospitals that don't have their own AM centres	
subject to non_am_demand {p in PRODUCTS, j in HOSPITALS}:
	sum{i in HOSPITALS} prod_shipped[i,j,p] >=  demand_hosp[j,p] * y[j];
	 
#Equipment constraints in the AM centre
subject to security_constraint {i in HOSPITALS}: 
    num_equip[i] <= max_equip_allowed[i] * x[i];
    

   
   
   