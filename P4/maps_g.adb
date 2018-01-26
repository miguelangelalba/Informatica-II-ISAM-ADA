--Miguel Ángel Alba Blanco
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Maps_G is

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= null Loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type;
                  Success: out Boolean) is
      P_Aux : Cell_A;
      Found : Boolean;
   begin
      -- Si ya existe Key, cambiamos su Value
      P_Aux := M.P_First;
      Found := False;
      If M.Length < Max_Length then
         Success := True;
         while not Found and P_Aux /= null loop
            if P_Aux.Key = Key then
               P_Aux.Value := Value;
               Found := True;
            end if;
            P_Aux := P_Aux.Next;
         end loop;

         -- Si no hemos encontrado Key añadimos al principio
         if not Found then
            M.P_First := new Cell'(Key, Value, M.P_First);
            M.Length := M.Length + 1;
         end if;
      else
         Success:=False;
      end if;


   end Put;

   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Current  : Cell_A;
      P_Previous : Cell_A;
   begin
      Success := False;
      P_Previous := null;
      P_Current  := M.P_First;
      while not Success and P_Current /= null  loop
         if P_Current.Key = Key then
            Success := True;
            M.Length := M.Length - 1;
            if P_Previous /= null then
               P_Previous.Next := P_Current.Next;
            end if;
            if M.P_First = P_Current then
               M.P_First := M.P_First.Next;
            end if;
            Free (P_Current);
         else
            P_Previous := P_Current;
            P_Current := P_Current.Next;
         end if;
      end loop;

   end Delete;


   function Get_Keys (M : Map) return Keys_Array_Type is
      P_Aux : Cell_A;
      n: Integer:= 1;
      Warehouse:Keys_Array_Type;
      I:Integer:=1;
   begin 
      P_Aux := M.P_First;

      while I <= Max_Length loop
         warehouse(I):= Null_Key;
         I:=I+1;
      end loop;

      while P_Aux /= null loop
         warehouse(n):= P_Aux.Key;
         P_Aux:= P_Aux.Next;
         n:=n+1;
      end loop;

      return Warehouse;
   end Get_Keys;

   function Get_Values (M : Map) return Values_Array_Type is
      P_Aux : Cell_A;
      n: Integer:= 1;
      Warehouse:Values_Array_Type;
      I:Integer:=1;
   begin
      P_Aux := M.P_First;

      while I <= Max_Length loop
         warehouse(I):= Null_Value;
         I:=I+1;
      end loop;

      while P_Aux /= null loop
         warehouse(n):= P_Aux.Value;
         P_Aux:= P_Aux.Next;
         n:=n+1;
      end loop;
      return Warehouse;     
   end Get_Values;

   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;

   procedure Print_Map (M : Map) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;

      Ada.Text_IO.Put_Line ("Map");
      Ada.Text_IO.Put_Line ("===");

      while P_Aux /= null loop
         Ada.Text_IO.Put_Line (Key_To_String(P_Aux.Key) & " " &
                                 VAlue_To_String(P_Aux.Value));
         P_Aux := P_Aux.Next;
      end loop;
   end Print_Map;



end Maps_G;
