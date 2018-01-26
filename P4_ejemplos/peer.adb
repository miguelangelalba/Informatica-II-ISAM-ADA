with Handlers;
with Lower_Layer_UDP;

with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;

procedure Peer is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;

   Remote_Peer_Ep : LLU.End_Point_Type;
   Peer_EP        : LLU.End_Point_Type;

   Buffer        : aliased LLU.Buffer_Type(1024);
   Usage_Error   : exception;

   Text          : ASU.Unbounded_String;
begin
   if Ada.Command_Line.Argument_Count /= 3 then
      raise Usage_Error;
   end if;

   Peer_EP := LLU.Build(LLU.To_IP(LLU.Get_Host_Name),
                        Integer'Value (Ada.Command_Line.Argument(1)));
   LLU.Bind (Peer_EP, Handlers.Peer_Handler'Access);

   Remote_Peer_EP := LLU.Build(LLU.To_IP(Ada.Command_Line.Argument (2)),
                               Integer'Value (Ada.Command_Line.Argument(3)));

   loop
      Ada.Text_IO.Put("Escribe una cadena: ");
      Text := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

      -- Send message to remote peer
      LLU.Reset(Buffer);
      ASU.Unbounded_String'Output (Buffer'Access, Text);
      LLU.Send (Remote_Peer_EP, Buffer'Access);
   end loop;


exception
   when Usage_Error =>
      Ada.Text_IO.Put_Line ("Usage: ./peer peer_port remote_peer_hostname remote_peer_port");
      LLU.Finalize;
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;
end Peer;
