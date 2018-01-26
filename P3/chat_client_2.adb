--Miguel Ángel Alba Blanco
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Chat_Messages;
with Ada.Command_Line;
with Handlers;


procedure Chat_Client_2 is
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;

   Usage_Error: exception;

Procedure Send_Client_Info (Server_EP: in LLU.End_Point_Type;
	Client_EP_Receive: in LLU.End_Point_Type;
	Client_EP_Handler: in LLU.End_Point_Type;
	Nick: in ASU.Unbounded_String) is

	
	Buffer:aliased LLU.Buffer_Type(1024);
begin

	 LLU.Reset(Buffer);
   CM.Message_Type'Output(Buffer'Access,CM.Init);
   LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive);
   LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
   ASU.Unbounded_String'Output(Buffer'Access,Nick);
   LLU.Send(Server_EP, Buffer'Access);
   LLU.Reset(Buffer);

end Send_Client_Info;

procedure Receive_Server_Message(Client_EP:in LLU.End_Point_Type;
			Nick: in ASU.Unbounded_String;
			Acogido: Out Boolean;
			Server_Not_found: Out Boolean) is

	Expired:Boolean;
	Mess:CM.Message_Type;
	Buffer:aliased LLU.Buffer_Type(1024);
   	  
begin 

   LLU.Reset(Buffer);    
   LLU.Receive(Client_EP, Buffer'Access, 10.0, Expired);
   if Expired then
      Ada.Text_IO.Put_Line ("Server unreachable");
      Server_Not_found:=True;
      
   else
		Mess:= CM.Message_Type'Input(Buffer'Access);
    	Acogido:= Boolean'Input(Buffer'Access);
   end if;
   
      
end Receive_Server_Message;

procedure Send_Client_Message (Client_EP_Handler: in LLU.End_Point_Type;
			Server_EP:in LLU.End_Point_Type ) is

   Buffer:aliased LLU.Buffer_Type(1024);
   Message:ASU.Unbounded_String;
begin
   loop
      LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.Writer);
      LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
      Ada.Text_IO.Put(">>");
      Message:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
      
      If ASU.To_String(Message) = ".quit" then
         LLU.Reset(Buffer);
         CM.Message_Type'Output(Buffer'Access,CM.Logout);
         LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
         LLU.Send(Server_EP, Buffer'Access);
         LLU.Reset(Buffer);
         LLU.Finalize;
         exit;

      else
      	ASU.Unbounded_String'Output(Buffer'Access,Message);
      	LLU.Send(Server_EP, Buffer'Access);
      	LLU.Reset(Buffer);
      end if;
     
   end loop;
  
end Send_Client_Message;

   Server_EP: LLU.End_Point_Type;
   Client_EP_Receive: LLU.End_Point_Type;
   Client_EP_Handler:LLU.End_Point_Type;
   Maquina:ASU.Unbounded_String;
   Dir_IP:ASU.Unbounded_String;
   Port: Integer;
   Acogido:Boolean;
   Nick:ASU.Unbounded_String;
   Server_Not_found:Boolean := False;

begin	

	if ACL.Argument_Count > 3 or ACL.Argument_Count < 3 then
   	raise Usage_Error;
	end if;

	Maquina := ASU.To_Unbounded_String(ACL.Argument(1));
 	Port := Integer'Value(ACL.Argument(2));
 	Nick := ASU.To_Unbounded_String(ACL.Argument(3));

 	If ASU.To_String(Nick) = "server" then

 		Ada.Text_IO.Put_Line("El Nick server es un Nick reservado por el sistema");
 		LLU.Finalize;
 	else	
	 	Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
	 	Server_EP := LLU.Build(ASU.To_String(Dir_IP), Port);
	 	LLU.Bind_Any(Client_EP_Receive);
	 	LLU.Bind_Any(Client_EP_Handler,Handlers.Client_Handler'Access);
	 
	 	Send_Client_Info(Server_EP,Client_EP_Receive,Client_EP_Handler,Nick);
	 	Receive_Server_Message(Client_EP_Receive,Nick,Acogido,Server_Not_found);
		
		If Acogido = True	then
	   	Ada.Text_IO.Put_Line("Mini-Chat v2.0: Welcome " & 
	     		ASU.To_String(Nick));
	   	 Send_Client_Message(Client_EP_Handler,Server_EP);
	   	 LLU.Finalize;
	   else
	   	If Server_Not_found = False then
	   		Ada.Text_IO.Put_Line("Mini-Chat v2.0: IGNORED new user" & 
	   		ASU.To_String(Nick) & " , nick already used");
	   		LLU.Finalize;
	   	else
	   		LLU.Finalize;
	   	end if;
	   end if;
	end if;

exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Client_2;