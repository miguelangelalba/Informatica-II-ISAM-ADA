--Miguel Ángel Alba Blanco
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Chat_Messages;
with Client_Lists;
with Ada.Command_Line;

procedure Chat_Server_2 is
	
	package CM renames Chat_Messages;
   package LLU renames Lower_Layer_UDP;
   package ACL renames Ada.Command_Line;
   package ASU renames Ada.Strings.Unbounded;
   package CL renames Client_Lists;

   Usage_Error: exception;

   function Unir2_Cadenas (Cadena1:ASU.Unbounded_String;
			Cadena2:ASU.Unbounded_String) return String is
	begin
		return (ASU.To_String(Cadena1)& ASU.To_String(Cadena2));
	End Unir2_Cadenas; 

   Server_EP:LLU.End_Point_Type;
   Port:Integer;
   Max_Client:Integer;
   Maquina:ASU.Unbounded_String;
   Dir_IP:ASU.Unbounded_String;
   Mess:CM.Message_Type;
   Client_EP_Receive:LLU.End_Point_Type;
	Client_EP_Handler:LLU.End_Point_Type;
	Nick:ASU.Unbounded_String;
	Buffer:aliased LLU.Buffer_Type(1024);
	Expired:Boolean;
	List:CL.Client_List_Type;
	Acogido:Boolean;
	Message:ASU.Unbounded_String;
	Message_Aux: ASU.Unbounded_String;
	P_Buffer: Access LLU.Buffer_Type;
	Count:Natural;
	Nick_Serv:ASU.Unbounded_String;
	Ep_Oldest: LLU.End_Point_Type;
		
begin
   
   if ACL.Argument_Count > 2 or ACL.Argument_Count < 2 then
   	raise Usage_Error;
	end if;
	
	--Construcción del End_Point_server (Exceptuando el Max_Client)
	Port := Integer'Value(ACL.Argument(1));
	Max_Client := Integer'Value(ACL.Argument(2));

	If Max_Client < 2 or Max_Client > 50 then
		Ada.Text_IO.Put_Line ("Numero de clientes no valido");
		raise Usage_Error;
	end if;
	
	Maquina := ASU.To_Unbounded_String (LLU.Get_Host_Name);
	Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
	Server_EP := LLU.Build(ASU.To_String(Dir_IP),Port);
		
	LLU.Bind (Server_EP);

	loop
		
		LLU.Reset(Buffer);
		LLU.Receive(Server_EP, Buffer'Access, 1000.0, Expired);

		if Expired then
			Ada.Text_IO.Put_Line ("Plazo expirado, vuelva a intentarlo");
		else
			Mess:= CM.Message_Type'Input (Buffer'Access);
			case Mess is 
				when CM.Init =>
					Client_EP_Receive := LLU.End_Point_Type'Input (Buffer'Access);
					Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
					Nick:= ASU.Unbounded_String'Input(Buffer'Access);
					
					begin
						--El mas 1 se hace ya que cuanta antes de 
						--meter en la lista y mostraría uno menos
						If (CL.Count(List)+1) <=Max_Client then
							
							CL.Add_Client(List,Client_EP_Handler,Nick);
							Count:= (CL.Count(List)+1);
							LLU.Reset(Buffer);
							CM.Message_Type'Output(Buffer'Access,CM.Welcome);
							Acogido:= True;
							Boolean'Output(Buffer'Access,Acogido);
							LLU.Send(Client_EP_Receive,Buffer'Access);
							LLU.Reset(Buffer);

							Message_Aux:=ASU.To_Unbounded_String(" Joins the chat");
							Message:= ASU.To_Unbounded_String(Unir2_Cadenas(Nick,Message_Aux));
							Nick:= ASU.To_Unbounded_String("Server");
							P_Buffer:=Buffer'Access;

							CM.Message_Type'Output(Buffer'Access,CM.Server);
							ASU.Unbounded_String'Output(Buffer'Access,Nick);
	               	ASU.Unbounded_String'Output(Buffer'Access,Message);
	               	CL.Send_To_All(List,P_Buffer,Client_EP_Handler);
	               	
							--Para ver si funciona el list image
							--Ada.Text_IO.Put_Line(CL.List_Image(List));

						else
						--Primero añado y después borro, ya que si existe el nick
						--salta el error antes de meterlo, por lo tanto no añadiría
						-- y no lo expulsaría
						--En caso de qu se  fuese a borrar el nick repetido tambíen
						--Pero claro... en caso del tipo array si es de 50, no podría añadirlo
						--Podría crear un array de 51 para resolver este problema... preguntar..
							CL.Add_Client(List,Client_EP_Handler,Nick);
							CL.Remove_Oldest(List,Ep_Oldest,Nick);

							Message:= ASU.To_Unbounded_String("you are been banned for being idle too long");
							Nick_Serv:=ASU.To_Unbounded_String("Server");
							LLU.Reset(Buffer);
							CM.Message_Type'Output(Buffer'Access,CM.Server);
      					ASU.Unbounded_String'Output(Buffer'Access,Nick_Serv);
      					ASU.Unbounded_String'Output(Buffer'Access,Message);
      					P_Buffer:=Buffer'Access;
							LLU.Send(Ep_Oldest,P_Buffer);
							--CL.Search_Client(List,client);

							Message_Aux:=ASU.To_Unbounded_String(" banned for being idle too long");
							Message:= ASU.To_Unbounded_String(Unir2_Cadenas(Nick,Message_Aux));
   						Nick_Serv:=ASU.To_Unbounded_String("Server");
							
							LLU.Reset(Buffer);
							CM.Message_Type'Output(Buffer'Access,CM.Server);
      					ASU.Unbounded_String'Output(Buffer'Access,Nick_Serv);
      					ASU.Unbounded_String'Output(Buffer'Access,Message);
      					P_Buffer:=Buffer'Access;
      					CL.Send_To_All(List,P_Buffer,null);

							LLU.Reset(Buffer);
							CM.Message_Type'Output(Buffer'Access,CM.Welcome);
							Acogido:= True;
							Boolean'Output(Buffer'Access,Acogido);
							LLU.Send(Client_EP_Receive,Buffer'Access);

						end if;
					exception
						when CL.Client_List_Error =>
							Ada.Text_IO.Put_Line ("INIT received from " &
               		 ASU.To_String(Nick) & ": IGNORED, nick already used");
							LLU.Reset(Buffer);
							CM.Message_Type'Output(Buffer'Access,CM.Welcome);
							Count:= Count-1;
							Acogido:= False;
							Boolean'Output(Buffer'Access,Acogido);
							LLU.Send(Client_EP_Receive,Buffer'Access);
					end;

				when CM.Welcome =>
					null;
				when CM.Writer =>
					begin
						
						Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
		      	   Message:= ASU.Unbounded_String'Input(Buffer'Access);
						Nick:= CL.Search_Client(List,Client_EP_Handler);
	               Ada.Text_IO.Put_Line("WRITER received from " &
	               ASU.To_String(Nick) & ": " & ASU.To_String(Message));
						CL.Update_Client(List,Client_EP_Handler);

						LLU.Reset(Buffer);
						CM.Message_Type'Output(Buffer'Access,CM.Server);
	               ASU.Unbounded_String'Output(Buffer'Access,Nick);
	               ASU.Unbounded_String'Output(Buffer'Access,Message);
	               P_Buffer:=Buffer'Access;
	               CL.Send_To_All(List,P_Buffer,Client_EP_Handler);

	             exception 
	               when CL.Client_List_Error =>
	              	--Salto en caso de que lleguen mensajes de desconocidos
                    Ada.Text_IO.Put_Line("WRITER received from unknown client. IGNORED");
	            end;
				when CM.Server =>
					null;
				when CM.Logout =>
					Client_EP_Handler:=LLU.End_Point_Type'Input (Buffer'Access);
					begin
						Nick:=CL.Search_Client(List,Client_EP_Handler);
						Ada.Text_IO.Put_Line("LOGOUT received from " &
						ASU.To_String(Nick));
						CL.Delete_Client(List,Nick);
																
						Message_Aux:=ASU.To_Unbounded_String(" leaves the chat");
						Message:= ASU.To_Unbounded_String(Unir2_Cadenas(Nick,Message_Aux));
						Nick :=ASU.To_Unbounded_String("Server");

						LLU.Reset(Buffer);
						CM.Message_Type'Output(Buffer'Access,CM.Server);
	               ASU.Unbounded_String'Output(Buffer'Access,Nick);
	               ASU.Unbounded_String'Output(Buffer'Access,Message);
	               P_Buffer:=Buffer'Access;
						CL.Send_To_All(List,P_Buffer,Client_EP_Handler);
					exception
						when CL.Client_List_Error =>
							null;
					end;

			end case;
		
		end if;

	end loop;

exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Server_2;