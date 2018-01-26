--Miguel Ángel Alba Blanco
with Ada.Text_IO;
with Ada.Calendar;
with Ada.Strings.Unbounded;
with Gnat.Calendar.Time_IO;

package body To_String_Time is

	--package ASU renames Ada.Strings.Unbounded;
	--package C_IO renames Gnat.Calendar.Time_IO;

function Image_3 (T: Ada.Calendar.Time) return String is
   begin
	   return C_IO.Image(T, "%T.%i");
end Image_3;

end	To_String_Time;