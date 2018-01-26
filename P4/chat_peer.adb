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


procedure Chat_Peer is
	
	package CM renames Chat_Messages;
   package LLU renames Lower_Layer_UDP;
   package ACL renames Ada.Command_Line;
   package ASU renames Ada.Strings.Unbounded;
   package CH renames Chat_Handlers;
   package LI renames List_Image;

   use type CH.Seq_N_T;



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
	begin
		
		LLU.Receive(EP_R, Buffer'Access, 2.0, Expired);
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


	end;

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
	                          P_Buffer: access LLU.Buffer_Type) is
	   
	begin 
	  
	   for I in 1..10  loop
	            
	      If LLU.Image(Warehouse_Nodo_EP(I)) /= LLU.Image(Null) then  
	   		LLU.Send(Warehouse_Nodo_EP(I),P_Buffer);
	   		debug.Put((" Enviando.." & Integer'Image(I) & " "),Pantalla.Amarillo);
	   	end if;
	       
	   end loop;
	  Debug.Put_Line(LI.Image_EP(Warehouse_Nodo_EP),Pantalla.Verde);

	--Exception
	  -- when  Client_List_Error =>
	     -- null;

	end Send_msg;

	procedure Msg_Writer(Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
								EP_H_Creat: In LLU.End_Point_Type;
								EP_H_Rsnd: in LLU.End_Point_Type;
								Nick_Aux: in ASU.Unbounded_String;
								Message: in Asu.Unbounded_String) is
		--Seq_N:CH.Seq_N_T:=1;
		Buffer:aliased LLU.Buffer_Type(1024);
		P_Buffer: Access LLU.Buffer_Type;
	begin
		Seq_N:=Seq_N+1;
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access,CM.Writer);
		LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      CH.Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      ASU.Unbounded_String'Output(Buffer'Access,Message);
      P_Buffer:=Buffer'Access;
      Send_msg(Warehouse_Nodo_EP,P_Buffer);
      LLU.Reset(Buffer);
	end Msg_Writer;
	procedure Msg_Logout (Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
								EP_H_Creat: In LLU.End_Point_Type;
								EP_H_Rsnd: in LLU.End_Point_Type;
								Nick_Aux: in ASU.Unbounded_String;
								Confirm_Sent: in Boolean) is
		Buffer:aliased LLU.Buffer_Type(1024);
		P_Buffer: Access LLU.Buffer_Type;
	begin
		Seq_N:= Seq_N+1;
		debug.Put_Line(("Iniciando P_Logout..."),Pantalla.Magenta);
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access,CM.Logout);
		LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      CH.Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      Boolean'Output(Buffer'Access,Confirm_Sent);
      P_Buffer:=Buffer'Access;
      Send_msg(Warehouse_Nodo_EP,P_Buffer);
      LLU.Reset(Buffer);
	end Msg_Logout;

   procedure Msg_Confirm(Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
   							EP_H_Creat:in LLU.End_Point_Type;
   							EP_H_Rsnd: in LLU.End_Point_Type;
   							Nick_Aux:in ASU.Unbounded_String) is
		Buffer:aliased LLU.Buffer_Type(1024);
		P_Buffer: Access LLU.Buffer_Type;
	begin
		Seq_N:=Seq_N+1;
		debug.Put_Line(("Enviando Confimación..."),Pantalla.Amarillo);
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access,CM.Confirm);
		LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      CH.Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      P_Buffer:=Buffer'Access;

      Send_msg(Warehouse_Nodo_EP,P_Buffer);
      LLU.Reset(Buffer);


	end Msg_Confirm;

	procedure Msg_Init(Warehouse_Nodo_EP:in CH.Neighbors.Keys_Array_Type;
										EP_H_Creat: in LLU.End_Point_Type;
										EP_H_Rsnd: in LLU.End_Point_Type;
										EP_R_Creat: in LLU.End_Point_Type;
										Nick_Aux:in ASU.Unbounded_String) is
		Buffer:aliased LLU.Buffer_Type(1024);
		P_Buffer: Access LLU.Buffer_Type;
	begin

		Add_Latest_Msgs(EP_H_Creat,Seq_N);
		debug.Put_Line(("Iniciando P_Admision..."),Pantalla.Magenta);
		debug.Put_Line(("Enviando Init"),Pantalla.Amarillo);
		LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.Init);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      CH.Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      LLU.End_Point_Type'Output(Buffer'Access, EP_R_Creat);
      debug.Put(("EP_R_Creat:" & LLU.Image(EP_R_Creat)),Pantalla.Verde);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      P_Buffer:=Buffer'Access;

      Send_msg(Warehouse_Nodo_EP,P_Buffer);
      LLU.Reset(Buffer);
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

------------------------------
-- Declaración de Variables --
------------------------------
	
	Num_Arg: Integer range 2..6;
	Buffer:aliased LLU.Buffer_Type(1024);
	Port: Integer;
	Dir_IP:ASU.Unbounded_String;
	Maquina:ASU.Unbounded_String;
	EP_R :LLU.End_Point_Type;
	EP_H:LLU.End_Point_Type;
	Neighbor_h_1: LLU.End_Point_Type;
	Neighbor_h_2: LLU.End_Point_Type;
	Warehouse_Nodo_EP: CH.Neighbors.Keys_Array_Type;
	Confirm_Sent:Boolean;
	Message:ASU.Unbounded_String;
	Salir:Boolean:=False;
	Status:Boolean;

------------------------
-- Programa Principal --
------------------------

begin

	Num_Arg:=ACL.Argument_Count;

	if ACL.Argument_Count > 6 or ACL.Argument_Count < 2 or 
		ACL.Argument_Count = 3 or ACL.Argument_Count = 5 then
	  	Num_Arg:=ACL.Argument_Count;
	  	raise Usage_Error;
	end if;


	Maquina := ASU.To_Unbounded_String (LLU.Get_Host_Name);
	Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
	Port := Integer'Value(ACL.Argument(1));
	LLU.Bind_Any(EP_R);
	
	EP_H:= LLU.Build(ASU.To_String(Dir_IP),Port);
	LLU.Bind (EP_H,CH.Client_Handler'Access);
		
	CH.Nick:= ASU.To_Unbounded_String(ACL.Argument(2));

	Num_Arg:=ACL.Argument_Count;

	Case	Num_Arg is

	when 2 =>
		Debug.Put_Line(("NOT following admission protocol because we have no initial contacts ..."),Pantalla.Verde);
		Ada.Text_IO.Put_Line("Chat_Peer");
		Ada.Text_IO.Put_Line("=========");
		Ada.Text_IO.New_Line;
		Ada.Text_IO.Put_Line ("Logging into chat with nick:" & ASU.To_String(CH.Nick));
	when 3 =>
		null;
	when 4 =>
		Maquina := ASU.To_Unbounded_String(ACL.Argument(3));
		Port:=Integer'Value(ACL.Argument(4));
		Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
		Neighbor_h_1 := LLU.Build(ASU.To_String(Dir_IP), Port); 

		Add_Nodo(CH.Nick,Neighbor_h_1);

		Get_Nodo(Warehouse_Nodo_EP);

		Msg_Init(Warehouse_Nodo_EP,EP_H,EP_H,EP_R,CH.Nick);

		if Receive_Reject(EP_R) = True then
			--Protocolo de salida
			Confirm_Sent:= False;

			Msg_Logout(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick,Confirm_Sent);
			Debug.Put_Line("P_Logout Terminado",Pantalla.Magenta);
			Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
			LLU.Finalize;
			Salir:= True;
			
		else
			Msg_Confirm(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick);
			Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
			
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line("Chat_Peer");
			Ada.Text_IO.Put_Line("=========");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line ("Logging into chat with nick:" & ASU.To_String(CH.Nick));
		end if;

	when 5 =>
		null;		
	when 6 =>
		Maquina := ASU.To_Unbounded_String(ACL.Argument(3));
		Port:=Integer'Value(ACL.Argument(4));
		Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
		Neighbor_h_1 := LLU.Build(ASU.To_String(Dir_IP), Port);

		Add_Nodo(CH.Nick,Neighbor_h_1);

		Maquina := ASU.To_Unbounded_String(ACL.Argument(5));
		Port:=Integer'Value(ACL.Argument(6));
		Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
		Neighbor_h_2 := LLU.Build(ASU.To_String(Dir_IP), Port); 
	
		Add_Nodo(CH.Nick,Neighbor_h_2);

		Get_Nodo(Warehouse_Nodo_EP);

		Msg_Init(Warehouse_Nodo_EP,EP_H,EP_H,EP_R,CH.Nick);

		if Receive_Reject(EP_R) = True then
			--Protocolo de salida
			Confirm_Sent:= False;
			Msg_Logout(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick,Confirm_Sent);
			Debug.Put_Line("P_Logout Terminado",Pantalla.Magenta);
			Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
			LLU.Finalize;
			Salir:=True;



		else
			Msg_Confirm(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick);
			Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line("Chat_Peer");
			Ada.Text_IO.Put_Line("=========");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line ("Logging into chat with nick:" & ASU.To_String(CH.Nick));
		end if;
		
	end case;

	 --Ada.Text_IO.Put_Line("Chat_Peer");
	 ---Ada.Text_IO.Put_Line("=========");
	 --Ada.Text_IO.New_Line;
	 ---Ada.Text_IO.Put_Line ("Logging into chat with nick:" & ASU.To_String(CH.Nick));


	--Debug.Put_Line(LI.Image_EP(Warehouse_Nodo_EP),Pantalla.Verde);
	
	while Salir = False loop

		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access,CM.Writer);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H);
      Ada.Text_IO.Put(">>");
      Message:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

      If ASU.To_String(Message) = ".quit" then
         LLU.Reset(Buffer);
         Confirm_Sent:=True;
         Get_Nodo(Warehouse_Nodo_EP);
         Msg_Logout(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick,Confirm_Sent);
         Debug.Put_Line("P_Logout Terminado",Pantalla.Magenta);
         LLU.Reset(Buffer);
         LLU.Finalize;
         exit;

      elsif ASU.To_String(Message) = ".debug" then
      	Status:=False;
      	Debug.Set_Status(Status);

      else
      	Get_Nodo(Warehouse_Nodo_EP);
      	Msg_Writer(Warehouse_Nodo_EP,EP_H,EP_H,CH.Nick,Message);
      end if;
			
	end loop;				

	

exception
   when Ex:others =>
       Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

      --Ada.Text_IO.Put_Line ("Solo se pueden introducir 2,4 o 6 parametros");
   	LLU.Finalize;
end Chat_Peer;