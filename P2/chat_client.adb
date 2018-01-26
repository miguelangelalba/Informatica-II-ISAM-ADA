--Miguel Ángel Alba Blanco
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Chat_Messages;
with Ada.Command_Line;

procedure Chat_Client is
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;

   Usage_Error: exception;

Procedure Send_Client_Info (Client_EP: in LLU.End_Point_Type;
      Nick: in ASU.Unbounded_String; 
      Server_EP: in LLU.End_Point_Type ) is

   Buffer:aliased LLU.Buffer_Type(1024);
begin

   LLU.Reset(Buffer);
   --Introduce el tipo de mensaje
   CM.Message_Type'Output(Buffer'Access,CM.Init);
   LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
   ASU.Unbounded_String'Output(Buffer'Access,Nick);
   LLU.Send(Server_EP, Buffer'Access);
   LLU.Reset(Buffer);

end Send_Client_Info;

procedure Receive_Server_Message(Client_EP:in LLU.End_Point_Type) is
   Mess:CM.Message_Type;
   Nick:ASU.Unbounded_String;
   Buffer:aliased LLU.Buffer_Type(1024);
   Expired:Boolean;
   Message:ASU.Unbounded_String;
begin 
   
   loop
      LLU.Reset(Buffer);    
      LLU.Receive(Client_EP, Buffer'Access, 1000.0, Expired);
      if Expired then
         Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
      else
         Mess:= CM.Message_Type'Input(Buffer'Access);
         Nick:= ASU.Unbounded_String'Input(Buffer'Access);
         Message:= ASU.Unbounded_String'Input(Buffer'Access);
         Ada.Text_IO.Put_Line(ASU.To_String(Nick) & ": " & 
               ASU.To_String(Message));
      end if;
   end loop;
      
end Receive_Server_Message;

procedure Send_Client_Message (Client_EP: in LLU.End_Point_Type;
      Server_EP: in LLU.End_Point_Type) is

   Buffer:aliased LLU.Buffer_Type(1024);
   Message:ASU.Unbounded_String;
begin
   loop
      LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.Writer);
      LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
      Ada.Text_IO.Put("Mensaje: ");
      Message:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
      
      If ASU.To_String(Message) = ".quit" then
         LLU.Reset(Buffer);
         LLU.Finalize;
         exit;
      end if;
      ASU.Unbounded_String'Output(Buffer'Access,Message);
      LLU.Send(Server_EP, Buffer'Access);
      LLU.Reset(Buffer);
   end loop;
  
end Send_Client_Message;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Nick:ASU.Unbounded_String;
   Reply:ASU.Unbounded_String;
   Maquina:ASU.Unbounded_String;
   Dir_IP:ASU.Unbounded_String;
   Port: Integer;

begin
   
   if ACL.Argument_Count > 3 or ACL.Argument_Count < 3 then
      raise Usage_Error;
   end if;

   Maquina := ASU.To_Unbounded_String(ACL.Argument(1));
   Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
   Port := Integer'Value(ACL.Argument(2));
   Nick := ASU.To_Unbounded_String(ACL.Argument(3));
   -- Construye el End_Point en el que está atado el servidor
   Server_EP := LLU.Build(ASU.To_String(Dir_IP), Port);
  -- Este está creado para hacer pruebas
   --Client_EP := LLU.Build(ASU.To_String(Dir_IP), 6124);
   -- Construye un End_Point libre cualquiera y se ata a él
   --LLU.Bind (Client_EP);
   LLU.Bind_Any(Client_EP);

   Send_Client_Info(Client_EP,Nick,Server_EP);

   If ASU.To_String(Nick) = "reader" then
       Receive_Server_Message(Client_EP);
   else  
      Send_Client_Message(Client_EP,Server_EP);
   end if;

exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Client;