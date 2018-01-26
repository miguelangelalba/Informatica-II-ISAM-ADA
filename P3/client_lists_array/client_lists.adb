--Miguel Ángel Alba Blanco
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Text_IO;
with Chat_Messages;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Unchecked_Deallocation;
with Ada.Calendar;

package body Client_Lists is

   package CM renames Chat_Messages;
   package ACL renames Ada.Command_Line;
   package CL renames Client_Lists;

   function Es_Igual_Nick (Parametro1:ASU.Unbounded_String;
            Parametro2:ASU.Unbounded_String)return Boolean is
   begin
      if ASU.To_String(Parametro1) = ASU.To_String(Parametro2) then
         return True;
      Else 
         return False;
      end if;
   end Es_Igual_Nick;

   function Es_Igual_EP (Parametro1: LLU.End_Point_Type;
            Parametro2: LLU.End_Point_Type)return Boolean is
   begin
      if LLU.Image(Parametro1) = LLU.Image(Parametro2) then
         return True;
      Else 
         return False;
      end if;
   end Es_Igual_EP;

   function Unir2_Cadenas (Cadena1:ASU.Unbounded_String;
         Cadena2:ASU.Unbounded_String) return String is
   begin
      return (ASU.To_String(Cadena1) & ASU.To_String(Cadena2));
   End Unir2_Cadenas;

   function Unir3_Cadenas(Cadena1:ASU.Unbounded_String;
         Cadena2:ASU.Unbounded_String;
         Cadena3:ASU.Unbounded_String) return String is
   begin
      return (ASU.To_String (Cadena1) & ":" & ASU.To_String(Cadena2)
       & " " & ASU.To_String(Cadena3) & ASCII.LF);
   end Unir3_Cadenas;

   procedure Quitar_Espacios (Word_Aux: in ASU.Unbounded_String;
            Word: out ASU.Unbounded_String) is
   begin
      If ASU.To_String(Word_Aux) /= "" then
         Word:= Word_Aux;
      End if;

   end Quitar_Espacios;

   procedure Trocear_Ep(Line: in out ASU.Unbounded_String;
               Dir_Ip: out ASU.Unbounded_String;
               Puerto: out ASU.Unbounded_String) is

      Position: Integer;
      Word:ASU.Unbounded_String;
      Word_Aux:ASU.Unbounded_String;
      Contador:Integer;
   begin 
      Contador:=0;
      loop
         Position:=ASU.Index(Line," ");

         exit when Position= 0;
         Word_Aux:= ASU.Head(Line,Position-1);
         Quitar_Espacios(Word_Aux,Word);
         Word:=Word;
         If Contador = 2 then
            Dir_Ip:=ASU.Head(Word,Position-2);
         end if;
         If Contador = 3 then 
            Puerto:=ASU.Tail(Line,ASU.Length(Line)-Position-1);
         end if;
         Contador:= Contador+1;
         --Esto es para ir acortando la línea y que 
         -- no entre en bucle
         Line:=ASU.Tail(Line,ASU.Length(Line)-Position);
      end loop;

   end Trocear_Ep;

   procedure Search_Oldest (List: in Client_List_Type;
            Nick_Oldest:out ASU.Unbounded_String;
            Ep_Oldest: out LLU.End_Point_Type) is

      Use Type Ada.Calendar.Time;
      I:Integer;
      List_Aux: cell;
      Count:Integer:=0;
   begin
      I := 1;
      
      while I <= Max_Client loop

         If List.Almacen(I).Full = True then

            Count:= Count+1;
               --Esto es para asegurarme que cojo como modelo
               --un time con full = a True;
            If Count < 2 then
               List_Aux:=List.Almacen(I);
               I:=I+1;
            end if;
           
            If (List_Aux.Time) >= (List.Almacen(I).Time) then
               
               List_Aux:=List.Almacen(I);
               
            end If;
         else 
            null;
         end if;
        I:=I+1;
      end loop;
      Nick_Oldest:= List_Aux.Nick;
      Ep_Oldest:= List_Aux.Client_EP;
   end Search_Oldest;

   procedure Search_EP (List: in out Client_List_Type;
            EP: in LLU.End_Point_Type;
            Position_Ep: out Integer; Found: out Boolean) is
      I:Integer;
   begin

      I := 1;
      while I <= Max_Client loop
         If Es_Igual_EP(List.Almacen(I).Client_EP,EP) then
            Found:= True;
            Position_Ep:=I;
            exit;
         end if;
         I:=I+1;
      end loop;

   end Search_EP;
   procedure Search_Nick (List: in out Client_List_Type;
               Nick: in ASU.Unbounded_String;
               Position_Nick: out Integer;
               P_Anterior_Nick: out cell;
               Found: out Boolean) is
   
      I:Integer;
   begin

      I := 1;
      while I <= Max_Client loop
         If Es_Igual_Nick(List.Almacen(I).Nick,Nick) and (List.Almacen(I).Full = True) then
            Found:= True;
            Position_Nick:=I;
            exit;
         end if;
         P_Anterior_Nick:= List.Almacen(I);
         I:=I+1;
      end loop;
   end Search_Nick;


  procedure Add_Client (List: in out Client_List_Type;
                         EP: in LLU.End_Point_Type;
                         Nick: in ASU.Unbounded_String) is
    
      I:Integer;
      Position_Nick: Integer;
      P_Anterior_Nick:cell;
      Found_Nick: Boolean;
   begin
      I := 1;
                   
    while I <= Max_Client loop

      If List.Almacen(I).Full = False then

        Search_Nick(List,Nick,Position_Nick,P_Anterior_Nick,Found_Nick);

         If Found_Nick = True then
            raise Client_List_Error;
         end If;        
         List.Almacen(I).Client_EP := EP;
         List.Almacen(I).Nick := Nick;
         List.Almacen(I).Time := Ada.Calendar.Clock;
         List.Almacen(I).Full := True;
         List.Total := List.Total +1;
         exit;
      else
         I := I + 1;

      End If;
        
   end loop;
    Ada.Text_IO.Put_Line ("INIT received from " &
          ASU.To_String(Nick) & ": ACCEPTED");

  end Add_Client;

   procedure Delete_Client (List: in out Client_List_Type;
                            Nick: in ASU.Unbounded_String) is
      Position_Nick: Integer;
      P_Anterior_Nick:cell;
      Found_Nick: Boolean;
   begin
      Search_Nick(List,Nick,Position_Nick,P_Anterior_Nick,Found_Nick);
      If Found_Nick = True then
         Ada.Text_IO.Put_Line ("Borrando el usuario");
         List.Almacen(Position_Nick).Full:=False;
         List.Total:= List.Total -1;
      else
         raise Client_List_Error;
      end if;
   Exception
      when Client_List_Error =>
         Ada.Text_IO.Put_Line(ASU.To_String(Nick) &
             " No se encuentra en la lista");

   end Delete_Client;

   function Search_Client (List: in Client_List_Type;
                           EP: in LLU.End_Point_Type)
                          return ASU.Unbounded_String is
      Position_Ep:Integer;
      Found:Boolean;
      List_Aux:Client_List_Type;
   begin
      --Si no hago esto me salta un error
      --me imagino que es porque List no es un parametro
      --in out y como se tiene que meter una variable 
      --tengo que hacerlo de esta manera.
      List_Aux:= List;
      Search_EP(List_Aux,EP,Position_Ep,Found);
      If Found = False then
         raise Client_List_Error;
      end if;
      If List.Almacen(Position_Ep).Full = False then
         raise Client_List_Error;
      else
         return List.Almacen(Position_Ep).Nick;
      end if;

   end Search_Client;

   procedure Send_To_All (List: in Client_List_Type;
                          P_Buffer: access LLU.Buffer_Type;
                          EP_Not_Send: in LLU.End_Point_Type) is
      I:Integer;
   begin 
      I := 1;
      If List.Total = 0  then 
         raise Client_List_Error;
      end if;
      while I <= Max_Client loop
         if Es_Igual_EP(List.Almacen(I).Client_EP,EP_Not_Send) then
            null;
         else 
            If List.Almacen(I).Full = True then
               LLU.Send(List.Almacen(I).Client_EP,P_Buffer);
            end if;
         end if;

         I:=I+1;
      end loop;
   Exception
      when  Client_List_Error =>
         null;

   end Send_To_All;

   function List_Image (List: in Client_List_Type) return String is
   
      Line:ASU.Unbounded_String;
      Dir_Ip:ASU.Unbounded_String;
      Puerto:ASU.Unbounded_String;
      Resultado:ASU.Unbounded_String;
      Unidas:ASU.Unbounded_String;
      I:Integer;
   begin
      I := 1;
      while I <= Max_Client loop

         If List.Almacen(I).Full = True then
            Line:=ASU.To_Unbounded_String(LLU.Image(List.Almacen(I).Client_EP));
            Trocear_Ep(Line,Dir_Ip,Puerto);
            Unidas:=ASU.To_Unbounded_String(Unir3_Cadenas(Dir_Ip,Puerto,List.Almacen(I).Nick));
            Resultado:=ASU.To_Unbounded_String(Unir2_Cadenas(Resultado,Unidas));
         end if;
         I:=I+1;
      end loop;
      return ASU.To_String (Resultado);
   end List_Image;

   procedure Update_Client (List: in out Client_List_Type;
                            EP: in LLU.End_Point_Type) is
      Position_Ep: Integer;
      Found:Boolean;
   begin
      Search_EP(List,EP,Position_EP,Found);
      Ada.Text_IO.Put_Line ("Actualizado" & ASU.To_String(List.Almacen(Position_Ep).Nick));
      List.Almacen(Position_Ep).Time := Ada.Calendar.Clock;
   end Update_Client;


   procedure Remove_Oldest (List: in out Client_List_Type;
               EP: out LLU.End_Point_Type;
               Nick: out ASU.Unbounded_String) is

      Ep_Oldest:LLU.End_Point_Type;
      Nick_Oldest:ASU.Unbounded_String;
   begin

      Search_Oldest(List,Nick_Oldest,Ep_Oldest);

      EP:= Ep_Oldest;
      Nick:=Nick_Oldest;

      Delete_Client(List,Nick_Oldest);

   end Remove_Oldest;

   function Count (List: in Client_List_Type) return Natural is

   begin
      return List.Total;
   end Count;

end Client_Lists;