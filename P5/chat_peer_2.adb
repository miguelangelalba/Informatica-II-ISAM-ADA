--Miguel Ángel Alba Blanco
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Chat_Messages;
with Ada.Command_Line;
with Chat_Handlers;
with Maps_G;
with Debug;
with Pantalla;
with Ada.Calendar;
with List_Image;
with Maps_Protector_G;
with Timed_Handlers;
--with Gestion_Message;


procedure Chat_Peer_2 is
	
	package CM renames Chat_Messages;
   package LLU renames Lower_Layer_UDP;
   package ACL renames Ada.Command_Line;
   package ASU renames Ada.Strings.Unbounded;
   package CH renames Chat_Handlers;
   package LI renames List_Image;
   --package GM renames Gestion_Message;

   use type CH.Seq_N_T;
   use type Ada.Calendar.Time;
   Use type LLU.End_Point_Type;
   Use type Natural; 

   Usage_Error: exception;
---------------------------------------
-- Declaración de Variables Globales --
---------------------------------------

Seq_N:CH.Seq_N_T:=1;

------------------------------
-- Declaración de Funciones --
------------------------------

function Receive_Reject (EP_R:LLU.End_Point_Type) return Boolean is

		Expired:Boolean:=False;
		Buffer:aliased LLU.Buffer_Type(1024);
		Mess:CM.Message_Type;
		EP_H_Sender:LLU.End_Point_Type;
		Nick_Sender: ASU.Unbounded_String;
		Warehouse_Aux: CH.Neighbors.Keys_Array_Type;
		Plazo_Espera:Duration;
	begin
		--No estoy seguro de que esto funcione así
		Plazo_Espera:= 0.5+(6.0*CH.Max_Delay/1000.0);
		LLU.Receive(EP_R, Buffer'Access, Plazo_Espera, Expired);
		If Expired = True then	
			debug.Put_Line(("Se puede usar el Nick"),Pantalla.Verde);
			return False;
		else
			Mess:= CM.Message_Type'Input (Buffer'Access);
			EP_H_Sender:= LLU.End_Point_Type'Input(Buffer'Access);
			Nick_Sender:= ASU.Unbounded_String'Input(Buffer'Access);
			--Como utilizo un paquete para escribir las direcciones, tengo que hacer esto
			-- Debo mejorarlo...
			Warehouse_Aux(1):= EP_H_Sender;
			Ada.Text_IO.Put_Line("User rejected because " & Li.Image_EP(Warehouse_Aux)
										 & "is using the same nick");
			 
			debug.Put_Line(("Nick duplicado"),Pantalla.Verde);
			debug.Put_Line((ASU.To_String(Nick_Sender)),Pantalla.Rojo);

			return True;
		end if;


end Receive_Reject;


-----------------------------------
-- Declaración de Procedimientos --
-----------------------------------
	procedure Add_Latest_Msgs (EP_H_Creat: in LLU.End_Point_Type;
						 	Seq_N: in CH.Seq_N_T) is
		Success : Boolean;

	begin
		CH.Latest_Msgs.Put(CH.Map_Latest_Msgs,EP_H_Creat,Seq_N,Success);
		
		If Success = True	then
			Debug.Put_Line(("Se añadió correctamente a Latest_Msgs"),Pantalla.Verde);
		else	
			Debug.Put_Line(("No se ha añadiado,'Máximos Latest_Msgs'"),
									Pantalla.Rojo);
		end if; 

	end Add_Latest_Msgs;



   procedure Send_msg (Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
	                          P_Buffer: access LLU.Buffer_Type;
	                          P_Buffer_Main:in CH.Buffer_A_T;
	                          EP_H_Creat:in LLU.End_Point_Type;
	                          Seq_N:in CH.Seq_N_T) is 
	                          
	   Time_Retransmision: Ada.Calendar.Time;
		Value:CH.Value_T;
		Plazo_Retransmision: Duration;
	begin 
	  
	   for I in 1..10  loop
	            
	      If LLU.Image(Warehouse_Nodo_EP(I)) /= LLU.Image(Null) then  
	   		
	   		LLU.Send(Warehouse_Nodo_EP(I),P_Buffer);
	   		debug.Put((" Enviando.." & Integer'Image(I) & " "),Pantalla.Amarillo);
	   		
	   		Value.EP_H_Creat:=EP_H_Creat;
				Value.Seq_N:=Seq_N;
				Value.P_Buffer:=P_Buffer_Main;
				Plazo_Retransmision:= 2* Duration(CH.Max_Delay)/1000;
				Time_Retransmision:=  Ada.Calendar.Clock + Plazo_Retransmision;
				CH.Sender_Buffering.Put(CH.Map_Sender_Buffering,Time_Retransmision,Value);
				Debug.Put_Line(("Añadiendo a Buffering"),Pantalla.Verde);
				Timed_Handlers.Set_Timed_Handler(Time_Retransmision, CH.Resend_Msg_Timer'Access);

	   	end if;
	       
	   end loop;
	  	
	  	Debug.Put_Line(LI.Image_EP(Warehouse_Nodo_EP),Pantalla.Verde);
	  	
	  	
	end Send_msg;

	procedure Msg_Writer(Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
								EP_H_Creat: In LLU.End_Point_Type;
								EP_H_Rsnd: in LLU.End_Point_Type;
								Nick_Aux: in ASU.Unbounded_String;
								Message: in Asu.Unbounded_String) is
		
	begin
		CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
		Seq_N:=Seq_N+1;
		
		CM.Message_Type'Output(CM.P_Buffer_Main,CM.Writer);
		LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Creat);
      CH.Seq_N_T'Output(CM.P_Buffer_Main,Seq_N);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Rsnd);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Nick_Aux);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Message);
      Send_msg(Warehouse_Nodo_EP,CM.P_Buffer_Main,CM.P_Buffer_Main,EP_H_Creat,Seq_N);
   
   end Msg_Writer;
	

	procedure Msg_Logout (Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
								EP_H_Creat: In LLU.End_Point_Type;
								EP_H_Rsnd: in LLU.End_Point_Type;
								Nick_Aux: in ASU.Unbounded_String;
								Confirm_Sent: in Boolean) is
		
	begin
		
		CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
		Seq_N:= Seq_N+1;
		debug.Put_Line(("Iniciando P_Logout..."),Pantalla.Magenta);
		
		CM.Message_Type'Output(CM.P_Buffer_Main,CM.Logout);
		LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Creat);
      CH.Seq_N_T'Output(CM.P_Buffer_Main,Seq_N);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Rsnd);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Nick_Aux);
      Boolean'Output(CM.P_Buffer_Main,Confirm_Sent);
      Send_msg(Warehouse_Nodo_EP,CM.P_Buffer_Main,CM.P_Buffer_Main,EP_H_Creat,Seq_N);

      
	end Msg_Logout;

	procedure Msg_Confirm(Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
   							EP_H_Creat:in LLU.End_Point_Type;
   							EP_H_Rsnd: in LLU.End_Point_Type;
   							Nick_Aux:in ASU.Unbounded_String) is
	
	begin

		CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
		Seq_N:=Seq_N+1;
		debug.Put_Line(("Enviando Confimación..."),Pantalla.Amarillo);
		CM.Message_Type'Output(CM.P_Buffer_Main,CM.Confirm);
		LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Creat);
      CH.Seq_N_T'Output(CM.P_Buffer_Main,Seq_N);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Rsnd);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Nick_Aux);
      
      Send_msg(Warehouse_Nodo_EP,CM.P_Buffer_Main,CM.P_Buffer_Main,EP_H_Creat,Seq_N);

      --Send_msg(Warehouse_Nodo_EP,P_Buffer);
   
	end Msg_Confirm;

   procedure Msg_Init(Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
										EP_H_Creat: in LLU.End_Point_Type;
										EP_H_Rsnd: in LLU.End_Point_Type;
										EP_R_Creat: in LLU.End_Point_Type;
										Nick_Aux:in ASU.Unbounded_String) is
										
		--Buffer:aliased LLU.Buffer_Type(1024);
		--P_Buffer: Access LLU.Buffer_Type;
		P_Buffer_Main:CH.Buffer_A_T;
		
	begin
		
		CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);		
		--Add_Latest_Msgs(EP_H_Creat,Seq_N);
		debug.Put_Line(("Iniciando P_Admision..."),Pantalla.Magenta);
		debug.Put_Line(("Enviando Init"),Pantalla.Amarillo);
		CM.Message_Type'Output(CM.P_Buffer_Main,CM.Init);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Creat);
      CH.Seq_N_T'Output(CM.P_Buffer_Main,Seq_N);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Rsnd);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_R_Creat);
      debug.Put(("EP_R_Creat:" & LLU.Image(EP_R_Creat)),Pantalla.Verde);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Nick_Aux);
          
		P_Buffer_Main:= CM.P_Buffer_Main;
      Send_msg(Warehouse_Nodo_EP,CM.P_Buffer_Main,CM.P_Buffer_Main,EP_H_Creat,Seq_N);
    
     
   end Msg_Init;


	procedure Get_Nodo(Warehouse_Nodo_EP: out CH.Neighbors.Keys_Array_Type) is

	begin
	-- Este procedure no hubiese sido necesario crearlo
		Warehouse_Nodo_EP := CH.Neighbors.Get_Keys(CH.Map_Neighbors);
		
	end Get_Nodo;

   procedure Add_Nodo(Nick_Aux: in ASU.Unbounded_String;
						 	Neighbor_h: in LLU.End_Point_Type) is
		Value: Ada.Calendar.Time := Ada.Calendar.Clock;
		Success : Boolean;

	begin
		CH.Neighbors.Put(CH.Map_Neighbors,Neighbor_h,Value,Success);
		
		If Success = True	then
			Debug.Put_Line(("Se añadió correctamente"),Pantalla.Verde);
		else	
			Debug.Put_Line(("No se ha añadiado,'Máximos de nodos"),
									Pantalla.Rojo);
		end if; 

	end Add_Nodo;

	procedure Add_Destination(Warehouse_Nodo_EP:CH.Neighbors.Keys_Array_Type;
									EP_H_Creat:LLU.End_Point_Type;
									Seq_N:CH.Seq_N_T)is
	
		Identificador:CH.Mess_Id_T;
		Warehouse_Destination:CH.Destinations_T;
		Time: Ada.Calendar.Time := Ada.Calendar.Clock;
	begin
		Identificador.Ep:=EP_H_Creat;
		Identificador.Seq:=Seq_N;

		for I in 1..10  loop
			If Warehouse_Nodo_EP(I) /= null then
				Warehouse_Destination(I).Ep:=Warehouse_Nodo_EP(I);
				Warehouse_Destination(I).Retries:=0;
			end if;
		end loop;
	-- esto creo que puede estar mal y se tendría que meter en el bucle
		CH.Sender_Dests.Put(CH.Map_Sender_Dests,Identificador,Warehouse_Destination);
		Debug.Put_Line(("Añadiendo a Destinations"),Pantalla.Verde);
	
	end Add_Destination;


------------------------------
-- Declaración de Variables --
------------------------------
Num_Arg: Integer range 5..9;
Port: Integer;
Min_Delay:Integer;
Fault_Pct:Natural; --range 0..100;
Nb_Host: ASU.Unbounded_String;
Nb_Port:Integer;
--Buffer:aliased LLU.Buffer_Type(1024);
Maquina:ASU.Unbounded_String;
Dir_IP:ASU.Unbounded_String;
EP_R :LLU.End_Point_Type;
EP_H:LLU.End_Point_Type;
Neighbor_h_1: LLU.End_Point_Type;
Neighbor_h_2: LLU.End_Point_Type;
Warehouse_Nodo_EP: CH.Neighbors.Keys_Array_Type;
Confirm_Sent:Boolean;
Salir:Boolean:=False;
Message:ASU.Unbounded_String;
Status:Boolean;
Plazo_Retransmision:Duration;

------------------------
-- Programa Principal --
------------------------

begin

	Num_Arg:=ACL.Argument_Count;
	if ACL.Argument_Count > 9 or ACL.Argument_Count < 5 or 
		ACL.Argument_Count = 6 or ACL.Argument_Count = 8 then
	  	Num_Arg:=ACL.Argument_Count;
	  	raise Usage_Error;
	end if;	

	Maquina := ASU.To_Unbounded_String (LLU.Get_Host_Name);
	Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
	Port:= Integer'Value(ACL.Argument(1));
	LLU.Bind_Any(EP_R);

	EP_H:= LLU.Build(ASU.To_String(Dir_IP),Port);
	LLU.Bind (EP_H,CH.Client_Handler'Access);

	--Creo que tengo que crear un Ep para el manejador temporizador
	CH.Nick:= ASU.To_Unbounded_String(ACL.Argument(2));
	Min_Delay:=Integer'Value(ACL.Argument(3));
	CH.Max_Delay:=Integer'Value(ACL.Argument(4));
	Fault_Pct:=Natural'Value(ACL.Argument(5));
	Plazo_Retransmision:= 2* Duration(CH.Max_Delay)/1000;

	CH.Max_Retransmisiones:= (10 + ((Fault_Pct/10)*(Fault_Pct/10)));
	LLU.Set_Faults_Percent(Fault_Pct);
	LLU.Set_Random_Propagation_Delay(Min_Delay,CH.Max_Delay);

	Case	Num_Arg is

	when 5 =>

		Debug.Put_Line(("NOT following admission protocol because we have no initial contacts ..."),Pantalla.Verde);
		Ada.Text_IO.Put_Line("Chat_Peer");
		Ada.Text_IO.Put_Line("=========");
		Ada.Text_IO.New_Line;
		Ada.Text_IO.Put_Line ("Logging into chat with nick:" & ASU.To_String(CH.Nick));
	when 6 =>
		null;
	when 7 =>
		Nb_Host := ASU.To_Unbounded_String(ACL.Argument(6));
		Nb_Port:=Integer'Value(ACL.Argument(7));
		Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Nb_Host)));
		Neighbor_h_1 := LLU.Build(ASU.To_String(Dir_IP), Nb_Port);						

		Add_Nodo(CH.Nick,Neighbor_h_1);
		Get_Nodo(Warehouse_Nodo_EP);
		Msg_Init(Warehouse_Nodo_EP,EP_H,EP_H,EP_R,CH.Nick);

		Add_Destination(Warehouse_Nodo_EP,EP_H,Seq_N);
		
		if Receive_Reject(EP_R) = True then
			--Protocolo de salida
			Confirm_Sent:= False;
			Msg_Logout(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick,Confirm_Sent);
			Debug.Put_Line("P_Logout Terminado",Pantalla.Magenta);
			Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
			delay CH.Max_Retransmisiones *Plazo_Retransmision;

			LLU.Finalize;
			Timed_Handlers.Finalize;
			Salir:=True;

		else
			Msg_Confirm(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick);
			Add_Destination(Warehouse_Nodo_EP,EP_H,Seq_N);

			Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line("Chat_Peer");
			Ada.Text_IO.Put_Line("=========");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line ("Logging into chat with nick:" & ASU.To_String(CH.Nick));
		end if;

	when 8 =>
		null;
	when 9 =>
		Maquina := ASU.To_Unbounded_String(ACL.Argument(6));
		Port:=Integer'Value(ACL.Argument(7));
		Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
		Neighbor_h_1 := LLU.Build(ASU.To_String(Dir_IP), Port);

		Add_Nodo(CH.Nick,Neighbor_h_1);

		Maquina := ASU.To_Unbounded_String(ACL.Argument(8));
		Port:=Integer'Value(ACL.Argument(9));
		Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
		Neighbor_h_2 := LLU.Build(ASU.To_String(Dir_IP), Port);

		Add_Nodo(CH.Nick,Neighbor_h_2);
		Get_Nodo(Warehouse_Nodo_EP);
		Msg_Init(Warehouse_Nodo_EP,EP_H,EP_H,EP_R,CH.Nick);

		Add_Destination(Warehouse_Nodo_EP,EP_H,Seq_N);

		if Receive_Reject(EP_R) = True then
			--Protocolo de salida
			Confirm_Sent:= False;
			Msg_Logout(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick,Confirm_Sent);
			Debug.Put_Line("P_Logout Terminado",Pantalla.Magenta);
			--Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
			delay CH.Max_Retransmisiones *Plazo_Retransmision;

			LLU.Finalize;
			Timed_Handlers.Finalize;
			Salir:=True;

		else
			Msg_Confirm(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick);
			Add_Destination(Warehouse_Nodo_EP,EP_H,Seq_N);
			Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line("Chat_Peer");
			Ada.Text_IO.Put_Line("=========");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line ("Logging into chat with nick:" & ASU.To_String(CH.Nick));
		end if;

	end case;

	while Salir = False loop

		CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);		
		CM.Message_Type'Output(CM.P_Buffer_Main,CM.Writer);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H);
      Ada.Text_IO.Put(">>");
      Message:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

      If ASU.To_String(Message) = ".quit" then
         
         Confirm_Sent:=True;
         Get_Nodo(Warehouse_Nodo_EP);
         Msg_Logout(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick,Confirm_Sent);
      	Add_Destination(Warehouse_Nodo_EP,EP_H,Seq_N);
		   Debug.Put_Line("P_Logout Terminado",Pantalla.Magenta);
         delay CH.Max_Retransmisiones *Plazo_Retransmision;

         Timed_Handlers.Finalize;
         LLU.Finalize;
         Salir:=True;
         exit;

      elsif ASU.To_String(Message) = ".debug" then
      	Status:=False;
      	Debug.Set_Status(Status);

      elsif ASU.To_String(Message) = ".whoami" then
      		Debug.Set_Status(Status);
      	If status = False then
      		Status:=True;
      		Debug.Set_Status(Status);
      		Debug.Put_Line("Nick: " & Asu.To_String(CH.nick) & " | " & "EP_H: " &
      				LI.Image_Value_T(EP_H) & " | " & "EP_R: " & LI.Image_Value_T(EP_R),Pantalla.Rojo);
      		Status:=False;
      		Debug.Set_Status(Status);
      	else
				Debug.Put_Line("Nick: " & Asu.To_String(CH.nick) & " | " & "EP_H: " &
      				LI.Image_Value_T(EP_H) & " | " & "EP_R: " & LI.Image_Value_T(EP_R),Pantalla.Rojo);
      	end If;
      --elsif ASU.To_String(Message) = ".nb" then

      		--Debug.Set_Status(Status);
      	--If status = False then
      		--Status:=True;
      		--Debug.Set_Status(Status);
      		--Debug.Put_Line(CH.Neighbors.Print_Map(CH.Map_Neighbors),Pantalla.Rojo);
      		--Status:=False;
      		--Debug.Set_Status(Status);
      	--else
      	--	null
      	--end If;
      else
      	Get_Nodo(Warehouse_Nodo_EP);
      	Msg_Writer(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick,Message);
			Add_Destination(Warehouse_Nodo_EP,EP_H,Seq_N);
     end if;
   end loop;
   	
		
exception
   when Ex:others =>
       Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;
      Timed_Handlers.Finalize;
end Chat_Peer_2;
