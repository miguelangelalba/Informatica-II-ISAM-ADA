--Miguel Ángel Alba Blanco
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Chat_Messages;
with Client_Lists;
with Ada.Command_Line;

procedure Chat_Server is

	 package CM renames Chat_Messages;
   package LLU renames Lower_Layer_UDP;
   package ACL renames Ada.Command_Line;
   package ASU renames Ada.Strings.Unbounded;
   package CL renames Client_Lists;

  Usage_Error: exception;

  function Unir2_Cadenas (Cadena1:ASU.Unbounded_String;
      Cadena2:ASU.Unbounded_String) return String is
  begin
    return (ASU.To_String(Cadena1)& "" & ASU.To_String(Cadena2));
  End Unir2_Cadenas;


   Server_EP:LLU.End_Point_Type;
   Client_EP:LLU.End_Point_Type;
   Buffer:aliased LLU.Buffer_Type(1024);
   P_Buffer: Access LLU.Buffer_Type;
   Nick:ASU.Unbounded_String;
   Reply:ASU.Unbounded_String := ASU.To_Unbounded_String ("¡Bienvenido!");
   Expired:Boolean;
   Maquina:ASU.Unbounded_String;
   Dir_IP:ASU.Unbounded_String;
   Mess:CM.Message_Type;
   List:CL.Client_List_Type;
   Message:ASU.Unbounded_String;
   Port:Integer;
   Resultado:ASU.Unbounded_String;
   I:Integer;
   Message_Aux: ASU.Unbounded_String;
begin
  if ACL.Argument_Count > 1 or ACL.Argument_Count < 1 then
      raise Usage_Error;
   end if;
   Port := Integer'Value(ACL.Argument(1));
   -- construye un End_Point en una dirección y puerto concretos
   Maquina := ASU.To_Unbounded_String (LLU.Get_Host_Name);
   Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
   Server_EP := LLU.Build(ASU.To_String(Dir_IP),Port);
   -- se ata al End_Point para poder recibir en él
   LLU.Bind (Server_EP);

   I:=0;

   
   loop
   
      LLU.Reset(Buffer);
      LLU.Receive (Server_EP, Buffer'Access, 1000.0, Expired);

      if Expired then
         Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
      else
        Mess:= CM.Message_Type'Input (Buffer'Access);
         case Mess is 
	      	when CM.Init => 
	      	    Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
              Nick:= ASU.Unbounded_String'Input(Buffer'Access);
	      		begin
              
              CL.Add_Client(List,Client_EP,Nick);
                     
              If ASU.To_String (Nick) /= "reader" then
    	           begin
                    
                    Message_Aux:=ASU.To_Unbounded_String(" joins the chat");
                    Message:= ASU.To_Unbounded_String(Unir2_Cadenas(Nick,Message_Aux));
                    Nick:= ASU.To_Unbounded_String("server");
                    LLU.Reset(Buffer);
                    CM.Message_Type'Output(Buffer'Access,CM.Server);
                    ASU.Unbounded_String'Output(Buffer'Access,Nick);
                    ASU.Unbounded_String'Output(Buffer'Access,Message);
                    P_Buffer:=Buffer'Access;
                    CL.Send_To_Readers(List,P_Buffer);
                 Exception
                    when CL.Client_List_Error =>
                    Ada.Text_IO.Put_Line("WRITER received from unknown client. IGNORED");
                 end;
              end if;
            Exception
              when CL.Client_List_Error =>
                Ada.Text_IO.Put_Line ("INIT received from " &
                ASU.To_String(Nick) & " IGNORED, nick already used");
            end; 

         --if I = 0 or I >0 then
	      	--		Ada.Text_IO.Put("Introduce una cadena caracteres: ");
   				--	Nick:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
	      	 -- CL.Delete_Client(List,Nick);
	      	--End If;
	      		I:=I+1;
	      	when CM.Writer =>
	      	   Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
	      	   Message:= ASU.Unbounded_String'Input(Buffer'Access);
	      	   begin
                Nick:= CL.Search_Client(List,Client_EP);
                Ada.Text_IO.Put_Line("WRITER received from " &
                ASU.To_String(Nick) & ": " & 
                ASU.To_String(Message));
                LLU.Reset(Buffer);
                CM.Message_Type'Output(Buffer'Access,CM.Server);
                ASU.Unbounded_String'Output(Buffer'Access,Nick);
                ASU.Unbounded_String'Output(Buffer'Access,Message);
                P_Buffer:=Buffer'Access;
                CL.Send_To_Readers(List,P_Buffer);
             Exception
                when CL.Client_List_Error =>
                Ada.Text_IO.Put_Line("WRITER received from unknown client. IGNORED");
	      	   end;
            
	      	when CM.Server =>
					null;
			end case;      		
       	
      end if;
   end loop;
  exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Server;