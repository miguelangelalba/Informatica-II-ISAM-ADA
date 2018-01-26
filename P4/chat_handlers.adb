--Miguel Ángel Alba Blanco
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Maps_G;
with Debug;
with Ada.Calendar;
with Pantalla;
with List_Image;


package body Chat_Handlers is

   --package ASU renames Ada.Strings.Unbounded;
   package CM renames Chat_Messages;
   package LI renames List_Image;
   Use type LLU.End_Point_Type;


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
   --Por qué tengo que usar el Np ?? No tendría que usarlo..
   --NP_Neighbors.Delete(Map_Neighbors,Neighbor_H,Success);
   Neighbors.Delete(Map_Neighbors,Neighbor_h,Success);
   
   If Success = True then
      Debug.Put_Line(("Nodo Borrado"),Pantalla.Rojo);
   else  
      null;
      --Debug.Put_Line(("No se ha Borrado,'No se encuentra en la lista'"),
         --               Pantalla.Rojo);
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
      If Success_Get = False then
         Latest_Msgs.Put(Map_Latest_Msgs,EP_H_Creat,Seq_N,Success_Put);
         Resend:=True;
         If Success_Put = True then
            Debug.Put_Line(("Se añadió correctamente a Latest_Msgs"),Pantalla.Verde);
         else  
            Debug.Put_Line(("No se ha añadiado,'Máximos Latest_Msgs'"),
                              Pantalla.Rojo);
         end if;
      else
         If Seq_N > Seq_N_Aux then
            --Delete_Latest_Msgs(EP_H_Creat);
             Resend:=True;
            Latest_Msgs.Put(Map_Latest_Msgs,EP_H_Creat,Seq_N,Success_Put);
            If Success_Put = True then
               Debug.Put_Line(("Se añadió correctamente a Latest_Msgs"),Pantalla.Verde);
               --Resend:=True;
            else 
               --Resend:=False;
               Debug.Put_Line(("No se ha añadiado,'Máximos Latest_Msgs'"),
                              Pantalla.Rojo);
            end if;
               Latest_Msgs.Put(Map_Latest_Msgs,EP_H_Creat,Seq_N,Success_Put);
               Debug.Put_Line(("Se ha renovado el Latest_Msgs"),Pantalla.Amarillo);
         else
            Resend:=False;

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

procedure Get_Nodo(Warehouse_Nodo_EP: out Neighbors.Keys_Array_Type) is

   begin
      Warehouse_Nodo_EP := Neighbors.Get_Keys(Map_Neighbors);
      
   end Get_Nodo;

   -------------------------
   -- Reenvio de Mensajes --
   -------------------------
   procedure Resend_Msg(Warehouse_Nodo_EP: in Neighbors.Keys_Array_Type;
                        EP_Not_Resend: in LLU.End_Point_Type;
                        P_Buffer:Access LLU.Buffer_Type) is
   begin

      for I in Warehouse_Nodo_EP'Range loop
         
         --debug.Put(("Estoy en el blucle reenviar" & Integer'Image(I)),Pantalla.Rojo);
         If LLU.Image(Warehouse_Nodo_EP(I)) = LLU.Image(EP_Not_Resend) then
             null;
             --debug.Put(("no tiene que mandar nada a:" & LLU.Image(EP_Not_Resend)),Pantalla.Rojo);

         ElsIf LLU.Image(Warehouse_Nodo_EP(I)) /= LLU.Image(Null) then  
            LLU.Send(Warehouse_Nodo_EP(I),P_Buffer);
            debug.Put_Line(("Reenviando.. "),Pantalla.Amarillo);
            Debug.Put_Line( LI.Image_EP(Warehouse_Nodo_EP),Pantalla.Verde);

         end if;

          
      end loop;

   end Resend_Msg;

   procedure Resend_Msg_Writer (Warehouse_Nodo_EP:in Neighbors.Keys_Array_Type;
                              EP_Not_Resend: in LLU.End_Point_Type;
                              EP_H_Creat: in LLU.End_Point_Type;
                              Seq_N: in out Seq_N_T;
                              EP_H_Rsnd: in LLU.End_Point_Type;
                              Nick_Aux:in ASU.Unbounded_String;
                              Message: in ASU.Unbounded_String) is
      Buffer:aliased LLU.Buffer_Type(1024);
      P_Buffer: Access LLU.Buffer_Type;
   begin
      debug.Put_Line(("Reenviando Mensaje..."),Pantalla.Amarillo);
      LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.Writer);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      debug.Put_Line((LLU.Image(EP_H_Rsnd)),Pantalla.Azul);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      ASU.Unbounded_String'Output(Buffer'Access,Message);
      P_Buffer:=Buffer'Access;

      Resend_Msg(Warehouse_Nodo_EP,EP_Not_Resend,P_Buffer);
      LLU.Reset(Buffer);

   end Resend_Msg_Writer;

   procedure  Resend_Msg_Logout(Warehouse_Nodo_EP:in Neighbors.Keys_Array_Type;
                              EP_Not_Resend: in LLU.End_Point_Type;
                              EP_H_Creat: in LLU.End_Point_Type;
                              Seq_N: in out Seq_N_T;
                              EP_H_Rsnd: in LLU.End_Point_Type;
                              Nick_Aux:in ASU.Unbounded_String;
                              Confirm_Sent: in Boolean) is
      Buffer:aliased LLU.Buffer_Type(1024);
      P_Buffer: Access LLU.Buffer_Type;
   begin
      debug.Put_Line(("Reenviando Confirm..."),Pantalla.Amarillo);
      LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.Logout);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      debug.Put_Line((LLU.Image(EP_H_Rsnd)),Pantalla.Amarillo);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      Boolean'Output(Buffer'Access,Confirm_Sent);
      P_Buffer:=Buffer'Access;

      Resend_Msg(Warehouse_Nodo_EP,EP_Not_Resend,P_Buffer);
      LLU.Reset(Buffer);
   end Resend_Msg_Logout;

   procedure Resend_Msg_Confirm (Warehouse_Nodo_EP:in Neighbors.Keys_Array_Type;
                              EP_Not_Resend: in LLU.End_Point_Type;
                              EP_H_Creat: in LLU.End_Point_Type;
                              Seq_N: in out Seq_N_T;
                              EP_H_Rsnd: in LLU.End_Point_Type;
                              Nick_Aux:in ASU.Unbounded_String) is
      Buffer:aliased LLU.Buffer_Type(1024);
      P_Buffer: Access LLU.Buffer_Type;
   begin
      debug.Put_Line(("Reenviando Confirm..."),Pantalla.Amarillo);
      LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.Confirm);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      debug.Put_Line((LLU.Image(EP_H_Rsnd)),Pantalla.Amarillo);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      P_Buffer:=Buffer'Access;

      Resend_Msg(Warehouse_Nodo_EP,EP_Not_Resend,P_Buffer);
      LLU.Reset(Buffer);

   end Resend_Msg_Confirm;

   procedure Resend_Msg_Init(Warehouse_Nodo_EP:in Neighbors.Keys_Array_Type;
                              EP_Not_Resend: in LLU.End_Point_Type;
                              EP_H_Creat: in LLU.End_Point_Type;
                              Seq_N: in out Seq_N_T;
                              EP_H_Rsnd: in LLU.End_Point_Type;
                              EP_R_Creat: in LLU.End_Point_Type;
                              Nick_Aux:in ASU.Unbounded_String) is
      Buffer:aliased LLU.Buffer_Type(1024);
      P_Buffer: Access LLU.Buffer_Type;
   begin
      debug.Put_Line(("Reenviando Init..."),Pantalla.Amarillo);
      LLU.Reset(Buffer);
      CM.Message_Type'Output(Buffer'Access,CM.Init);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
      Seq_N_T'Output(Buffer'Access,Seq_N);
      LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
      debug.Put_Line((LLU.Image(EP_H_Rsnd)),Pantalla.azul);

      LLU.End_Point_Type'Output(Buffer'Access, EP_R_Creat);
      ASU.Unbounded_String'Output(Buffer'Access,Nick_Aux);
      P_Buffer:=Buffer'Access;

      Resend_Msg(Warehouse_Nodo_EP,EP_Not_Resend,P_Buffer);
      LLU.Reset(Buffer);
   end Resend_Msg_Init;




   ------------------------
   -- Mensajes Recividos --
   ------------------------


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
   debug.Put_Line(("Logout Recivido"),Pantalla.Verde);

end Received_Logout;

procedure Received_Writer(P_Buffer: access LLU.Buffer_Type;
                        EP_H_Creat:Out LLU.End_Point_Type;
                        Seq_N:Out Seq_N_T;
                        EP_H_Rsnd: Out LLU.End_Point_Type;
                        Nick_Aux:Out ASU.Unbounded_String;
                        Message: Out Asu.Unbounded_String) is 
   Buffer:aliased LLU.Buffer_Type(1024);
begin
   EP_H_Creat:= LLU.End_Point_Type'Input(P_Buffer);
   Seq_N:= Seq_N_T'Input(P_Buffer);
   EP_H_Rsnd:= LLU.End_Point_Type'Input(P_Buffer);
   Nick_Aux:= ASU.Unbounded_String'Input(P_Buffer);
   Message:= ASU.Unbounded_String'Input(P_Buffer);
   LLU.Reset(Buffer);

end Received_Writer;

procedure Received_Confirm (P_Buffer: access LLU.Buffer_Type;
                        EP_H_Creat:Out LLU.End_Point_Type;
                        Seq_N:Out Seq_N_T;
                        EP_H_Rsnd: Out LLU.End_Point_Type;
                        Nick_Aux:Out ASU.Unbounded_String) is
      Buffer:aliased LLU.Buffer_Type(1024);
   begin
      EP_H_Creat:= LLU.End_Point_Type'Input(P_Buffer);
      Seq_N:= Seq_N_T'Input(P_Buffer);
      EP_H_Rsnd:= LLU.End_Point_Type'Input(P_Buffer);
      Nick_Aux:= ASU.Unbounded_String'Input(P_Buffer);
      LLU.Reset(Buffer);
      debug.Put_Line(("Confimación Recivida"),Pantalla.Verde);
   end Received_Confirm;

  procedure Send_Msg_Reject (EP_R_Creat: in LLU.End_Point_Type;
                           P_Buffer: access LLU.Buffer_Type) is
   Buffer:aliased LLU.Buffer_Type(1024);
  begin
      --debug.Put_Line((LLU.Image(EP_R_Creat)),Pantalla.Rojo);
      LLU.Send(EP_R_Creat,P_Buffer);
      debug.Put_Line((" Enviando.. Reject"),Pantalla.Amarillo);
      LLU.Reset(Buffer);

   
  end Send_Msg_Reject;

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
   begin
      -- saca del Buffer P_Buffer.all un Unbounded_String
   
      Mess:= CM.Message_Type'Input (P_Buffer);
           case Mess is
         when CM.Init =>
            debug.Put_Line(("P_Admision"),Pantalla.Amarillo);
            debug.Put_Line(("Init Recivido"),Pantalla.Verde);
            Received_Init(P_Buffer,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick_Aux);
            debug.Put_Line(("Init Recivido de : (EP_H_Rsnd) " & LLU.Image(EP_H_Rsnd)),Pantalla.Verde);
            
            Add_Latest_Msgs(EP_H_Creat,Seq_N,Resend);
            If EP_H_Creat = EP_H_Rsnd then
               Add_Nodo(Nick_Aux,EP_H_Rsnd);
            end if;

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
                  If Resend = True then
                     --Add_Latest_Msgs(EP_H_Creat,Seq_N);
                     Get_Nodo(Warehouse_Nodo_EP);
                     Debug.Put_Line(LI.Image_EP(Warehouse_Nodo_EP),Pantalla.Verde);
                     EP_Not_Resend:= EP_H_Rsnd;
                     --Debug.Put_Line(LLU.Image(EP_Not_Resend),Pantalla.Rojo);
                     Debug.Put_Line("no reenviar a " & LLU.Image(EP_Not_Resend),Pantalla.Rojo);
                     Resend_Msg_Init(Warehouse_Nodo_EP,EP_Not_Resend,EP_H_Creat,Seq_N,To,EP_R_Creat,Nick_Aux);
                  end if;
               end If;
            End if;

         when CM.Reject =>
            null;
         when CM.Confirm =>
            
            Received_Confirm(P_Buffer,EP_H_Creat,Seq_N,EP_H_Rsnd,Nick_Aux);
            Add_Latest_Msgs(EP_H_Creat,Seq_N,Resend);

            If Resend = True then
               Ada.Text_IO.New_Line;
               Ada.Text_IO.Put_Line(ASU.To_String(Nick_Aux) & " Joins the chat");
               Ada.Text_IO.Put(">>");
               Debug.Put_Line("P_Admision Terminado",Pantalla.Magenta);
               Get_Nodo(Warehouse_Nodo_EP);
               EP_Not_Resend:= EP_H_Rsnd;
               Resend_Msg_Confirm(Warehouse_Nodo_EP,EP_Not_Resend,EP_H_Creat,Seq_N,To,Nick_Aux);
            end if;

         when CM.Writer =>

            debug.Put_Line("Mensaje Recivido",Pantalla.Verde);
            Received_Writer(P_Buffer,EP_H_Creat,Seq_N,EP_H_Rsnd,Nick_Aux,Message);
            
            If EP_H_Creat /= From then

               Add_Latest_Msgs(EP_H_Creat,Seq_N,Resend);

               If Resend = True then
                  Ada.Text_IO.New_Line;
                  Ada.Text_IO.Put_Line(ASU.To_String(Nick_Aux) & ":" & ASU.To_String(Message));
                  Ada.Text_IO.Put(">>");
                  Get_Nodo(Warehouse_Nodo_EP);
                  EP_Not_Resend:= EP_H_Rsnd;
                  Resend_Msg_Writer(Warehouse_Nodo_EP,EP_Not_Resend,EP_H_Creat,Seq_N,To,Nick_Aux,Message);
               --else
                  --Ada.Text_IO.Put_Line(ASU.To_String(Nick_Aux) & ":" & ASU.To_String(Message));
                  --Ada.Text_IO.Put(">>");
               end if;
            end if;

            

         when CM.Logout =>
            --Cuando haga un logout tengo que borrar en latest_msg, tener en cuenta, si no no reenvía los mensajes
            --Se queda guardado un número de secuancia mayor en esa EP 
            --Tener cuidado, es muy importante
            Debug.Put_Line("Mensaje Recivido",Pantalla.Verde);
            Received_Logout(P_Buffer,EP_H_Creat,Seq_N,EP_H_Rsnd,Nick_Aux,Confirm_Sent);
            --If LLU.Image(EP_H_Creat) = LLU.Image(EP_H_Rsnd) then
            

            Delete_Latest_Msgs(EP_H_Creat,Resend);

           If Resend = True then   
               Ada.Text_IO.New_Line;
               Debug.Put_Line("Borrando Delete MSg",Pantalla.Rojo);
               Ada.Text_IO.Put_Line(ASU.To_String(Nick_Aux) & " leaves the chat");
               Get_Nodo(Warehouse_Nodo_EP);
               Ada.Text_IO.Put(">>");
               EP_Not_Resend:= EP_H_Rsnd;
               Debug.Put_Line("ReEnviando logout",Pantalla.Amarillo);
               Resend_Msg_Logout(Warehouse_Nodo_EP,EP_Not_Resend,EP_H_Creat,Seq_N,To,Nick_Aux,Confirm_Sent);
               Delete_Nodo(EP_H_Creat);
               
            end if;

            If Confirm_Sent = False then
               
               Debug.Put_Line("P_Admision Terminado",Pantalla.Amarillo);
            End if;
      end case;
                     
         
   end Client_Handler;

end Chat_Handlers;

