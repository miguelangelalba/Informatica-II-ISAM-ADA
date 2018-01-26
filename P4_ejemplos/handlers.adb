with Ada.Text_IO;
with Ada.Strings.Unbounded;

package body Handlers is

   package ASU renames Ada.Strings.Unbounded;

   Handler_Call_Counter : Natural := 0;


   procedure Peer_Handler (From    : in     LLU.End_Point_Type;
                           To      : in     LLU.End_Point_Type;
                           P_Buffer: access LLU.Buffer_Type) is
      use type ASU.Unbounded_String;

      S          : ASU.Unbounded_String;
   begin
      -- Extracts text
      S := ASU.Unbounded_String'Input(P_Buffer);

      Ada.Text_Io.Put_Line
        ("               Handler received: " & ASU.To_String(S));

   end Peer_Handler;

end Handlers;

