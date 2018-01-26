--Miguel Ángel Alba Blanco
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Maps_G;
with Debug;
with Ada.Calendar;
with Pantalla;
with List_Image;
with Timed_Handlers;
with Ada.Unchecked_Deallocation;


package body Chat_Handlers is

   --package ASU renames Ada.Strings.Unbounded;
   package CM renames Chat_Messages;
   package LI renames List_Image;
   Use type LLU.End_Point_Type;
   Use type Seq_N_T;
   use type Ada.Calendar.Time;


  	----------------------------------------------
	--Funciones necesarias para la instanciación--
	----------------------------------------------

	Function Mess_Equal(Mess_Id_1:Mess_Id_T;Mess_Id_2:Mess_Id_T) return Boolean is

		begin	

			If Mess_Id_1.Ep = Mess_Id_2.Ep and Mess_Id_1.Seq = Mess_Id_2.Seq then
				return True;
			else
				return False;
			end if;

	end Mess_Equal;

	Function Mess_Minor (Mess_Id_1:Mess_Id_T;Mess_Id_2:Mess_Id_T) return Boolean is

		begin

			-- Duda uno de los dos tiene que ser menor?
			--En este caso tengo que comparaándolos pasandolo a stringel <
			-- Si no,  me da problemas.
			If (LLU.Image(Mess_Id_1.Ep) < LLU.Image(Mess_Id_2.Ep) or Mess_Id_1.Ep = Mess_Id_2.Ep ) and
				(Mess_Id_1.Seq < Mess_Id_2.seq) then
				return True;
			else 
				return False;
			end if;


	end Mess_Minor;

	Function Mess_Image(Mess_Id_1:Mess_Id_T) return string is
		Image:String:="";

		begin

		return "Ep_H_Creat: " & LI.Image_Mess_Id_T(Mess_Id_1.Ep) & " Seq_N: " & Seq_N_T'Image(Mess_Id_1.Seq); 
		
	end Mess_Image;

	Function Destination_Image(Warehouse_Destination:Destinations_T) return String is

		begin

			return "Destinations: " & LI.Dest_Image(Warehouse_Destination);
	
	end Destination_Image;

	Function Value_T_Image(Value_T_1:Value_T) return string is

		begin	

		return "Ep_H_Creat: " & LI.Image_Value_T(Value_T_1.Ep_H_Creat) & " Seq_N: " & Seq_N_T'Image(Value_T_1.Seq_N);
	end 	Value_T_Image;

	------------------------------
-- Declaración de Funciones --
------------------------------

 function Es_Igual_Nick (Parametro1:ASU.Unbounded_String;
            Parametro2:ASU.Unbounded_String)return Boolean is
   begin
      if ASU.To_String(Parametro1) = ASU.To_String(Parametro2) then
         return True;
      Else 
         return False;
      end if;
   end Es_Igual_Nick;

	-----------------------------------
	-- Declaración de Procedimientos --
	-----------------------------------

	procedure Delete_Nodo (Neighbor_H: in LLU.End_Point_Type) is
   Success : Boolean;
	begin
	   Neighbors.Delete(Map_Neighbors,Neighbor_h,Success);
	   
	   If Success = True then
	      Debug.Put_Line(("Nodo Borrado"),Pantalla.Rojo);
	    end if; 
end Delete_Nodo;

procedure Delete_Latest_Msgs (EP_H_Creat: in LLU.End_Point_Type;
                              Success:out Boolean)is
   --Success : Boolean;
begin
   Latest_Msgs.Delete(Map_Latest_Msgs,EP_H_Creat,Success);
   
   If Success = True then
      Debug.Put_Line(("Latest_Msgs Borrado"),Pantalla.Rojo);
   else
      null;  
      --Debug.Put_Line(("No se ha Borrado el Latest_Msgs,'No se encuentra en la lista'"),
           --             Pantalla.Rojo);
   end if; 
end Delete_Latest_Msgs;


	procedure Add_Latest_Msgs (EP_H_Creat: in LLU.End_Point_Type;
                     Seq_N: in Seq_N_T;Resend: out Boolean) is
      Success_Get : Boolean;
      Success_Put : Boolean;
      Seq_N_Aux:Seq_N_T;
   begin
      Latest_Msgs.Get(Map_Latest_Msgs,EP_H_Creat,Seq_N_Aux,Success_Get);
		Debug.Put_Line(("Num:" & Seq_N_T'Image(Seq_N)),Pantalla.Magenta);
   		Debug.Put_Line(("Num_Aux:" & Seq_N_T'Image(Seq_N_Aux)),Pantalla.Magenta);

      If Success_Get = False then
      	--se añade ya que la lista está vacía
         Latest_Msgs.Put(Map_Latest_Msgs,EP_H_Creat,Seq_N,Success_Put);
         Resend:=True;
         If Success_Put = True then
            Debug.Put_Line(("Se añadió correctamente a Latest_Msgs"),Pantalla.Verde);
         else  
            Debug.Put_Line(("No se ha añadiado,'Máximos Latest_Msgs'"),
                              Pantalla.Rojo);
         end if;
      else

         If Seq_N = Seq_N_Aux +1 then
            --Delete_Latest_Msgs(EP_H_Creat);
            --En gestion de mensajes no controlo si el mensaje es uno mas
            --y lo controlo aquí
             Resend:=True;
            Latest_Msgs.Put(Map_Latest_Msgs,EP_H_Creat,Seq_N,Success_Put);
            If Success_Put = True then
               Debug.Put_Line(("Se añadió correctamente a Latest_Msgs en el paso 2"),Pantalla.Verde);
               --Resend:=True;
            else 
               Resend:=False;
               Debug.Put_Line(("No se ha añadiado,'Máximos Latest_Msgs'"),
                              Pantalla.Rojo);
            end if;
            --Latest_Msgs.Put(Map_Latest_Msgs,EP_H_Creat,Seq_N,Success_Put);
            Debug.Put_Line(("Se ha renovado el Latest_Msgs"),Pantalla.Amarillo);
         else
         	--aquí es donde falla
   	         --Latest_Msgs.Put(Map_Latest_Msgs,EP_H_Creat,Seq_N,Success_Put);
            Resend:=False;
            Debug.Put_Line(("No se ha añadido"),Pantalla.Amarillo);
         end if;

      end if;

   end Add_Latest_Msgs;

   procedure Add_Nodo(Nick_Aux: in ASU.Unbounded_String;
                     Neighbor_h: in LLU.End_Point_Type) is
	   Value: Ada.Calendar.Time := Ada.Calendar.Clock;
	   Success : Boolean;
	begin
		
	   Neighbors.Put(Map_Neighbors,Neighbor_h,Value,Success);
	   
	   If Success = True then
	      Debug.Put_Line(("Se añadió correctamente"),Pantalla.Verde);
	   else  
	      Debug.Put_Line(("No se ha añadiado,'Máximos de nodos"),
	                        Pantalla.Rojo);
	   end if; 
	end Add_Nodo;

	procedure Update_Destination_ACK (EP_H_Creat:in LLU.End_Point_Type;
									P_H_ACKer:in LLU.End_Point_Type;
									Seq_N: in Seq_N_T) is
		Identificador_Aux:Mess_Id_T;
		Success:Boolean:=False;
		Success_2:Boolean:= False;
		--Identificador_Dess:Mess_Id_T;
	   Valor_Dess:Destinations_T;
	   Nulos:Integer:=0;

	begin
		Identificador_Aux.Ep:=EP_H_Creat;
		Identificador_Aux.Seq:=Seq_N;

		Sender_Dests.Get(Map_Sender_Dests,Identificador_Aux,Valor_Dess,Success);
		If Success = True then
			for i in 1..10 loop
			
         Debug.Put_Line("-" & LLU.Image(Valor_Dess(i).EP),Pantalla.Rojo);
         	-- no es necesario ya lo hago en el timer
				if Valor_Dess(i).EP = P_H_ACKer then --or Valor_Dess(i).Retries > Max_Retransmisiones then
					Valor_Dess(i).EP := null;

				end if;
			end loop;
			Sender_Dests.Put(Map_Sender_Dests,Identificador_Aux,Valor_Dess);
			--Vuelvo a coger de la lista y si estan todos en null la borro
			--Esto ya no lohago aquí, lo hago en el temporizador
			Sender_Dests.Get(Map_Sender_Dests,Identificador_Aux,Valor_Dess,Success);
		else
			Debug.Put_Line(("Ha fallado el succes"),Pantalla.rojo);

		end if;

		
	end Update_Destination_ACK;

	procedure Add_Destination(Warehouse_Nodo_EP:Neighbors.Keys_Array_Type;
									EP_H_Creat:LLU.End_Point_Type;
									Seq_N:Seq_N_T)is
	
		Identificador:Mess_Id_T;
		Warehouse_Destination:Destinations_T;
		Time: Ada.Calendar.Time := Ada.Calendar.Clock;
		
	begin
		Identificador.Ep:=EP_H_Creat;
		Identificador.Seq:=Seq_N;

		for I in 1..10  loop

			Warehouse_Destination(I).Ep:=Warehouse_Nodo_EP(I);
			Warehouse_Destination(I).Retries:=0;
		end loop;
	-- esto creo que puede estar mal y se tendría que meter en el bucle
		Sender_Dests.Put(Map_Sender_Dests,Identificador,Warehouse_Destination);
		Debug.Put_Line(("Añadiendo a Destinations"),Pantalla.Verde);
	
	end Add_Destination;

	procedure Get_Nodo(Warehouse_Nodo_EP: out Neighbors.Keys_Array_Type) is

   begin
      Warehouse_Nodo_EP := Neighbors.Get_Keys(Map_Neighbors);
      
   end Get_Nodo;

  procedure Gestion_Mensajes(EP_H_Creat: in LLU.End_Point_Type;
                     Seq_N: in Seq_N_T;Send_Ack: out Boolean;
                     Resend:Out Boolean) is

  		Success_Get : Boolean;
      Seq_N_Aux:Seq_N_T;
  begin
  	   Latest_Msgs.Get(Map_Latest_Msgs,EP_H_Creat,Seq_N_Aux,Success_Get);
  	   	

		If Seq_N = Seq_N_Aux or Success_Get = False then
		   Resend:= True;
		   Send_Ack:=True;

		elsif Seq_N <= Seq_N_Aux then
			Send_Ack := True;
			Resend:=False;
		else
		--Si es del futuro no los asiento ni reenvio
			Send_Ack:=False;
			Resend:=False;
		end If;
	      
	  	
  end Gestion_Mensajes;

	-------------------------
	-- Reenvio de Mensajes --
	-------------------------
	
	procedure Resend_Msg_Timer(Time: in Ada.Calendar.Time) is
		
		procedure Free is new Ada.Unchecked_Deallocation (LLU.Buffer_Type,Buffer_A_T);
		
		--Identificador_Buff:Ada.Calendar.Time;
		Identificador_Dest:Mess_Id_T;
		Valor_Bufferring:Value_T;
		Valor_Dess:Destinations_T;
		Success:Boolean:=False;
		Success_1:Boolean:=False;
		Success_2:Boolean:=False;
		P_Buffer:access LLU.Buffer_Type;
		Time_Retransmision: Ada.Calendar.Time;
		Value:Value_T;
		Plazo_Retransmision: Duration;
		Borrar:Integer:=0;
		Found:Boolean:=False;

	begin

		Sender_Buffering.Get(Map_Sender_Buffering,Time,Valor_Bufferring,Success);
		
		--este if es ara comprobar el funcionamiento, no tiene otra utilidad
		If Success = False then 
			--debug.Put(("No se ha encontrado nada en Sender_Buffering"),Pantalla.Rojo);
			null;
		else
			--debug.Put((" se ha encontrado Sender_Buffering"),Pantalla.Amarillo);
			null;
		end if;

			Identificador_Dest.EP:=Valor_Bufferring.Ep_H_creat;
			Identificador_Dest.Seq:=Valor_Bufferring.Seq_N;

			Sender_Dests.Get(Map_Sender_Dests,Identificador_Dest,Valor_Dess,Success_1);
			if Success_1= True then
		
				P_Buffer:=Valor_Bufferring.P_Buffer;
				for I in 1..10  loop
						            
			      If Valor_Dess(I).EP /= Null and Valor_Dess(I).Retries < Max_Retransmisiones  then  
			   		
			   		debug.Put("Reenintentos " & Natural'Image(Valor_Dess(I).Retries),Pantalla.Amarillo);
			   		debug.Put("Reenintentos " & Integer'Image(Max_Retransmisiones),Pantalla.Amarillo);

			   		LLU.Send(Valor_Dess(I).EP,P_Buffer);
			   		debug.Put((" REenviando.. a" & Integer'Image(I) & " "),Pantalla.Amarillo);
			   		Debug.Put_Line( LLU.Image(Valor_Dess(I).EP),Pantalla.azul);

			   		Valor_Dess(I).Retries:= Valor_Dess(I).Retries +1;
						

				   	Value.EP_H_Creat:=Valor_Bufferring.Ep_H_creat;
						Value.Seq_N:=Valor_Bufferring.Seq_N;
						Value.P_Buffer:=Valor_Bufferring.P_Buffer;
						Plazo_Retransmision:= 2* Duration(Max_Delay)/1000;
						Time_Retransmision:=  Ada.Calendar.Clock + Plazo_Retransmision;
						Sender_Buffering.Put(Map_Sender_Buffering,Time_Retransmision,Value);
						Debug.Put_Line(("Añadiendo a Buffering"),Pantalla.Verde);
						Timed_Handlers.Set_Timed_Handler(Time_Retransmision, Resend_Msg_Timer'Access);
		   			Sender_Buffering.Delete(Map_Sender_Buffering,Time,Success_2);
			     		Found:=True;
			      end if;
			      
			   end loop;
		   
			   If Found = True then
				  	Sender_Dests.Put(Map_Sender_Dests,Identificador_Dest,Valor_Dess);
					--Debug.Put_Line(("Actualizando Destinatiosn"),Pantalla.verde);	
				Else
				  	Free (Valor_Bufferring.P_Buffer);
			   	Sender_Buffering.Delete(Map_Sender_Buffering,Time,Success_2);
					Sender_Dests.Delete(Map_Sender_Dests,Identificador_Dest,Success_2);
					--Debug.Put_Line(("Borrando Dests"),Pantalla.Rojo);
			   End if;
			else
				Sender_Buffering.Delete(Map_Sender_Buffering,Time,Success_2);
			end if;
	  
	end Resend_Msg_Timer;

	procedure Resend_Msg(Warehouse_Nodo_EP: in Neighbors.Keys_Array_Type;
                       		EP_Not_Resend: in LLU.End_Point_Type;
                       		P_Buffer: access LLU.Buffer_Type;
	                        P_Buffer_Main:in Buffer_A_T;
	                        EP_H_Creat:in LLU.End_Point_Type;
	                        Seq_N:in Seq_N_T) is 
	                          
	   Time_Retransmision: Ada.Calendar.Time;
		Valor_Bufferring:Value_T;
		Plazo_Retransmision: Duration;
		Seq_N_Aux:Seq_N_T;
		Success_Get:Boolean;
		Identificador_Dest:Mess_Id_T;
		Warehouse_Dess:Destinations_T;
		No_Add:Integer:=0;
		Found:Boolean:=False;
   begin
   		Latest_Msgs.Get(Map_Latest_Msgs,Ep_H_creat,Seq_N_Aux,Success_Get);

   		Identificador_Dest.Ep:=EP_H_Creat;
			Identificador_Dest.Seq:=Seq_N;
      for I in Warehouse_Nodo_EP'Range loop
      	

         --debug.Put(("Estoy en el blucle reenviar" & Integer'Image(I)),Pantalla.Rojo);
         If LLU.Image(Warehouse_Nodo_EP(I)) = LLU.Image(EP_Not_Resend)  then
            --debug.Put_Line(("aquí no se manda" & LLU.Image(EP_Not_Resend) ),Pantalla.Amarillo);
            --debug.Put(("El timer no se programa en este punto"),Pantalla.Rojo);
            null;

         ElsIf (LLU.Image(Warehouse_Nodo_EP(I)) /= LLU.Image(Null)) and (LLU.Image(Warehouse_Nodo_EP(I)) /= LLU.Image(EP_Not_Resend)) then  
            LLU.Send(Warehouse_Nodo_EP(I),P_Buffer);
            CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
            Warehouse_Dess(I).Ep:=Warehouse_Nodo_EP(I);
				Warehouse_Dess(I).Retries:=0;

				debug.Put_Line(("Reenviando.. mensaje a "),Pantalla.Amarillo);
            Debug.Put_Line( LLU.Image(Warehouse_Nodo_EP(I)),Pantalla.Amarillo);

            Valor_Bufferring.EP_H_Creat:=EP_H_Creat;
				Valor_Bufferring.Seq_N:=Seq_N;
				Valor_Bufferring.P_Buffer:=P_Buffer_Main;
				Plazo_Retransmision:= 2* Duration(Max_Delay)/1000;
				Time_Retransmision:=  Ada.Calendar.Clock + Plazo_Retransmision;
				Sender_Buffering.Put(Map_Sender_Buffering,Time_Retransmision,Valor_Bufferring);
				Debug.Put_Line(("Añadiendo a Buffering"),Pantalla.Verde);
				Timed_Handlers.Set_Timed_Handler(Time_Retransmision, Resend_Msg_Timer'Access);
		   	Found:=True;
		   end if;
         
      end loop;
      --Esto es para que no se añada
      	If Found =True then
      		Sender_Dests.Put(Map_Sender_Dests,Identificador_Dest,Warehouse_Dess);
				Debug.Put_Line(("Añadiendo a Destinations"),Pantalla.Azul);
			else
				Debug.Put_Line(("No se ha añadido el add"),Pantalla.Rojo);
				--Sender_Dests.Delete(Map_Sender_Dests,Identificador_Aux,Success_2);
			end if;
      
   end Resend_Msg;

	procedure Resend_Msg_Init(Warehouse_Nodo_EP:in Neighbors.Keys_Array_Type;
	                              EP_Not_Resend: in LLU.End_Point_Type;
	                              EP_H_Creat: in LLU.End_Point_Type;
	                              Seq_N: in out Seq_N_T;
	                              EP_H_Rsnd: in LLU.End_Point_Type;
	                              EP_R_Creat: in LLU.End_Point_Type;
	                              Nick_Aux:in ASU.Unbounded_String) is
	      --Buffer:aliased LLU.Buffer_Type(1024);
	      --P_Buffer: Access LLU.Buffer_Type;
	   begin
	      --debug.Put_Line(("Reenviando Init..."),Pantalla.Amarillo);
	      CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
	      CM.Message_Type'Output(CM.P_Buffer_Main,CM.Init);
	      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Creat);
	      Seq_N_T'Output(CM.P_Buffer_Main,Seq_N);
	      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Rsnd);
	      --debug.Put_Line((LLU.Image(EP_H_Rsnd)),Pantalla.azul);

	      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_R_Creat);
	      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Nick_Aux);
	     

	      Resend_Msg(Warehouse_Nodo_EP,EP_Not_Resend,CM.P_Buffer_Main,CM.P_Buffer_Main,EP_H_Creat,Seq_N);
	      
	   end Resend_Msg_Init;

	   procedure Resend_Msg_Confirm (Warehouse_Nodo_EP:in Neighbors.Keys_Array_Type;
                              EP_Not_Resend: in LLU.End_Point_Type;
                              EP_H_Creat: in LLU.End_Point_Type;
                              Seq_N: in out Seq_N_T;
                              EP_H_Rsnd: in LLU.End_Point_Type;
                              Nick_Aux:in ASU.Unbounded_String) is
      begin
      debug.Put_Line(("Reenviando Confirm..."),Pantalla.Amarillo);
      CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);

      CM.Message_Type'Output(CM.P_Buffer_Main,CM.Confirm);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Creat);
      Seq_N_T'Output(CM.P_Buffer_Main,Seq_N);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Rsnd);
      debug.Put_Line((LLU.Image(EP_H_Rsnd)),Pantalla.Amarillo);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Nick_Aux);
     
	    Resend_Msg(Warehouse_Nodo_EP,EP_Not_Resend,CM.P_Buffer_Main,CM.P_Buffer_Main,EP_H_Creat,Seq_N);
      

   end Resend_Msg_Confirm;

    procedure  Resend_Msg_Logout(Warehouse_Nodo_EP:in Neighbors.Keys_Array_Type;
                              EP_Not_Resend: in LLU.End_Point_Type;
                              EP_H_Creat: in LLU.End_Point_Type;
                              Seq_N: in out Seq_N_T;
                              EP_H_Rsnd: in LLU.End_Point_Type;
                              Nick_Aux:in ASU.Unbounded_String;
                              Confirm_Sent: in Boolean) is
    
   begin
      debug.Put_Line(("Reenviando Logout..."),Pantalla.Amarillo);
      CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);

      CM.Message_Type'Output(CM.P_Buffer_Main,CM.Logout);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Creat);
      Seq_N_T'Output(CM.P_Buffer_Main,Seq_N);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Rsnd);
      debug.Put_Line((LLU.Image(EP_H_Rsnd)),Pantalla.Amarillo);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Nick_Aux);
      Boolean'Output(CM.P_Buffer_Main,Confirm_Sent);
      
	   Resend_Msg(Warehouse_Nodo_EP,EP_Not_Resend,CM.P_Buffer_Main,CM.P_Buffer_Main,EP_H_Creat,Seq_N);
    
   end Resend_Msg_Logout;

   procedure Resend_Msg_Writer (Warehouse_Nodo_EP:in Neighbors.Keys_Array_Type;
                              EP_Not_Resend: in LLU.End_Point_Type;
                              EP_H_Creat: in LLU.End_Point_Type;
                              Seq_N: in out Seq_N_T;
                              EP_H_Rsnd: in LLU.End_Point_Type;
                              Nick_Aux:in ASU.Unbounded_String;
                              Message: in ASU.Unbounded_String) is
   begin

      debug.Put_Line(("Reenviando Mensaje..."),Pantalla.Amarillo);
      CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
      CM.Message_Type'Output(CM.P_Buffer_Main,CM.Writer);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Creat);
      Seq_N_T'Output(CM.P_Buffer_Main,Seq_N);
      LLU.End_Point_Type'Output(CM.P_Buffer_Main, EP_H_Rsnd);
      debug.Put_Line((LLU.Image(EP_H_Rsnd)),Pantalla.Azul);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Nick_Aux);
      ASU.Unbounded_String'Output(CM.P_Buffer_Main,Message);
      
	   Resend_Msg(Warehouse_Nodo_EP,EP_Not_Resend,CM.P_Buffer_Main,CM.P_Buffer_Main,EP_H_Creat,Seq_N);
     
   end Resend_Msg_Writer;
	

	-----------------------
	-- Envio de Mensajes --
	-----------------------

	procedure Send_Msg_ACK(EP_H_ACKer: in LLU.End_Point_Type;
									EP_H_Creat:in LLU.End_Point_Type;
									Seq_N: in Seq_N_T;
									EP_H_Rsnd: in LLU.End_Point_Type) is 
		Buffer:aliased LLU.Buffer_Type(1024);
      P_Buffer: Access LLU.Buffer_Type;
	begin
		
		LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.ACK);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_ACKer);
      LLU.End_Point_Type'Output(Buffer'Access,EP_H_Creat);
     	Seq_N_T'Output(Buffer'Access,Seq_N);
     	P_Buffer:=Buffer'Access;
     	LLU.Send(EP_H_Rsnd,P_Buffer);
     	LLU.Reset(Buffer);
      
	end Send_Msg_ACK;

	procedure Send_Msg_Reject (EP_R_Creat: in LLU.End_Point_Type;
                           P_Buffer: access LLU.Buffer_Type) is
   Buffer:aliased LLU.Buffer_Type(1024);
  begin
      --debug.Put_Line((LLU.Image(EP_R_Creat)),Pantalla.Rojo);
      LLU.Send(EP_R_Creat,P_Buffer);
      debug.Put_Line((" Enviando.. Reject"),Pantalla.Amarillo);
      LLU.Reset(Buffer);

   
  end Send_Msg_Reject;

 	------------------------
   -- Mensajes Recibidos --
   ------------------------

 procedure Received_Init (P_Buffer: access LLU.Buffer_Type;
                        EP_H_Creat: Out LLU.End_Point_Type;
                        Seq_N:Out Seq_N_T;
                        EP_H_Rsnd: Out LLU.End_Point_Type;
                        EP_R_Creat: Out LLU.End_Point_Type;
                        Nick_Aux:Out ASU.Unbounded_String) is
      Buffer:aliased LLU.Buffer_Type(1024);
   begin
      EP_H_Creat:= LLU.End_Point_Type'Input(P_Buffer);
      Seq_N:= Seq_N_T'Input(P_Buffer);
      EP_H_Rsnd:= LLU.End_Point_Type'Input(P_Buffer);
      EP_R_Creat:= LLU.End_Point_Type'Input(P_Buffer);
      Nick_Aux:= ASU.Unbounded_String'Input(P_Buffer);
      LLU.Reset(Buffer);
   end Received_Init;

	procedure Received_Logout(P_Buffer: access LLU.Buffer_Type;
	                        EP_H_Creat:Out LLU.End_Point_Type;
	                        Seq_N:Out Seq_N_T;
	                        EP_H_Rsnd: Out LLU.End_Point_Type;
	                        Nick_Aux:Out ASU.Unbounded_String;
	                        Confirm_Sent: Out Boolean) is
	   Buffer:aliased LLU.Buffer_Type(1024);
	begin
	   EP_H_Creat:= LLU.End_Point_Type'Input(P_Buffer);
	   Seq_N:= Seq_N_T'Input(P_Buffer);
	   EP_H_Rsnd:= LLU.End_Point_Type'Input(P_Buffer);
	   Nick_Aux:= ASU.Unbounded_String'Input(P_Buffer);
	   Confirm_Sent:= Boolean'Input(P_Buffer);
	   LLU.Reset(Buffer);
	   debug.Put_Line(("Logout Recibido"),Pantalla.Verde);

	end Received_Logout;

   procedure Received_Confirm (P_Buffer: access LLU.Buffer_Type;
                        EP_H_Creat:Out LLU.End_Point_Type;
                        Seq_N:Out Seq_N_T;
                        EP_H_Rsnd: Out LLU.End_Point_Type;
                        Nick_Aux:Out ASU.Unbounded_String) is
      --Buffer:aliased LLU.Buffer_Type(1024);
   begin
      EP_H_Creat:= LLU.End_Point_Type'Input(P_Buffer);
      Seq_N:= Seq_N_T'Input(P_Buffer);
      EP_H_Rsnd:= LLU.End_Point_Type'Input(P_Buffer);
      Nick_Aux:= ASU.Unbounded_String'Input(P_Buffer);
      debug.Put_Line(("Confimación Recivida"),Pantalla.Verde);
   end Received_Confirm;

   procedure Received_Writer(P_Buffer: access LLU.Buffer_Type;
                        EP_H_Creat:Out LLU.End_Point_Type;
                        Seq_N:Out Seq_N_T;
                        EP_H_Rsnd: Out LLU.End_Point_Type;
                        Nick_Aux:Out ASU.Unbounded_String;
                        Message: Out Asu.Unbounded_String) is 
   --Buffer:aliased LLU.Buffer_Type(1024);
begin
   EP_H_Creat:= LLU.End_Point_Type'Input(P_Buffer);
   Seq_N:= Seq_N_T'Input(P_Buffer);
   EP_H_Rsnd:= LLU.End_Point_Type'Input(P_Buffer);
   Nick_Aux:= ASU.Unbounded_String'Input(P_Buffer);
   Message:= ASU.Unbounded_String'Input(P_Buffer);

end Received_Writer;
  

    procedure Received_ACK (P_Buffer: access LLU.Buffer_Type;
                        EP_H_ACKer: out LLU.End_Point_Type;
                        EP_H_Creat:Out LLU.End_Point_Type;
                        Seq_N: Out Seq_N_T) is 
      Buffer:aliased LLU.Buffer_Type(1024);
     
   begin
      EP_H_ACKer:= LLU.End_Point_Type'Input(P_Buffer);
      EP_H_Creat:=LLU.End_Point_Type'Input(P_Buffer);
      Seq_N:= Seq_N_T'Input(P_Buffer);
      LLU.Reset(Buffer);
      
   end Received_ACK;

---------------------------
-- Comienzo del Handlers --
---------------------------

   procedure Client_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is
    	Reply: ASU.Unbounded_String;
	   Mess: CM.Message_Type;
	   EP_H_Creat: LLU.End_Point_Type;
	   EP_H_Rsnd: LLU.End_Point_Type;
	   EP_R_Creat: LLU.End_Point_Type;
	   Nick_Aux: ASU.Unbounded_String;
	   Seq_N:Seq_N_T;
	   Buffer:aliased LLU.Buffer_Type(1024);
	   P_Buffer_Aux: access LLU.Buffer_Type;
	   Confirm_Sent: Boolean;
	   Message:ASU.Unbounded_String;
	   Warehouse_Nodo_EP:Neighbors.Keys_Array_Type;
	   EP_Not_Resend: LLU.End_Point_Type;
	   Resend:Boolean;
	   P_H_ACKer:LLU.End_Point_Type;
	   Success_Get:Boolean;
	   Seq_N_Aux:Seq_N_T;
	   Send_Ack:Boolean;
	   	   
	begin

		Mess:= CM.Message_Type'Input (P_Buffer);

		case Mess is

			when CM.Init =>
				debug.Put_Line(("P_Admision"),Pantalla.Amarillo);
            debug.Put_Line(("Init Recibido"),Pantalla.Verde);
            Received_Init(P_Buffer,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick_Aux);
	         --debug.Put_Line(("Init Recibido de : (EP_H_Rsnd) " & LLU.Image(EP_H_Rsnd)),Pantalla.Verde);
            Gestion_Mensajes(EP_H_Creat,Seq_N,Send_Ack,Resend);
            Add_Latest_Msgs(EP_H_Creat,Seq_N,Resend);
            debug.Put_Line(("Enviando ACK"),Pantalla.Verde);
            --Aquí tambien se podría hacer lo del writer aunque en estos casos
            -- no afectaría ya que se mandan mensajes consecutivos
	
           	Send_Msg_ACK(To,EP_H_Creat,Seq_N,EP_H_Rsnd);

           
            If EP_H_Creat = EP_H_Rsnd then
	               Add_Nodo(Nick_Aux,EP_H_Rsnd);
	           end if;
            
				If Send_Ack /= False and Resend /= False then

	            If EP_H_Creat /= To then

	               debug.Put_Line((LLU.Image(EP_H_Creat) & LLU.Image(From)),Pantalla.Azul);

	               if Es_Igual_Nick(Nick,Nick_Aux) = True then
	                  debug.Put_Line((ASU.To_String(Nick) & "" & ASU.To_String(Nick_Aux)),Pantalla.Rojo);

	                  LLU.Reset(Buffer);
	                  CM.Message_Type'Output(Buffer'Access,CM.Reject);
	                  LLU.End_Point_Type'Output(Buffer'Access,To);
	                  ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
	                  P_Buffer_Aux:=Buffer'Access;
	                  Send_Msg_Reject(EP_R_Creat,P_Buffer_Aux);
	               else
	               	--Este if en realidad creo que sobra
	                  If Resend = True then
	                     --Add_Latest_Msgs(EP_H_Creat,Seq_N);
	                     Get_Nodo(Warehouse_Nodo_EP);
	                     Debug.Put_Line(LI.Image_EP(Warehouse_Nodo_EP),Pantalla.Verde);
	                     EP_Not_Resend:= EP_H_Rsnd;
	                     --Debug.Put_Line(LLU.Image(EP_Not_Resend),Pantalla.Rojo);
	                     --Debug.Put_Line("no reenviar a " & LLU.Image(EP_Not_Resend),Pantalla.Rojo);
	                     Resend_Msg_Init(Warehouse_Nodo_EP,EP_Not_Resend,EP_H_Creat,Seq_N,To,EP_R_Creat,Nick_Aux);
	                  	
	                  	--Add_Destination(Warehouse_Nodo_EP,EP_H_Creat,Seq_N);
	                  end if;
	               end If;
	            End if;
	        end if;

			when CM.Reject =>
				null;
			when CM.Confirm =>
			   Received_Confirm(P_Buffer,EP_H_Creat,Seq_N,EP_H_Rsnd,Nick_Aux);
			   
			   Gestion_Mensajes(EP_H_Creat,Seq_N,Send_Ack,Resend);
			   Add_Latest_Msgs(EP_H_Creat,Seq_N,Resend);
			   --Aquí tambien se podría hacer lo del writer
         	Send_Msg_ACK(To,EP_H_Creat,Seq_N,EP_H_Rsnd);
         	If Resend = true and EP_H_Creat /= to then
         		Ada.Text_IO.New_Line;
            	Ada.Text_IO.Put_Line(ASU.To_String(Nick_Aux) & " Joins the chat");
            	Ada.Text_IO.Put(">>");
            	Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
            end if;
         
            
				 If Resend /= False then
			   	Get_Nodo(Warehouse_Nodo_EP);
               EP_Not_Resend:= EP_H_Rsnd;
               Resend_Msg_Confirm(Warehouse_Nodo_EP,EP_Not_Resend,EP_H_Creat,Seq_N,To,Nick_Aux);
				else
					Debug.Put_Line("No reenvio",Pantalla.Rojo);

				end if;
			when CM.Writer =>
				Received_Writer(P_Buffer,EP_H_Creat,Seq_N,EP_H_Rsnd,Nick_Aux,Message);
				debug.Put_Line("Mensaje Writer Recibido",Pantalla.Verde);
				Gestion_Mensajes(EP_H_Creat,Seq_N,Send_Ack,Resend);
			   	Add_Latest_Msgs(EP_H_Creat,Seq_N,Resend);

			   If Send_Ack = True then
           		Send_Msg_ACK(To,EP_H_Creat,Seq_N,EP_H_Rsnd);
           	end if;
           
		      -- El to es por si le llega algun mensaje de si mismo que no lo imprima en pantalla
           	If Resend = true and EP_H_Creat /= to  then
           		Ada.Text_IO.New_Line;
               Ada.Text_IO.Put_Line(ASU.To_String(Nick_Aux) & ":" & ASU.To_String(Message));
               Ada.Text_IO.Put(">>");
            end if;
            If Resend /= False then
            	Get_Nodo(Warehouse_Nodo_EP);
               EP_Not_Resend:= EP_H_Rsnd;
               Resend_Msg_Writer(Warehouse_Nodo_EP,EP_Not_Resend,EP_H_Creat,Seq_N,To,Nick_Aux,Message);
				end if;
			when CM.Logout =>
			      Received_Logout(P_Buffer,EP_H_Creat,Seq_N,EP_H_Rsnd,Nick_Aux,Confirm_Sent);
				 --Cuando haga un logout tengo que borrar en latest_msg, tener en cuenta, si no no reenvía los mensajes
            --Se queda guardado un número de secuancia mayor en esa EP 
            --Tener cuidado, es muy importante
            Debug.Put_Line("Mensaje Logout Recibido",Pantalla.Verde);
            --Delete_Latest_Msgs(EP_H_Creat,Resend);
       
            Gestion_Mensajes(EP_H_Creat,Seq_N,Send_Ack,Resend);
            --Debug.Put_Line("GEstion Realizada",Pantalla.Verde);

            Add_Latest_Msgs(EP_H_Creat,Seq_N,Resend);
            Send_Msg_ACK(To,EP_H_Creat,Seq_N,EP_H_Rsnd);
            If Resend = true and EP_H_Creat /= to  then
           		Ada.Text_IO.Put_Line(ASU.To_String(Nick_Aux) & " leaves the chat");
           		Delete_Nodo(EP_H_Creat);
           		Ada.Text_IO.Put(">>");
           		Delete_Nodo(EP_H_Creat);
            end if;
            --ES lo mismo que arriba es una tontería sacarlo fuera
            --estuve provando distintas cosas y por eso el código se ha quedado así
            If Resend /= False then
            	Get_Nodo(Warehouse_Nodo_EP);
               EP_Not_Resend:= EP_H_Rsnd;
               Resend_Msg_Logout(Warehouse_Nodo_EP,EP_Not_Resend,EP_H_Creat,Seq_N,To,Nick_Aux,Confirm_Sent);
				end if;

			when CM.Ack =>

				debug.Put_Line(("ACK Recibido de.."),Pantalla.Amarillo);
				Received_ACK(P_Buffer,P_H_ACKer,EP_H_Creat,Seq_N);

				debug.Put_Line(("-" & LLU.Image(P_H_ACKer)),Pantalla.azul);
				Latest_Msgs.Get(Map_Latest_Msgs,EP_H_Creat,Seq_N_Aux,Success_Get);
				
				Update_Destination_ACK(EP_H_Creat,P_H_ACKer,Seq_N);
				
		end case;

   end Client_Handler;


end Chat_Handlers;